class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? sex; // 'Male' or 'Female'
  final String? address;
  final String? emergencyPhone1;
  final String? emergencyPhone2;
  final String? bloodType; // e.g., 'A+', 'O-', etc.
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isProfileComplete; // Track if user has completed their profile

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.sex,
    this.address,
    this.emergencyPhone1,
    this.emergencyPhone2,
    this.bloodType,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isProfileComplete = false, // Default to false for new users
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'sex': sex,
      'address': address,
      'emergency_phone1': emergencyPhone1,
      'emergency_phone2': emergencyPhone2,
      'blood_type': bloodType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'isProfileComplete': isProfileComplete ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
      sex: map['sex'],
      address: map['address'],
      emergencyPhone1: map['emergency_phone1'],
      emergencyPhone2: map['emergency_phone2'],
      bloodType: map['blood_type'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isActive: map['isActive'] == 1,
      isProfileComplete: map['isProfileComplete'] == 1,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? sex,
    String? address,
    String? emergencyPhone1,
    String? emergencyPhone2,
    String? bloodType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isProfileComplete,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      sex: sex ?? this.sex,
      address: address ?? this.address,
      emergencyPhone1: emergencyPhone1 ?? this.emergencyPhone1,
      emergencyPhone2: emergencyPhone2 ?? this.emergencyPhone2,
      bloodType: bloodType ?? this.bloodType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
