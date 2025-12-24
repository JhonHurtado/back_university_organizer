/// Application-wide constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // API Configuration
  static const String apiBaseUrl = 'http://192.168.101.12:3030/api/v1';
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String careersEndpoint = '/careers';
  static const String academicEndpoint = '/academic';
  static const String gradesEndpoint = '/grades';
  static const String schedulesEndpoint = '/schedules';
  static const String notificationsEndpoint = '/notifications';
  static const String preferencesEndpoint = '/preferences';
  static const String professorsEndpoint = '/professors';
  static const String subscriptionsEndpoint = '/subscriptions';
  static const String paymentsEndpoint = '/payments';
  static const String menusEndpoint = '/menus';
  static const String analyticsEndpoint = '/analytics';
  static const String activityLogsEndpoint = '/activity-logs';
  static const String verificationEndpoint = '/verification';

  // App Configuration
  static const String appName = 'University Organizer';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // OAuth Credentials (from backend)
  static const String oauthClientId = '1452e028caeb55f306bfe3d4c6a9591d';
  static const String oauthClientSecret = '12b11ad59ed8dd818235639134944afa056157f499b56d7f8da557a256289088';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Grade Scales
  static const Map<String, Map<String, dynamic>> gradeScales = {
    'FIVE': {
      'min': 0.0,
      'max': 5.0,
      'passing': 3.0,
      'name': 'Escala 0-5',
    },
    'TEN': {
      'min': 0.0,
      'max': 10.0,
      'passing': 6.0,
      'name': 'Escala 0-10',
    },
    'HUNDRED': {
      'min': 0.0,
      'max': 100.0,
      'passing': 60.0,
      'name': 'Escala 0-100',
    },
    'FOUR_GPA': {
      'min': 0.0,
      'max': 4.0,
      'passing': 2.0,
      'name': 'GPA 0-4',
    },
    'SEVEN': {
      'min': 1.0,
      'max': 7.0,
      'passing': 4.0,
      'name': 'Escala 1-7',
    },
  };

  // Days of week
  static const Map<int, String> daysOfWeek = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
}
