import 'package:flutter_test/flutter_test.dart';
import 'package:beacon_app/models/activity.dart';

void main() {
  group('Activity Model Tests', () {
    // Basic test to verify the Activity log model structure
    test('should create Activity instance correctly', () {
      final activity = Activity(
        id: 'act1',
        userId: 'user1',
        type: ActivityType.deviceConnected,
        description: 'Connected to device A',
        timestamp: DateTime.now(),
      );

      expect(activity.id, 'act1');
      expect(activity.type, ActivityType.deviceConnected);
      expect(activity.description, 'Connected to device A');
    });

    // Verification of JSON conversion for DB logging (including complex types)
    test('should convert to Map and back with metadata', () {
      final timestamp = DateTime.now();
      final metadata = {'deviceId': 'dev_123', 'signal': 85};

      final activity = Activity(
        id: 'act2',
        userId: 'user2',
        type: ActivityType.sosAlert,
        description: 'Sent SOS',
        timestamp: timestamp,
        metadata: metadata,
      );

      // Serialize
      final map = activity.toMap();
      expect(map['id'], 'act2');
      expect(map['type'], 'sosAlert'); // Enum as string
      expect(map['metadata'], isA<String>()); // Persisted as JSON String

      // Deserialize
      final newActivity = Activity.fromMap(map);
      expect(newActivity.id, activity.id);
      expect(newActivity.type, activity.type);
      expect(newActivity.metadata, isNotNull);
      expect(newActivity.metadata!['deviceId'], 'dev_123');
      expect(newActivity.metadata!['signal'], 85);
    });

    // Ensure we can update an activity entry if needed (e.g. appending info)
    test('should copyWith updated fields', () {
      final activity = Activity(
        id: 'act3',
        userId: 'user1',
        type: ActivityType.messageSent,
        description: 'Sent msg',
        timestamp: DateTime.now(),
      );

      final updated = activity.copyWith(description: 'Updated msg description');

      expect(updated.id, 'act3');
      expect(updated.description, 'Updated msg description');
    });
  });
}
