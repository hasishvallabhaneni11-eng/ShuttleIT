import 'package:latlong2/latlong.dart';

class AppConstants {
  static const String appName = 'ShuttleIT';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Real-time Campus Transit & Digital Passes';

  // Campus Default Coordinates (VIT Vellore)
  static const double vitCenterLat = 12.9692;
  static const double vitCenterLng = 79.1559;
  static const LatLng vitCenter = LatLng(vitCenterLat, vitCenterLng);

  // Shuttle Fare
  static const int shuttleFare = 20; // ₹20 flat rate

  // Key campus landmarks with accurate coordinates
  static const Map<String, LatLng> campusLandmarks = {
    'Main Gate': LatLng(12.9715, 79.1595),
    'Technology Tower (TT)': LatLng(12.9698, 79.1565),
    'Silver Jubilee Tower (SJT)': LatLng(12.9710, 79.1635),
    'Food Mall / Gazebo': LatLng(12.9702, 79.1578),
    'Men\'s Hostel (MH)': LatLng(12.9675, 79.1540),
    'Ladies Hostel (LH)': LatLng(12.9722, 79.1560),
    'Main Building (MB)': LatLng(12.9690, 79.1550),
    'Sports Complex': LatLng(12.9660, 79.1570),
  };

  // Fixed Demo Credentials for rapid testing & evaluation
  static const String demoStudentEmail = 'student@vit.ac.in';
  static const String demoStudentPassword = 'password123';

  // 3 Fixed Bus Driver Credentials
  static const String demoDriver1Email = 'driver01@vit.ac.in'; // Bus 01 - Route 1
  static const String demoDriver1Password = 'password123';

  static const String demoDriver2Email = 'driver02@vit.ac.in'; // Bus 02 - Route 2
  static const String demoDriver2Password = 'password123';

  static const String demoDriver3Email = 'driver03@vit.ac.in'; // Bus 03 - Route 3
  static const String demoDriver3Password = 'password123';

  // Backward compatibility alias
  static const String demoDriverEmail = demoDriver1Email;
  static const String demoDriverPassword = demoDriver1Password;

  // 1 Fixed Admin Credential
  static const String demoAdminEmail = 'admin@vit.ac.in';
  static const String demoAdminPassword = 'password123';
}


