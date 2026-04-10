import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // 🛑 CHANGE THIS IP ADDRESS IF YOUR WI-FI/HOTSPOT CHANGES!
  static const String _mobileIpAddress = '10.0.2.2';
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    return 'http://$_mobileIpAddress:8080/api';
  }
  
  // A central place to handle network errors in the future
  static void logError(String endpoint, Object error) {
    print("🚨 API ERROR at [$endpoint]: $error");
  }
}