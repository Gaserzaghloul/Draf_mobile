import 'package:flutter_test/flutter_test.dart';
import 'package:beacon_app/models/resource.dart';

void main() {
  group('Resource Model Tests', () {
    // Basic sanity check to ensure object creation works
    test('should create Resource instance correctly', () {
      final resource = Resource(
        id: 'res1',
        name: 'Bandages',
        description: 'First aid kit',
        type: ResourceType.other,
        filePath: '/path/to/file',
        fileName: 'bandages.jpg',
        fileSize: 1024,
        ownerId: 'user1',
        createdAt: DateTime.now(),
        requestType: ResourceRequestType.request,
      );

      expect(resource.id, 'res1');
      expect(resource.name, 'Bandages');
      expect(resource.requestType, ResourceRequestType.request);
    });

    // Verify that we can save to DB (Map) and load it back correctly
    test('should convert to Map and back', () {
      final timestamp = DateTime.now();
      final resource = Resource(
        id: 'res2',
        name: 'Water',
        description: 'Bottled water',
        type: ResourceType.other,
        filePath: '',
        fileName: '',
        fileSize: 0,
        ownerId: 'user2',
        createdAt: timestamp,
        status: ResourceStatus.available,
        requestType: ResourceRequestType.provide,
        ownerName: 'Donor',
      );

      // Convert to Map
      final map = resource.toMap();
      expect(map['id'], 'res2');
      expect(map['requestType'], 'provide'); // Enum conversion check

      // Convert back to Object
      final newResource = Resource.fromMap(map);
      expect(newResource.id, resource.id);
      expect(newResource.name, resource.name);
      expect(newResource.requestType, resource.requestType);
    });

    // Test immutability helpers used for updating UI/State
    test('should copyWith updated fields', () {
      final resource = Resource(
        id: 'res3',
        name: 'Tent',
        description: 'Two person tent',
        type: ResourceType.other,
        filePath: '',
        fileName: '',
        fileSize: 0,
        ownerId: 'user1',
        createdAt: DateTime.now(),
      );

      // Simulate updating the status after a download
      final updated = resource.copyWith(
        status: ResourceStatus.downloaded,
        filePath: '/new/path',
      );

      expect(updated.id, 'res3');
      expect(updated.status, ResourceStatus.downloaded); // Changed
      expect(updated.filePath, '/new/path'); // Changed
      expect(updated.name, 'Tent'); // Unchanged
    });
  });
}
