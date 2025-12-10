import 'package:flutter_test/flutter_test.dart';
import 'package:beacon_app/models/user.dart';

void main() {
  group('User Model Tests', () {
    // Verifies that the app correctly converts user data to a database-friendly Map format
    test('User toMap returns correct map', () {
      final user = User(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        emergencyPhone1: '1234567890',
        bloodType: 'O+',
      );

      final map = user.toMap();

      // Check fields individually to be sure
      expect(map['id'], '123');
      expect(map['name'], 'Test User');
      expect(map['email'], 'test@example.com');
      expect(map['emergency_phone1'], '1234567890');
      expect(map['blood_type'], 'O+');
    });

    // Verifies that we can correctly rebuild a User object from database data
    test('User fromMap creates correct user', () {
      final map = {
        'id': '456',
        'name': 'Another User',
        'email': 'another@example.com',
        'createdAt': DateTime(2025, 2, 2).toIso8601String(),
        'updatedAt': DateTime(2025, 2, 2).toIso8601String(),
        'emergency_phone1': '9876543210',
        'blood_type': 'A-',
        'isActive': 1,
        'isProfileComplete': 1,
      };

      final user = User.fromMap(map);

      // Sanity check the reconstructed object
      expect(user.id, '456');
      expect(user.name, 'Another User');
      expect(user.email, 'another@example.com');
      expect(user.emergencyPhone1, '9876543210');
      expect(user.bloodType, 'A-');
    });
  });
}
