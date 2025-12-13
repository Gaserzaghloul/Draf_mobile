import 'package:flutter_test/flutter_test.dart';
import 'package:beacon_app/models/connected_device.dart';

void main() {
  group('ConnectedDevice Model Tests', () {
    // Ensures a local device object can be instantiated properly
    test('should create ConnectedDevice instance correctly', () {
      final device = ConnectedDevice(
        id: 'dev1',
        name: 'Pixel 6',
        deviceId: 'mac_address_1',
        signalStrength: -50,
        lastSeen: DateTime.now(),
        isConnected: true,
      );

      expect(device.id, 'dev1');
      expect(device.name, 'Pixel 6');
      expect(device.isConnected, true);
    });

    // Check JSON serialization logic (crucial for local storage persistence)
    test('should convert to Map and back', () {
      final timestamp = DateTime.now();
      final device = ConnectedDevice(
        id: 'dev2',
        name: 'iPhone 13',
        deviceId: 'mac_address_2',
        signalStrength: -70,
        lastSeen: timestamp,
        isConnected: false, // Disconnected device
        ipAddress: '192.168.49.1',
      );

      final map = device.toMap();
      expect(map['id'], 'dev2');
      expect(
        map['isConnected'],
        0,
      ); // Boolean should save as Int (0/1) for SQLite
      expect(map['ipAddress'], '192.168.49.1');

      final newDevice = ConnectedDevice.fromMap(map);
      expect(newDevice.id, device.id);
      expect(newDevice.isConnected, false);
      expect(newDevice.lastSeen.toIso8601String(), timestamp.toIso8601String());
    });

    // Test updating device state (e.g., refreshing 'lastSeen' or 'isConnected')
    test('should copyWith updated fields', () {
      final device = ConnectedDevice(
        id: 'dev3',
        name: 'Samsung S21',
        deviceId: 'mac_address_3',
        signalStrength: -60,
        lastSeen: DateTime.now(),
        isConnected: false,
      );

      // Simulate re-connecting
      final updated = device.copyWith(
        isConnected: true,
        lastSeen: DateTime.now().add(const Duration(minutes: 1)),
      );

      expect(updated.id, 'dev3');
      expect(updated.isConnected, true); // Changed
      expect(updated.name, 'Samsung S21'); // Unchanged
    });
  });
}
