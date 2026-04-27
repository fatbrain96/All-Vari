import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Local development IP address (for development only)
  static const String _mobileIpAddress = '10.0.2.2';
  
  // Production URL - Your live Render backend
  static const String _productionUrl = 'https://vari-backend.onrender.com/api';
  
  static String get baseUrl {
    // For web admin panel, always use production
    if (kIsWeb) {
      return _productionUrl;
    }
    
    // For mobile APK, use production (change this to false for local development)
    bool useProduction = true;
    
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