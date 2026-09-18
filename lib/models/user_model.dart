enum UserRole { student, driver, admin }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? regNumber;
  final String? driverId;
  final String? assignedBusId;
  final String? phone;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.regNumber,
    this.driverId,
    this.assignedBusId,
    this.phone,
  });

  bool get isStudent => role == UserRole.student;
  bool get isDriver => role == UserRole.driver;
  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'regNumber': regNumber,
      'driverId': driverId,
      'assignedBusId': assignedBusId,
      'phone': phone,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, {String? uid}) {
    return AppUser(
      uid: uid ?? map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.student,
      ),
      regNumber: map['regNumber'],
      driverId: map['driverId'],
      assignedBusId: map['assignedBusId'],
      phone: map['phone'],
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? regNumber,
    String? driverId,
    String? assignedBusId,
    String? phone,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      regNumber: regNumber ?? this.regNumber,
      driverId: driverId ?? this.driverId,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      phone: phone ?? this.phone,
    );
  }
}

