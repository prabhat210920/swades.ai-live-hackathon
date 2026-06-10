class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl =
      'https://swades-ai-live-hackathon.onrender.com';

  // Secure storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userPhoneKey = 'user_phone';

  // API endpoints
  static const String registerEndpoint = '/auth/register/';
  static const String loginEndpoint = '/auth/login/';
  static const String tokenRefreshEndpoint = '/auth/token/refresh/';
  static const String venuesEndpoint = '/venues/';
  static const String bookingsEndpoint = '/bookings/';

  // Network
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
