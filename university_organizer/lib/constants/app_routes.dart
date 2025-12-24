/// Application routes
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String preferences = '/preferences';

  // Career Routes
  static const String careers = '/careers';
  static const String careerDetail = '/careers/:id';
  static const String addCareer = '/careers/add';
  static const String editCareer = '/careers/:id/edit';

  // Subject Routes
  static const String subjects = '/subjects';
  static const String subjectDetail = '/subjects/:id';
  static const String addSubject = '/subjects/add';
  static const String editSubject = '/subjects/:id/edit';

  // Grade Routes
  static const String grades = '/grades';
  static const String gradeDetail = '/grades/:id';
  static const String addGrade = '/grades/add';

  // Schedule Routes
  static const String schedule = '/schedule';
  static const String addSchedule = '/schedule/add';
  static const String editSchedule = '/schedule/:id/edit';

  // Professor Routes
  static const String professors = '/professors';
  static const String professorDetail = '/professors/:id';
  static const String addProfessor = '/professors/add';

  // Notification Routes
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notifications/:id';

  // Analytics Routes
  static const String analytics = '/analytics';
  static const String gradeAnalytics = '/analytics/grades';
  static const String performanceAnalytics = '/analytics/performance';

  // Subscription Routes
  static const String subscription = '/subscription';
  static const String plans = '/subscription/plans';
  static const String payment = '/subscription/payment';

  // Calendar Routes
  static const String calendar = '/calendar';
  static const String addEvent = '/calendar/add';

  // Settings Routes
  static const String settings = '/settings';
  static const String about = '/settings/about';
  static const String help = '/settings/help';
}
