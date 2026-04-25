import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConfig {
  // Local development IP address (for mobile debugging only)
  static const String _mobileIpAddress = '10.0.2.2';
  
  // Production URL - Your actual Render deployment
  static const String _productionUrl = 'https://vari-backend.onrender.com/api';
  
  static String get baseUrl {
    // Always use production URL for both web and mobile
    // This ensures everyone connects to the same database
    return _productionUrl;
  }
  
  // Central error logging
  static void logError(String endpoint, Object error) {
    // Always log errors for debugging, even in production
    print("API ERROR at [$endpoint]: $error");
  }
}