import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConfig {
  // Local development IP address
  static const String _mobileIpAddress = '10.0.2.2';
  
  // Production URL (replace with your actual Render URL once deployed)
  static const String _productionUrl = 'https://your-render-url.onrender.com/api';
  
  static String get baseUrl {
    // Use production URL in release mode, local in debug
    if (kReleaseMode) {
      return _productionUrl;
    }
    
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    return 'http://$_mobileIpAddress:8080/api';
  }
  
  // Central error logging
  static void logError(String endpoint, Object error) {
    // Always log errors for debugging, even in production
    print("API ERROR at [$endpoint]: $error");
  }
}