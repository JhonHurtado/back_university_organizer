// =====================================================
// services/preference.service.ts
// =====================================================

import database from "@/lib/prisma/prisma";
import { GradeScale } from "generated/prisma/enums";


// =====================================================
// OBTENER PREFERENCIAS
// =====================================================
export async function getPreferences(userId: string) {
  return database.userPreference.findUnique({
    where: { userId },
  });
}

// =====================================================
// CREAR PREFERENCIAS (si no existen)
// =====================================================
export async function createPreferences(userId: string) {
  return database.userPreference.create({
    data: { userId },
  });
}

// =====================================================
// ACTUALIZAR PREFERENCIAS
// =====================================================
export async function updatePreferences(
  userId: string,
  data: {
    emailNotifications?: boolean;
    pushNotifications?: boolean;
    gradeAlerts?: boolean;
    scheduleReminders?: boolean;
    reminderMinutesBefore?: number;
    darkMode?: boolean;
    compactView?: boolean;
    weekStartsOn?: number;
    gradeScale?: GradeScale;
    showGPA?: boolean;
  }
) {
  return database.userPreference.upsert({
    where: { userId },
    update: data,
    create: { userId, ...data },
  });
}

// =====================================================
// ACTUALIZAR NOTIFICACIONES
// =====================================================
export async function updateNotificationPreferences(
  userId: string,
  data: {
    emailNotifications?: boolean;
    pushNotifications?: boolean;
    gradeAlerts?: boolean;
    scheduleReminders?: boolean;
    reminderMinutesBefore?: number;
  }
) {
  return database.userPreference.update({
    where: { userId },
    data,
  });
}

// =====================================================
// ACTUALIZAR VISUALIZACIÓN
// =====================================================
export async function updateDisplayPreferences(
  userId: string,
  data: {
    darkMode?: boolean;
    compactView?: boolean;
    weekStartsOn?: number;
  }
) {
  return database.userPreference.update({
    where: { userId },
    data,
  });
}

// =====================================================
// ACTUALIZAR ACADÉMICO
// =====================================================
export async function updateAcademicPreferences(
  userId: string,
  data: {
    gradeScale?: GradeScale;
    showGPA?: boolean;
  }
) {
  return database.userPreference.update({
    where: { userId },
    data,
  });
}