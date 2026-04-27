import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Local development IP address (for development only)
  static const String _mobileIpAddress = '10.0.2.2';
  
  // Production URL - Will be updated after Railway deployment
  static const String _productionUrl = 'https://your-railway-app.railway.app/api';
  
  static String get baseUrl {
    // For development, use localhost
    // For production APK, use Railway URL
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    
    // TODO: Change this to true when building production APK
    bool useProduction = false;
    
    if (useProduction) {
      return _productionUrl;
    } else {
      return 'http://$_mobileIpAddress:8080/api';
    }
  }
  
  // Central error logging
  static void logError(String endpoint, Object error) {
    print("🚨 API ERROR at [$endpoint]: $error");
  }
}