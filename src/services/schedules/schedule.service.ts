// =====================================================
// services/schedules/schedule.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateScheduleInput,
  UpdateScheduleInput,
  CreateScheduleExceptionInput,
  UpdateScheduleExceptionInput,
  WeeklyScheduleQueryInput,
} from "@/types/schemas/schedules/schedule.schemas";
import type { Schedule, ScheduleException } from "generated/prisma/client";

// =====================================================
// SCHEDULE SERVICE
// =====================================================
class ScheduleService {
  // =====================================================
  // CREATE SCHEDULE
  // =====================================================
  async createSchedule(userId: string, data: CreateScheduleInput): Promise<Schedule> {
    // Verificar que la inscripción existe y pertenece al usuario
    const enrollment = await database.subjectEnrollment.findFirst({
      where: { id: data.enrollmentId },
      include: {
        subject: {
          include: { career: true },
        },
      },
    });

    if (!enrollment) {
      throw new Error("ENROLLMENT_NOT_FOUND");
    }

    if (enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Validar fechas si se proporcionan
    if (data.startDate && data.endDate && data.startDate >= data.endDate) {
      throw new Error("INVALID_DATE_RANGE");
    }

    // Verificar conflictos de horario
    const hasConflict = await this.checkScheduleConflict(
      userId,
      enrollment.subject.careerId,
      data.dayOfWeek,
      data.startTime,
      data.endTime,
      data.startDate,
      data.endDate
    );

    if (hasConflict) {
      throw new Error("SCHEDULE_CONFLICT");
    }

    const schedule = await database.schedule.create({
      data,
      include: {
        enrollment: {
          include: {
            subject: true,
          },
        },
      },
    });

    return schedule;
  }

  // =====================================================
  // UPDATE SCHEDULE
  // =====================================================
  async updateSchedule(
    userId: string,
    id: string,
    data: UpdateScheduleInput
  ): Promise<Schedule> {
    const schedule = await database.schedule.findFirst({
      where: { id },
      include: {
        enrollment: {
          include: {
            subject: {
              include: { career: true },
            },
          },
        },
      },
    });

    if (!schedule) {
      throw new Error("NOT_FOUND");
    }

    if (schedule.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Validar fechas si se actualizan
    const startDate = data.startDate ?? schedule.startDate;
    const endDate = data.endDate ?? schedule.endDate;
    if (startDate && endDate && startDate >= endDate) {
      throw new Error("INVALID_DATE_RANGE");
    }

    // Si se cambian día u horas, verificar conflictos
    if (data.dayOfWeek !== undefined || data.startTime || data.endTime) {
      const dayOfWeek = data.dayOfWeek ?? schedule.dayOfWeek;
      const startTime = data.startTime ?? schedule.startTime;
      const endTime = data.endTime ?? schedule.endTime;

      const hasConflict = await this.checkScheduleConflict(
        userId,
        schedule.enrollment.subject.careerId,
        dayOfWeek,
        startTime,
        endTime,
        startDate,
        endDate,
        id // Excluir el horario actual
      );

      if (hasConflict) {
        throw new Error("SCHEDULE_CONFLICT");
      }
    }

    const updated = await database.schedule.update({
      where: { id },
      data,
    });

    return updated;
  }

  // =====================================================
  // DELETE SCHEDULE
  // =====================================================
  async deleteSchedule(userId: string, id: string): Promise<void> {
    const schedule = await database.schedule.findFirst({
      where: { id },
      include: {
        enrollment: {
          include: {
            subject: {
              include: { career: true },
            },
          },
        },
      },
    });

    if (!schedule) {
      throw new Error("NOT_FOUND");
    }

    if (schedule.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    await database.schedule.update({
      where: { id },
      data: { state: "I" },
    });
  }

  // =====================================================
  // GET SCHEDULES BY ENROLLMENT
  // =====================================================
  async getSchedulesByEnrollment(
    userId: string,
    enrollmentId: string
  ): Promise<Schedule[]> {
    const enrollment = await database.subjectEnrollment.findFirst({
      where: { id: enrollmentId },
      include: {
        subject: {
          include: { career: true },
        },
      },
    });

    if (!enrollment) {
      throw new Error("ENROLLMENT_NOT_FOUND");
    }

    if (enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    const schedules = await database.schedule.findMany({
      where: {
        enrollmentId,
        state: "A",
      },
      orderBy: [{ dayOfWeek: "asc" }, { startTime: "asc" }],
      include: {
        exceptions: {
          where: { state: "A" },
        },
      },
    });

    return schedules;
  }

  // =====================================================
  // GET WEEKLY SCHEDULE
  // =====================================================
  async getWeeklySchedule(userId: string, query: WeeklyScheduleQueryInput) {
    // Verificar que la carrera pertenece al usuario
    const career = await database.career.findFirst({
      where: {
        id: query.careerId,
        userId,
        deletedAt: null,
      },
    });

    if (!career) {
      throw new Error("CAREER_NOT_FOUND");
    }

    // Obtener todos los horarios de la carrera
    const schedules = await database.schedule.findMany({
      where: {
        enrollment: {
          subject: {
            careerId: query.careerId,
          },
          status: { in: ["ENROLLED", "IN_PROGRESS"] },
        },
        state: "A",
      },
      include: {
        enrollment: {
          include: {
            subject: {
              include: {
                semester: true,
              },
            },
          },
        },
        exceptions: {
          where: { state: "A" },
        },
      },
      orderBy: [{ dayOfWeek: "asc" }, { startTime: "asc" }],
    });

    // Organizar por día de la semana
    const weeklySchedule = {
      sunday: schedules.filter((s) => s.dayOfWeek === 0),
      monday: schedules.filter((s) => s.dayOfWeek === 1),
      tuesday: schedules.filter((s) => s.dayOfWeek === 2),
      wednesday: schedules.filter((s) => s.dayOfWeek === 3),
      thursday: schedules.filter((s) => s.dayOfWeek === 4),
      friday: schedules.filter((s) => s.dayOfWeek === 5),
      saturday: schedules.filter((s) => s.dayOfWeek === 6),
    };

    return weeklySchedule;
  }

  // =====================================================
  // CHECK CONFLICTS
  // =====================================================
  async checkConflicts(careerId: string) {
    const schedules = await database.schedule.findMany({
      where: {
        enrollment: {
          subject: {
            careerId,
          },
        },
        state: "A",
      },
      include: {
        enrollment: {
          include: {
            subject: true,
          },
        },
      },
    });

    const conflicts: any[] = [];

    for (let i = 0; i < schedules.length; i++) {
      for (let j = i + 1; j < schedules.length; j++) {
        const s1 = schedules[i];
        const s2 = schedules[j];

        if (s1.dayOfWeek === s2.dayOfWeek) {
          if (this.timesOverlap(s1.startTime, s1.endTime, s2.startTime, s2.endTime)) {
            conflicts.push({
              schedule1: {
                id: s1.id,
                subject: s1.enrollment.subject.name,
                time: `${s1.startTime} - ${s1.endTime}`,
                room: s1.room,
              },
              schedule2: {
                id: s2.id,
                subject: s2.enrollment.subject.name,
                time: `${s2.startTime} - ${s2.endTime}`,
                room: s2.room,
              },
              day: s1.dayOfWeek,
            });
          }
        }
      }
    }

    return conflicts;
  }

  // =====================================================
  // CREATE SCHEDULE EXCEPTION
  // =====================================================
  async createException(
    userId: string,
    data: CreateScheduleExceptionInput
  ): Promise<ScheduleException> {
    const schedule = await database.schedule.findFirst({
      where: { id: data.scheduleId },
      include: {
        enrollment: {
          include: {
            subject: {
              include: { career: true },
            },
          },
        },
      },
    });

    if (!schedule) {
      throw new Error("SCHEDULE_NOT_FOUND");
    }

    if (schedule.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Verificar que no exista ya una excepción para esta fecha
    const existing = await database.scheduleException.findUnique({
      where: {
        scheduleId_date: {
          scheduleId: data.scheduleId,
          date: data.date,
        },
      },
    });

    if (existing) {
      throw new Error("EXCEPTION_ALREADY_EXISTS");
    }

    const exception = await database.scheduleException.create({
      data,
    });

    return exception;
  }

  // =====================================================
  // UPDATE SCHEDULE EXCEPTION
  // =====================================================
  async updateException(
    userId: string,
    id: string,
    data: UpdateScheduleExceptionInput
  ): Promise<ScheduleException> {
    const exception = await database.scheduleException.findFirst({
      where: { id },
      include: {
        schedule: {
          include: {
            enrollment: {
              include: {
                subject: {
                  include: { career: true },
                },
              },
            },
          },
        },
      },
    });

    if (!exception) {
      throw new Error("NOT_FOUND");
    }

    if (exception.schedule.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    const updated = await database.scheduleException.update({
      where: { id },
      data,
    });

    return updated;
  }

  // =====================================================
  // DELETE SCHEDULE EXCEPTION
  // =====================================================
  async deleteException(userId: string, id: string): Promise<void> {
    const exception = await database.scheduleException.findFirst({
      where: { id },
      include: {
        schedule: {
          include: {
            enrollment: {
              include: {
                subject: {
                  include: { career: true },
                },
              },
            },
          },
        },
      },
    });

    if (!exception) {
      throw new Error("NOT_FOUND");
    }

    if (exception.schedule.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    await database.scheduleException.update({
      where: { id },
      data: { state: "I" },
    });
  }

  // =====================================================
  // HELPER: CHECK SCHEDULE CONFLICT
  // =====================================================
  private async checkScheduleConflict(
    userId: string,
    careerId: string,
    dayOfWeek: number,
    startTime: string,
    endTime: string,
    startDate?: Date | null,
    endDate?: Date | null,
    excludeScheduleId?: string
  ): Promise<boolean> {
    const schedules = await database.schedule.findMany({
      where: {
        enrollment: {
          subject: {
            careerId,
            career: { userId },
          },
        },
        dayOfWeek,
        state: "A",
        ...(excludeScheduleId && { id: { not: excludeScheduleId } }),
      },
    });

    for (const schedule of schedules) {
      if (this.timesOverlap(startTime, endTime, schedule.startTime, schedule.endTime)) {
        // Verificar superposición de fechas si aplica
        if (startDate && endDate && schedule.startDate && schedule.endDate) {
          if (this.datesOverlap(startDate, endDate, schedule.startDate, schedule.endDate)) {
            return true;
          }
        } else if (!startDate && !endDate && !schedule.startDate && !schedule.endDate) {
          // Ambos son recurrentes sin límite de fecha
          return true;
        }
      }
    }

    return false;
  }

  // =====================================================
  // HELPER: CHECK TIME OVERLAP
  // =====================================================
  private timesOverlap(
    start1: string,
    end1: string,
    start2: string,
    end2: string
  ): boolean {
    const [s1h, s1m] = start1.split(":").map(Number);
    const [e1h, e1m] = end1.split(":").map(Number);
    const [s2h, s2m] = start2.split(":").map(Number);
    const [e2h, e2m] = end2.split(":").map(Number);

    const start1Minutes = s1h * 60 + s1m;
    const end1Minutes = e1h * 60 + e1m;
    const start2Minutes = s2h * 60 + s2m;
    const end2Minutes = e2h * 60 + e2m;

    return start1Minutes < end2Minutes && start2Minutes < end1Minutes;
  }

  // =====================================================
  // HELPER: CHECK DATE OVERLAP
  // =====================================================
  private datesOverlap(
    start1: Date,
    end1: Date,
    start2: Date,
    end2: Date
  ): boolean {
    return start1 < end2 && start2 < end1;
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const scheduleService = new ScheduleService();
