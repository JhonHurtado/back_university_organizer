// =====================================================
// prisma/seed.ts
// Database Seed File - Comprehensive Test Data
// =====================================================

import { PrismaClient } from "@prisma/client";
import bcrypt from "bcrypt";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Starting database seeding...");

  // =====================================================
  // 1. API CLIENTS
  // =====================================================
  console.log("\n📦 Creating API clients...");

  await prisma.apiClient.create({
    data: {
      name: "Web Application",
      clientId: "cli_web_app_12345",
      clientSecret: await bcrypt.hash("secret_web_app_67890", 10),
      description: "Main web application client",
      status: "ACTIVE",
      scopes: ["read:users", "write:users", "read:careers", "write:careers"],
      rateLimit: 10000,
    },
  });

   await prisma.apiClient.create({
    data: {
      name: "Mobile App",
      clientId: "cli_mobile_app_54321",
      clientSecret: await bcrypt.hash("secret_mobile_app_09876", 10),
      description: "Official mobile application",
      status: "ACTIVE",
      scopes: ["read:users", "write:users"],
      rateLimit: 5000,
    },
  });

  console.log(`✅ Created ${2} API clients`);

  // =====================================================
  // 2. PLANS & FEATURES
  // =====================================================
  console.log("\n💎 Creating subscription plans...");

  const freePlan = await prisma.plan.create({
    data: {
      name: "Free",
      slug: "free",
      description: "Basic features for getting started",
      price: 0,
      currency: "USD",
      billingPeriod: "MONTHLY",
      trialDays: 0,
      maxCareers: 1,
      maxSubjectsPerCareer: 20,
      maxScheduleExports: 2,
      features: {
        basicSchedule: true,
        gradeTracking: true,
        notifications: false,
        analytics: false,
        export: false,
      },
      canExportPDF: false,
      canExportExcel: false,
      hasAnalytics: false,
      hasReminders: true,
      hasBackup: false,
      priority: 1,
      isActive: true,
      isPopular: false,
      sortOrder: 1,
    },
  });

  const premiumPlan = await prisma.plan.create({
    data: {
      name: "Premium",
      slug: "premium",
      description: "Full access to all features",
      price: 9.99,
      currency: "USD",
      billingPeriod: "MONTHLY",
      trialDays: 14,
      maxCareers: 5,
      maxSubjectsPerCareer: 100,
      maxScheduleExports: 50,
      features: {
        basicSchedule: true,
        gradeTracking: true,
        notifications: true,
        analytics: true,
        export: true,
        prioritySupport: true,
      },
      canExportPDF: true,
      canExportExcel: true,
      hasAnalytics: true,
      hasReminders: true,
      hasBackup: true,
      priority: 2,
      isActive: true,
      isPopular: true,
      sortOrder: 2,
    },
  });

  await prisma.plan.create({
    data: {
      name: "Enterprise",
      slug: "enterprise",
      description: "Advanced features for power users",
      price: 29.99,
      currency: "USD",
      billingPeriod: "MONTHLY",
      trialDays: 30,
      maxCareers: 999,
      maxSubjectsPerCareer: 999,
      maxScheduleExports: 999,
      features: {
        basicSchedule: true,
        gradeTracking: true,
        notifications: true,
        analytics: true,
        export: true,
        prioritySupport: true,
        customBranding: true,
        apiAccess: true,
      },
      canExportPDF: true,
      canExportExcel: true,
      hasAnalytics: true,
      hasReminders: true,
      hasBackup: true,
      priority: 3,
      isActive: true,
      isPopular: false,
      sortOrder: 3,
    },
  });

  console.log(`✅ Created ${3} subscription plans`);

  // =====================================================
  // 3. MENUS
  // =====================================================
  console.log("\n📋 Creating menu structure...");

  await prisma.menu.create({
    data: {
      name: "dashboard",
      label: "Dashboard",
      labelKey: "menu.dashboard",
      icon: "dashboard",
      path: "/dashboard",
      sortOrder: 1,
      isActive: true,
      isPremium: false,
    },
  });

  const academicMenu = await prisma.menu.create({
    data: {
      name: "academic",
      label: "Academic",
      labelKey: "menu.academic",
      icon: "school",
      path: "/academic",
      sortOrder: 2,
      isActive: true,
      isPremium: false,
    },
  });

  await prisma.menu.create({
    data: {
      name: "careers",
      label: "Careers",
      labelKey: "menu.academic.careers",
      icon: "graduation-cap",
      path: "/academic/careers",
      parentId: academicMenu.id,
      sortOrder: 1,
      isActive: true,
      isPremium: false,
    },
  });

  await prisma.menu.create({
    data: {
      name: "subjects",
      label: "Subjects",
      labelKey: "menu.academic.subjects",
      icon: "book",
      path: "/academic/subjects",
      parentId: academicMenu.id,
      sortOrder: 2,
      isActive: true,
      isPremium: false,
    },
  });

  await prisma.menu.create({
    data: {
      name: "analytics",
      label: "Analytics",
      labelKey: "menu.analytics",
      icon: "chart-bar",
      path: "/analytics",
      sortOrder: 3,
      isActive: true,
      isPremium: true,
    },
  });

  console.log(`✅ Created ${5} menu items`);

  // =====================================================
  // 4. USERS
  // =====================================================
  console.log("\n👥 Creating users...");

  const hashedPassword = await bcrypt.hash("password123", 10);

  const user1 = await prisma.user.create({
    data: {
      email: "john.doe@university.edu",
      password: hashedPassword,
      firstName: "John",
      lastName: "Doe",
      phone: "+1234567890",
      timezone: "America/New_York",
      language: "en",
      isActive: true,
      emailVerified: true,
      emailVerifiedAt: new Date(),
    },
  });

  const user2 = await prisma.user.create({
    data: {
      email: "jane.smith@university.edu",
      password: hashedPassword,
      firstName: "Jane",
      lastName: "Smith",
      phone: "+1987654321",
      timezone: "America/Los_Angeles",
      language: "es",
      isActive: true,
      emailVerified: true,
      emailVerifiedAt: new Date(),
    },
  });

  await prisma.user.create({
    data: {
      email: "mike.johnson@university.edu",
      password: hashedPassword,
      firstName: "Mike",
      lastName: "Johnson",
      phone: "+1122334455",
      timezone: "America/Chicago",
      language: "en",
      isActive: true,
      emailVerified: false,
    },
  });

  console.log(`✅ Created ${3} users`);

  // =====================================================
  // 5. USER PREFERENCES
  // =====================================================
  console.log("\n⚙️  Creating user preferences...");

  await prisma.userPreference.create({
    data: {
      userId: user1.id,
      emailNotifications: true,
      pushNotifications: true,
      gradeAlerts: true,
      scheduleReminders: true,
      reminderMinutesBefore: 30,
      darkMode: false,
      compactView: false,
      weekStartsOn: 1,
      gradeScale: "FIVE",
      showGPA: true,
    },
  });

  await prisma.userPreference.create({
    data: {
      userId: user2.id,
      emailNotifications: true,
      pushNotifications: false,
      gradeAlerts: true,
      scheduleReminders: true,
      reminderMinutesBefore: 15,
      darkMode: true,
      compactView: true,
      weekStartsOn: 0,
      gradeScale: "TEN",
      showGPA: true,
    },
  });

  console.log(`✅ Created ${2} user preferences`);

  // =====================================================
  // 6. SUBSCRIPTIONS
  // =====================================================
  console.log("\n💳 Creating subscriptions...");

  const now = new Date();
  const oneMonthLater = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

  await prisma.subscription.create({
    data: {
      userId: user1.id,
      planId: premiumPlan.id,
      status: "ACTIVE",
      startDate: now,
      endDate: oneMonthLater,
      autoRenew: true,
    },
  });

  await prisma.subscription.create({
    data: {
      userId: user2.id,
      planId: freePlan.id,
      status: "ACTIVE",
      startDate: now,
      endDate: oneMonthLater,
      autoRenew: false,
    },
  });

  console.log(`✅ Created ${2} subscriptions`);

  // =====================================================
  // 7. CAREERS
  // =====================================================
  console.log("\n🎓 Creating careers...");

  const careerStartDate = new Date("2024-01-15");
  const careerEndDate = new Date("2029-06-30");

  const csCareer = await prisma.career.create({
    data: {
      userId: user1.id,
      name: "Computer Science",
      code: "CS-2024",
      university: "Massachusetts Institute of Technology",
      faculty: "Engineering",
      campus: "Main Campus",
      totalCredits: 180,
      totalSemesters: 10,
      currentSemester: 3,
      gradeScale: "FIVE",
      minPassingGrade: 3.0,
      maxGrade: 5.0,
      startDate: careerStartDate,
      expectedEndDate: careerEndDate,
      status: "ACTIVE",
      color: "#3B82F6",
    },
  });

  const businessCareer = await prisma.career.create({
    data: {
      userId: user2.id,
      name: "Business Administration",
      code: "BA-2024",
      university: "Harvard University",
      faculty: "Business School",
      campus: "Boston Campus",
      totalCredits: 150,
      totalSemesters: 8,
      currentSemester: 2,
      gradeScale: "FOUR_GPA",
      minPassingGrade: 2.0,
      maxGrade: 4.0,
      startDate: careerStartDate,
      expectedEndDate: new Date("2028-06-30"),
      status: "ACTIVE",
      color: "#10B981",
    },
  });

  console.log(`✅ Created ${2} careers`);

  // =====================================================
  // 8. SEMESTERS
  // =====================================================
  console.log("\n📚 Creating semesters...");

  const csSemester1 = await prisma.semester.create({
    data: {
      careerId: csCareer.id,
      number: 1,
      name: "First Semester",
      minCredits: 12,
      maxCredits: 18,
    },
  });

  const csSemester2 = await prisma.semester.create({
    data: {
      careerId: csCareer.id,
      number: 2,
      name: "Second Semester",
      minCredits: 12,
      maxCredits: 18,
    },
  });

  const csSemester3 = await prisma.semester.create({
    data: {
      careerId: csCareer.id,
      number: 3,
      name: "Third Semester",
      minCredits: 12,
      maxCredits: 18,
    },
  });

  const businessSemester1 = await prisma.semester.create({
    data: {
      careerId: businessCareer.id,
      number: 1,
      name: "First Semester",
      minCredits: 15,
      maxCredits: 20,
    },
  });

  console.log(`✅ Created ${4} semesters`);

  // =====================================================
  // 9. SUBJECTS
  // =====================================================
  console.log("\n📖 Creating subjects...");

  const cs101 = await prisma.subject.create({
    data: {
      careerId: csCareer.id,
      semesterId: csSemester1.id,
      code: "CS101",
      name: "Introduction to Programming",
      description: "Fundamental programming concepts using Python",
      credits: 4,
      hoursPerWeek: 6,
      subjectType: "REQUIRED",
      area: "Computer Science",
      totalCuts: 3,
      isElective: false,
      gradeWeights: {
        exams: 0.6,
        homework: 0.3,
        participation: 0.1,
      },
    },
  });

  const cs102 = await prisma.subject.create({
    data: {
      careerId: csCareer.id,
      semesterId: csSemester1.id,
      code: "CS102",
      name: "Data Structures",
      description: "Introduction to data structures and algorithms",
      credits: 4,
      hoursPerWeek: 6,
      subjectType: "REQUIRED",
      area: "Computer Science",
      totalCuts: 3,
      isElective: false,
    },
  });

  const cs201 = await prisma.subject.create({
    data: {
      careerId: csCareer.id,
      semesterId: csSemester2.id,
      code: "CS201",
      name: "Advanced Algorithms",
      description: "Advanced algorithmic techniques and analysis",
      credits: 4,
      hoursPerWeek: 6,
      subjectType: "REQUIRED",
      area: "Computer Science",
      totalCuts: 3,
      isElective: false,
    },
  });

  const cs301 = await prisma.subject.create({
    data: {
      careerId: csCareer.id,
      semesterId: csSemester3.id,
      code: "CS301",
      name: "Machine Learning",
      description: "Introduction to machine learning algorithms",
      credits: 4,
      hoursPerWeek: 6,
      subjectType: "ELECTIVE",
      area: "Artificial Intelligence",
      totalCuts: 3,
      isElective: true,
    },
  });

  const math101 = await prisma.subject.create({
    data: {
      careerId: csCareer.id,
      semesterId: csSemester1.id,
      code: "MATH101",
      name: "Calculus I",
      description: "Differential and integral calculus",
      credits: 4,
      hoursPerWeek: 5,
      subjectType: "REQUIRED",
      area: "Mathematics",
      totalCuts: 3,
      isElective: false,
    },
  });

  const bus101 = await prisma.subject.create({
    data: {
      careerId: businessCareer.id,
      semesterId: businessSemester1.id,
      code: "BUS101",
      name: "Introduction to Business",
      description: "Fundamentals of business administration",
      credits: 3,
      hoursPerWeek: 4,
      subjectType: "REQUIRED",
      area: "Business",
      totalCuts: 3,
      isElective: false,
    },
  });

  console.log(`✅ Created ${6} subjects`);

  // =====================================================
  // 10. SUBJECT PREREQUISITES
  // =====================================================
  console.log("\n🔗 Creating subject prerequisites...");

  await prisma.subjectPrerequisite.create({
    data: {
      subjectId: cs201.id,
      prerequisiteId: cs101.id,
      isStrict: true,
    },
  });

  await prisma.subjectPrerequisite.create({
    data: {
      subjectId: cs301.id,
      prerequisiteId: cs201.id,
      isStrict: true,
    },
  });

  console.log(`✅ Created ${2} prerequisites`);

  // =====================================================
  // 11. ACADEMIC PERIODS
  // =====================================================
  console.log("\n📅 Creating academic periods...");

  const period2024_1 = await prisma.academicPeriod.create({
    data: {
      careerId: csCareer.id,
      name: "2024-1",
      year: 2024,
      period: 1,
      startDate: new Date("2024-01-15"),
      endDate: new Date("2024-06-30"),
      isCurrent: false,
    },
  });

  const period2024_2 = await prisma.academicPeriod.create({
    data: {
      careerId: csCareer.id,
      name: "2024-2",
      year: 2024,
      period: 2,
      startDate: new Date("2024-08-01"),
      endDate: new Date("2024-12-20"),
      isCurrent: true,
    },
  });

  const businessPeriod = await prisma.academicPeriod.create({
    data: {
      careerId: businessCareer.id,
      name: "2024-1",
      year: 2024,
      period: 1,
      startDate: new Date("2024-01-15"),
      endDate: new Date("2024-06-30"),
      isCurrent: true,
    },
  });

  console.log(`✅ Created ${3} academic periods`);

  // =====================================================
  // 12. PROFESSORS
  // =====================================================
  console.log("\n👨‍🏫 Creating professors...");

  const profSmith = await prisma.professor.create({
    data: {
      firstName: "Dr. Robert",
      lastName: "Smith",
      email: "robert.smith@mit.edu",
      phone: "+1555123456",
      office: "Building A, Room 305",
      department: "Computer Science",
      title: "Associate Professor",
      notes: "Specializes in algorithms and data structures",
    },
  });

  const profJohnson = await prisma.professor.create({
    data: {
      firstName: "Dr. Emily",
      lastName: "Johnson",
      email: "emily.johnson@mit.edu",
      phone: "+1555654321",
      office: "Building B, Room 201",
      department: "Mathematics",
      title: "Full Professor",
      notes: "Expert in calculus and linear algebra",
    },
  });

  const profDavis = await prisma.professor.create({
    data: {
      firstName: "Dr. Michael",
      lastName: "Davis",
      email: "michael.davis@harvard.edu",
      phone: "+1555789012",
      office: "Business School, Room 401",
      department: "Business Administration",
      title: "Senior Lecturer",
      notes: "Focus on entrepreneurship and strategy",
    },
  });

  console.log(`✅ Created ${3} professors`);

  // =====================================================
  // 13. ENROLLMENTS
  // =====================================================
  console.log("\n📝 Creating enrollments...");

  const enrollment1 = await prisma.subjectEnrollment.create({
    data: {
      subjectId: cs101.id,
      academicPeriodId: period2024_1.id,
      status: "PASSED",
      attempt: 1,
      section: "A",
      classroom: "Room 301",
      finalGrade: 4.5,
      letterGrade: "A",
      gradePoints: 4.5,
      isPassed: true,
      completedAt: new Date("2024-06-15"),
    },
  });

  const enrollment2 = await prisma.subjectEnrollment.create({
    data: {
      subjectId: cs102.id,
      academicPeriodId: period2024_1.id,
      status: "PASSED",
      attempt: 1,
      section: "A",
      classroom: "Room 302",
      finalGrade: 4.2,
      letterGrade: "A",
      gradePoints: 4.2,
      isPassed: true,
      completedAt: new Date("2024-06-15"),
    },
  });

  const enrollment3 = await prisma.subjectEnrollment.create({
    data: {
      subjectId: math101.id,
      academicPeriodId: period2024_1.id,
      status: "PASSED",
      attempt: 1,
      section: "B",
      classroom: "Room 201",
      finalGrade: 3.8,
      letterGrade: "B+",
      gradePoints: 3.8,
      isPassed: true,
      completedAt: new Date("2024-06-15"),
    },
  });

  const enrollment4 = await prisma.subjectEnrollment.create({
    data: {
      subjectId: cs201.id,
      academicPeriodId: period2024_2.id,
      status: "IN_PROGRESS",
      attempt: 1,
      section: "A",
      classroom: "Room 303",
    },
  });

  const enrollment5 = await prisma.subjectEnrollment.create({
    data: {
      subjectId: bus101.id,
      academicPeriodId: businessPeriod.id,
      status: "IN_PROGRESS",
      attempt: 1,
      section: "A",
      classroom: "Business 101",
    },
  });

  console.log(`✅ Created ${5} enrollments`);

  // =====================================================
  // 14. ENROLLMENT PROFESSORS
  // =====================================================
  console.log("\n👨‍🏫 Assigning professors to enrollments...");

  await prisma.enrollmentProfessor.create({
    data: {
      enrollmentId: enrollment1.id,
      professorId: profSmith.id,
      role: "main",
    },
  });

  await prisma.enrollmentProfessor.create({
    data: {
      enrollmentId: enrollment2.id,
      professorId: profSmith.id,
      role: "main",
    },
  });

  await prisma.enrollmentProfessor.create({
    data: {
      enrollmentId: enrollment3.id,
      professorId: profJohnson.id,
      role: "main",
    },
  });

  await prisma.enrollmentProfessor.create({
    data: {
      enrollmentId: enrollment4.id,
      professorId: profSmith.id,
      role: "main",
    },
  });

  await prisma.enrollmentProfessor.create({
    data: {
      enrollmentId: enrollment5.id,
      professorId: profDavis.id,
      role: "main",
    },
  });

  console.log(`✅ Assigned ${5} professors to enrollments`);

  // =====================================================
  // 15. GRADES
  // =====================================================
  console.log("\n📊 Creating grades...");

  // Grades for completed enrollment (CS101)
  await prisma.grade.create({
    data: {
      enrollmentId: enrollment1.id,
      cutNumber: 1,
      cutName: "First Cut",
      weight: 0.33,
      grade: 4.3,
      maxGrade: 5.0,
      weightedGrade: 1.419,
      description: "Midterm exam and assignments",
      gradedAt: new Date("2024-03-15"),
    },
  });

  await prisma.grade.create({
    data: {
      enrollmentId: enrollment1.id,
      cutNumber: 2,
      cutName: "Second Cut",
      weight: 0.33,
      grade: 4.5,
      maxGrade: 5.0,
      weightedGrade: 1.485,
      description: "Projects and quizzes",
      gradedAt: new Date("2024-05-01"),
    },
  });

  await prisma.grade.create({
    data: {
      enrollmentId: enrollment1.id,
      cutNumber: 3,
      cutName: "Final Cut",
      weight: 0.34,
      grade: 4.7,
      maxGrade: 5.0,
      weightedGrade: 1.598,
      description: "Final exam and project",
      gradedAt: new Date("2024-06-10"),
    },
  });

  // Grades for in-progress enrollment (CS201)
  await prisma.grade.create({
    data: {
      enrollmentId: enrollment4.id,
      cutNumber: 1,
      cutName: "First Cut",
      weight: 0.33,
      grade: 4.0,
      maxGrade: 5.0,
      weightedGrade: 1.32,
      description: "Initial assessments",
      gradedAt: new Date("2024-10-01"),
    },
  });

  console.log(`✅ Created ${4} grades`);

  // =====================================================
  // 16. SCHEDULES
  // =====================================================
  console.log("\n⏰ Creating schedules...");

  const schedule1 = await prisma.schedule.create({
    data: {
      enrollmentId: enrollment4.id,
      dayOfWeek: 1, // Monday
      startTime: "08:00",
      endTime: "10:00",
      room: "Room 303",
      building: "Computer Science Building",
      type: "CLASS",
      color: "#3B82F6",
      isRecurring: true,
      startDate: new Date("2024-08-01"),
      endDate: new Date("2024-12-20"),
    },
  });

  await prisma.schedule.create({
    data: {
      enrollmentId: enrollment4.id,
      dayOfWeek: 3, // Wednesday
      startTime: "08:00",
      endTime: "10:00",
      room: "Room 303",
      building: "Computer Science Building",
      type: "CLASS",
      color: "#3B82F6",
      isRecurring: true,
      startDate: new Date("2024-08-01"),
      endDate: new Date("2024-12-20"),
    },
  });

  await prisma.schedule.create({
    data: {
      enrollmentId: enrollment5.id,
      dayOfWeek: 2, // Tuesday
      startTime: "14:00",
      endTime: "16:00",
      room: "Business 101",
      building: "Business School",
      type: "CLASS",
      color: "#10B981",
      isRecurring: true,
      startDate: new Date("2024-01-15"),
      endDate: new Date("2024-06-30"),
    },
  });

  console.log(`✅ Created ${3} schedules`);

  // =====================================================
  // 17. SCHEDULE EXCEPTIONS
  // =====================================================
  console.log("\n🚫 Creating schedule exceptions...");

  await prisma.scheduleException.create({
    data: {
      scheduleId: schedule1.id,
      date: new Date("2024-11-28"),
      type: "HOLIDAY",
      reason: "Thanksgiving Holiday",
    },
  });

  await prisma.scheduleException.create({
    data: {
      scheduleId: schedule1.id,
      date: new Date("2024-12-25"),
      type: "CANCELLED",
      reason: "Christmas Holiday",
    },
  });

  console.log(`✅ Created ${2} schedule exceptions`);

  // =====================================================
  // 18. NOTIFICATIONS
  // =====================================================
  console.log("\n🔔 Creating notifications...");

  await prisma.notification.create({
    data: {
      userId: user1.id,
      title: "New Grade Posted",
      message: "Your grade for CS201 - First Cut has been posted",
      type: "SUCCESS",
      category: "GRADE",
      isRead: false,
      actionUrl: "/academic/grades",
      actionLabel: "View Grade",
    },
  });

  await prisma.notification.create({
    data: {
      userId: user1.id,
      title: "Upcoming Class",
      message: "Advanced Algorithms class starts in 30 minutes",
      type: "INFO",
      category: "SCHEDULE",
      isRead: true,
      readAt: new Date(),
      actionUrl: "/schedule",
      actionLabel: "View Schedule",
    },
  });

  await prisma.notification.create({
    data: {
      userId: user2.id,
      title: "Subscription Renewal",
      message: "Your subscription will renew in 7 days",
      type: "WARNING",
      category: "SUBSCRIPTION",
      isRead: false,
      actionUrl: "/settings/subscription",
      actionLabel: "Manage Subscription",
    },
  });

  console.log(`✅ Created ${3} notifications`);

  // =====================================================
  // 19. ACTIVITY LOGS
  // =====================================================
  console.log("\n📝 Creating activity logs...");

  await prisma.activityLog.create({
    data: {
      userId: user1.id,
      action: "LOGIN",
      entity: "USER",
      entityId: user1.id,
      ipAddress: "192.168.1.100",
      userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    },
  });

  await prisma.activityLog.create({
    data: {
      userId: user1.id,
      action: "CREATE",
      entity: "CAREER",
      entityId: csCareer.id,
      newValues: {
        name: "Computer Science",
        university: "MIT",
      },
      ipAddress: "192.168.1.100",
      userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    },
  });

  await prisma.activityLog.create({
    data: {
      userId: user2.id,
      action: "UPDATE",
      entity: "USER",
      entityId: user2.id,
      oldValues: {
        darkMode: false,
      },
      newValues: {
        darkMode: true,
      },
      ipAddress: "192.168.1.101",
      userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
    },
  });

  console.log(`✅ Created ${3} activity logs`);

  // =====================================================
  // 20. CALENDAR EVENTS
  // =====================================================
  console.log("\n📆 Creating calendar events...");

  await prisma.calendarEvent.create({
    data: {
      userId: user1.id,
      title: "CS201 Final Exam",
      description: "Advanced Algorithms final examination",
      type: "EXAM",
      startDateTime: new Date("2024-12-15T09:00:00"),
      endDateTime: new Date("2024-12-15T12:00:00"),
      isAllDay: false,
      location: "Room 303",
      color: "#EF4444",
      isRecurring: false,
      reminderMinutes: 60,
    },
  });

  await prisma.calendarEvent.create({
    data: {
      userId: user1.id,
      title: "Study Group Session",
      description: "Group study for algorithms",
      type: "STUDY_SESSION",
      startDateTime: new Date("2024-12-10T14:00:00"),
      endDateTime: new Date("2024-12-10T17:00:00"),
      isAllDay: false,
      location: "Library",
      color: "#10B981",
      isRecurring: false,
      reminderMinutes: 30,
    },
  });

  console.log(`✅ Created ${2} calendar events`);

  // =====================================================
  // SUMMARY
  // =====================================================
  console.log("\n\n✨ Database seeding completed successfully!");
  console.log("\n📊 Summary:");
  console.log("   - 2 API clients");
  console.log("   - 3 subscription plans");
  console.log("   - 5 menu items");
  console.log("   - 3 users");
  console.log("   - 2 user preferences");
  console.log("   - 2 subscriptions");
  console.log("   - 2 careers");
  console.log("   - 4 semesters");
  console.log("   - 6 subjects");
  console.log("   - 2 prerequisites");
  console.log("   - 3 academic periods");
  console.log("   - 3 professors");
  console.log("   - 5 enrollments");
  console.log("   - 5 professor assignments");
  console.log("   - 4 grades");
  console.log("   - 3 schedules");
  console.log("   - 2 schedule exceptions");
  console.log("   - 3 notifications");
  console.log("   - 3 activity logs");
  console.log("   - 2 calendar events");
  console.log("\n🔑 Test Credentials:");
  console.log("   Email: john.doe@university.edu");
  console.log("   Email: jane.smith@university.edu");
  console.log("   Email: mike.johnson@university.edu");
  console.log("   Password: password123");
  console.log("\n💡 You can now use these credentials to test the API!");
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error("\n❌ Error seeding database:", e);
    await prisma.$disconnect();
    process.exit(1);
  });
