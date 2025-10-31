import 'app_config.dart';

/// API Configuration
/// 
/// จัดการ API endpoints และ headers
class ApiConfig {
  /// Get base URL from AppConfig
  static String get baseUrl => AppConfig.baseUrl;
  
  // ==========================================================================
  // API ENDPOINTS
  // ==========================================================================
  
  static String get loginEndpoint => '$baseUrl/auth/login.php';
  static String get logoutEndpoint => '$baseUrl/auth/logout.php';
  static String get verifyTokenEndpoint => '$baseUrl/auth/verify_token.php';
  static String get profileEndpoint => '$baseUrl/auth/profile.php';
  
  // Checkpoints
  static String get checkpointsEndpoint => '$baseUrl/checkpoints/list.php';
  static String get checkpointDetailEndpoint => '$baseUrl/checkpoints/detail.php';
  
  // Sessions
  static String get sessionsEndpoint => '$baseUrl/sessions/list.php';
  static String get activeSessionEndpoint => '$baseUrl/sessions/active.php';
  static String get createSessionEndpoint => '$baseUrl/sessions/create.php';
  static String get completeSessionEndpoint => '$baseUrl/sessions/complete.php';
  
  // Events
  static String get eventsEndpoint => '$baseUrl/events/list.php';
  static String get createEventEndpoint => '$baseUrl/events/create.php';
  
  // ==========================================================================
  // TIMEOUTS
  // ==========================================================================
  
  static Duration get connectTimeout => 
      Duration(milliseconds: AppConfig.connectionTimeout);
  
  static Duration get receiveTimeout => 
      Duration(milliseconds: AppConfig.receiveTimeout);
  
  // ==========================================================================
  // HEADERS
  // ==========================================================================
  
  /// Get HTTP headers
  /// 
  /// [token] - Optional JWT token for authentication
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}