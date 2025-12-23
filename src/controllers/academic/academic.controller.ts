// =====================================================
// controllers/academic/academic.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { semesterService } from "@/services/semesters/semester.service";
import { subjectService } from "@/services/subjects/subject.service";
import { academicPeriodService } from "@/services/academicPeriods/academicPeriod.service";
import { enrollmentService } from "@/services/enrollments/enrollment.service";
import {
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendConflict,
  sendBadRequest,
  sendServerError,
  sendValidationError,
  sendForbidden,
} from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as semesterSchemas from "@/types/schemas/semesters/semester.schemas";
import * as subjectSchemas from "@/types/schemas/subjects/subject.schemas";
import * as periodSchemas from "@/types/schemas/academicPeriods/academicPeriod.schemas";
import * as enrollmentSchemas from "@/types/schemas/enrollments/enrollment.schemas";

// =====================================================
// SEMESTER CONTROLLERS
// =====================================================
export async function createSemester(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const data = semesterSchemas.createSemesterSchema.parse(req.body);
    const semester = await semesterService.create(userId, data);
    return sendCreated({ res, message: "Semestre creado exitosamente", data: semester });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "CAREER_NOT_FOUND") return sendNotFound({ res, message: "Carrera no encontrada" });
    if (error.message === "INVALID_SEMESTER_NUMBER") return sendBadRequest({ res, message: "Número de semestre inválido" });
    if (error.message === "SEMESTER_ALREADY_EXISTS") return sendConflict({ res, message: "El semestre ya existe" });
    return sendServerError({ res, message: "Error al crear semestre" });
  }
}

export async function getSemestersByCareer(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId } = req.params;
    const semesters = await semesterService.findByCareer(userId, careerId);
    return sendSuccess({ res, message: "Semestres obtenidos exitosamente", data: semesters });
  } catch (error: any) {
    if (error.message === "CAREER_NOT_FOUND") return sendNotFound({ res, message: "Carrera no encontrada" });
    return sendServerError({ res, message: "Error al obtener semestres" });
  }
}

export async function getSemesterById(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = semesterSchemas.semesterIdSchema.parse(req.params);
    const semester = await semesterService.findById(userId, id);
    if (!semester) return sendNotFound({ res, message: "Semestre no encontrado" });
    return sendSuccess({ res, message: "Semestre obtenido exitosamente", data: semester });
  } catch (error: any) {
    if (error.message === "UNAUTHORIZED") return sendForbidden({ res, message: "No autorizado" });
    return sendServerError({ res, message: "Error al obtener semestre" });
  }
}

export async function updateSemester(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = semesterSchemas.semesterIdSchema.parse(req.params);
    const data = semesterSchemas.updateSemesterSchema.parse(req.body);
    const semester = await semesterService.update(userId, id, data);
    return sendSuccess({ res, message: "Semestre actualizado exitosamente", data: semester });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Semestre no encontrado" });
    if (error.message === "UNAUTHORIZED") return sendForbidden({ res, message: "No autorizado" });
    return sendServerError({ res, message: "Error al actualizar semestre" });
  }
}

export async function deleteSemester(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = semesterSchemas.semesterIdSchema.parse(req.params);
    await semesterService.delete(userId, id);
    return sendSuccess({ res, message: "Semestre eliminado exitosamente" });
  } catch (error: any) {
    if (error.message === "SEMESTER_HAS_SUBJECTS") return sendBadRequest({ res, message: "El semestre tiene materias asociadas" });
    return sendServerError({ res, message: "Error al eliminar semestre" });
  }
}

// =====================================================
// SUBJECT CONTROLLERS
// =====================================================
export async function createSubject(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const data = subjectSchemas.createSubjectSchema.parse(req.body);
    const subject = await subjectService.create(userId, data);
    return sendCreated({ res, message: "Materia creada exitosamente", data: subject });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SUBJECT_CODE_EXISTS") return sendConflict({ res, message: "El código de materia ya existe" });
    return sendServerError({ res, message: "Error al crear materia" });
  }
}

export async function getSubjectsByCareer(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId } = req.params;
    const filters = subjectSchemas.subjectQuerySchema.parse(req.query);
    const subjects = await subjectService.findByCareer(userId, careerId, filters);
    return sendSuccess({ res, message: "Materias obtenidas exitosamente", data: subjects });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener materias" });
  }
}

export async function getSubjectById(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = subjectSchemas.subjectIdSchema.parse(req.params);
    const subject = await subjectService.findById(userId, id);
    if (!subject) return sendNotFound({ res, message: "Materia no encontrada" });
    return sendSuccess({ res, message: "Materia obtenida exitosamente", data: subject });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener materia" });
  }
}

export async function updateSubject(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = subjectSchemas.subjectIdSchema.parse(req.params);
    const data = subjectSchemas.updateSubjectSchema.parse(req.body);
    const subject = await subjectService.update(userId, id, data);
    return sendSuccess({ res, message: "Materia actualizada exitosamente", data: subject });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al actualizar materia" });
  }
}

export async function deleteSubject(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = subjectSchemas.subjectIdSchema.parse(req.params);
    await subjectService.softDelete(userId, id);
    return sendSuccess({ res, message: "Materia eliminada exitosamente" });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al eliminar materia" });
  }
}

export async function addPrerequisite(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = req.params;
    const data = subjectSchemas.addPrerequisiteSchema.parse(req.body);
    const result = await subjectService.addPrerequisite(userId, id, data);
    return sendCreated({ res, message: "Prerequisito agregado exitosamente", data: result });
  } catch (error: any) {
    if (error.message === "CANNOT_BE_SELF_PREREQUISITE") return sendBadRequest({ res, message: "La materia no puede ser prerequisito de sí misma" });
    if (error.message === "PREREQUISITE_ALREADY_EXISTS") return sendConflict({ res, message: "El prerequisito ya existe" });
    return sendServerError({ res, message: "Error al agregar prerequisito" });
  }
}

export async function removePrerequisite(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id, prerequisiteId } = req.params;
    await subjectService.removePrerequisite(userId, id, prerequisiteId);
    return sendSuccess({ res, message: "Prerequisito eliminado exitosamente" });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al eliminar prerequisito" });
  }
}

// =====================================================
// ACADEMIC PERIOD CONTROLLERS
// =====================================================
export async function createPeriod(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const data = periodSchemas.createAcademicPeriodSchema.parse(req.body);
    const period = await academicPeriodService.create(userId, data);
    return sendCreated({ res, message: "Período académico creado exitosamente", data: period });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "ACADEMIC_PERIOD_EXISTS") return sendConflict({ res, message: "El período académico ya existe" });
    return sendServerError({ res, message: "Error al crear período académico" });
  }
}

export async function getPeriodsByCareer(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId } = req.params;
    const periods = await academicPeriodService.findByCareer(userId, careerId);
    return sendSuccess({ res, message: "Períodos académicos obtenidos exitosamente", data: periods });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener períodos académicos" });
  }
}

export async function getCurrentPeriod(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId } = req.params;
    const period = await academicPeriodService.getCurrentPeriod(userId, careerId);
    if (!period) return sendNotFound({ res, message: "No hay período académico activo" });
    return sendSuccess({ res, message: "Período actual obtenido exitosamente", data: period });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener período actual" });
  }
}

// =====================================================
// ENROLLMENT CONTROLLERS
// =====================================================
export async function enrollSubject(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const data = enrollmentSchemas.createEnrollmentSchema.parse(req.body);
    const enrollment = await enrollmentService.create(userId, data);
    return sendCreated({ res, message: "Inscripción creada exitosamente", data: enrollment });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "ALREADY_ENROLLED") return sendConflict({ res, message: "Ya está inscrito en esta materia" });
    if (error.message === "PREREQUISITES_NOT_MET") return sendBadRequest({ res, message: "No cumple con los prerequisitos" });
    if (error.message === "COREQUISITES_NOT_MET") return sendBadRequest({ res, message: "No cumple con los corequisitos" });
    return sendServerError({ res, message: "Error al inscribir materia" });
  }
}

export async function getEnrollmentsByCareer(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId } = req.params;
    const filters = enrollmentSchemas.enrollmentQuerySchema.parse(req.query);
    const enrollments = await enrollmentService.findByUser(userId, careerId, filters);
    return sendSuccess({ res, message: "Inscripciones obtenidas exitosamente", data: enrollments });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener inscripciones" });
  }
}

export async function getEnrollmentById(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = enrollmentSchemas.enrollmentIdSchema.parse(req.params);
    const enrollment = await enrollmentService.findById(userId, id);
    if (!enrollment) return sendNotFound({ res, message: "Inscripción no encontrada" });
    return sendSuccess({ res, message: "Inscripción obtenida exitosamente", data: enrollment });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener inscripción" });
  }
}

export async function updateEnrollment(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = enrollmentSchemas.enrollmentIdSchema.parse(req.params);
    const data = enrollmentSchemas.updateEnrollmentSchema.parse(req.body);
    const enrollment = await enrollmentService.update(userId, id, data);
    return sendSuccess({ res, message: "Inscripción actualizada exitosamente", data: enrollment });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al actualizar inscripción" });
  }
}

export async function withdrawEnrollment(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = enrollmentSchemas.enrollmentIdSchema.parse(req.params);
    const enrollment = await enrollmentService.withdraw(userId, id);
    return sendSuccess({ res, message: "Materia retirada exitosamente", data: enrollment });
  } catch (error: any) {
    if (error.message === "CANNOT_WITHDRAW_COMPLETED") return sendBadRequest({ res, message: "No se puede retirar una materia completada" });
    return sendServerError({ res, message: "Error al retirar materia" });
  }
}
