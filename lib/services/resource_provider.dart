import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/resource.dart';
import '../models/user.dart';

import '../models/activity.dart';
import '../database/database_service.dart';
import 'network_provider.dart';
import 'message_provider.dart';

class ResourceProvider extends ChangeNotifier {
  final NetworkProvider _networkProvider;
  final MessageProvider _messageProvider;

  final List<Resource> _resources = [];
  final List<Resource> _incomingResourceRequests = [];
  User? _currentUser;

  List<Resource> get resources => _resources;
  List<Resource> get incomingResourceRequests => _incomingResourceRequests;
  int get incomingResourceRequestsCount => _incomingResourceRequests.length;

  ResourceProvider(this._networkProvider, this._messageProvider) {
    _networkProvider.onResourceRequestReceived = _handleResourceRequest;
    _networkProvider.onResourceFulfilledReceived = _handleResourceFulfilled;
    loadResources();
  }

  Future<void> loadResources() async {
    _resources.clear();
    final saved = await DatabaseService.getAllResources();
    debugPrint('ResourceProvider: Loaded ${saved.length} resources from DB');
    _resources.addAll(saved);
    // Filter incoming requests requiring fulfillment.
    if (_currentUser != null) {
      _incomingResourceRequests.clear();
      _incomingResourceRequests.addAll(
        _resources.where(
          (r) =>
              r.requestType == ResourceRequestType.request &&
              r.ownerId != _currentUser!.id,
        ),
      );
    }
    notifyListeners();
  }

  void updateUser(User? user) {
    _currentUser = user;
    if (_currentUser != null && _resources.isNotEmpty) {
      // Update incoming requests for new user identity.
      _incomingResourceRequests.clear();
      _incomingResourceRequests.addAll(
        _resources.where(
          (r) =>
              r.requestType == ResourceRequestType.request &&
              r.ownerId != _currentUser!.id,
        ),
      );
      notifyListeners();
    }
  }

  void addResource(Resource resource) {
    _resources.add(resource);
    DatabaseService.insertResource(resource);
    notifyListeners();
  }

  void updateResource(Resource updatedResource) {
    final index = _resources.indexWhere((r) => r.id == updatedResource.id);
    if (index != -1) {
      _resources[index] = updatedResource;
      DatabaseService.updateResource(updatedResource);
      notifyListeners();
    }
  }

  void removeResource(String resourceId) {
    _resources.removeWhere((r) => r.id == resourceId);
    notifyListeners();
  }

  // Send provision message to requester
  void sendProvisionMessage(String requesterId, String messageContent) {
    if (_currentUser == null) return;

    // Add to local message list via provider
    _messageProvider.sendMessage(
      // This sends over network AND adds locally
      content: messageContent,
      receiverId: requesterId,
    );

    _logActivity(
      ActivityType.resourceShared,
      'Resource provision message sent: $messageContent',
    );
  }

  Future<bool> broadcastResourceRequest(Resource resource) async {
    try {
      final resourceMap = resource.toMap();
      final jsonMessage = jsonEncode({
        'type': 'resource_request',
        'resource': resourceMap,
      });

      // Attempt 1
      bool sent = await _networkProvider.p2pService.sendMessage(jsonMessage);

      // Retry briefly on failure.
      if (!sent) {
        final delays = [200, 500, 1000]; // ms
        for (int i = 0; i < 3; i++) {
          await Future.delayed(Duration(milliseconds: delays[i]));
          debugPrint(
            'ResourceProvider: Retrying broadcast attempt ${i + 2} (Fast Mode)...',
          );
          sent = await _networkProvider.p2pService.sendMessage(jsonMessage);
          if (sent) break;
        }
      }

      if (sent) {
        _logActivity(
          ActivityType.resourceShared,
          'Broadcasted resource request: ${resource.name}',
        );
      }
      return sent;
    } catch (e) {
      return false;
    }
  }

  Future<bool> broadcastResourceFulfilled(
    String requestId,
    String filePath,
  ) async {
    try {
      final sender = _currentUser?.id ?? 'unknown';
      final senderName = _currentUser?.name ?? 'Unknown User';
      final jsonMessage = jsonEncode({
        'type': 'resource_fulfilled',
        'requestId': requestId,
        'filePath': filePath,
        'sender': sender,
        'senderName': senderName,
      });

      final sent = await _networkProvider.p2pService.sendMessage(jsonMessage);

      if (sent) {
        debugPrint('ResourceProvider: Broadcasted fulfillment: $requestId');
        _logActivity(
          ActivityType.resourceShared,
          'Broadcasted resource fulfillment: $requestId',
        );
      }
      return sent;
    } catch (e) {
      return false;
    }
  }

  // Handlers
  void _handleResourceRequest(dynamic resourceData) {
    if (_currentUser == null) {
      debugPrint(
        'ResourceProvider: _handleResourceRequest ignored - No currentUser',
      );
      return;
    }

    final resource = resourceData as Resource;
    debugPrint(
      'ResourceProvider: Handling incoming request: ${resource.name} from ${resource.ownerName} (${resource.ownerId})',
    );

    // Ignore requests from self.
    if (resource.ownerId == _currentUser!.id) {
      return;
    }

    final exists = _incomingResourceRequests.any((r) => r.id == resource.id);
    if (!exists) {
      addResource(resource);
      notifyListeners();
    } else {
      debugPrint('ResourceProvider: Request already exists in list.');
    }
  }

  void _handleResourceFulfilled(
    String requestId,
    String filePath,
    String sender,
    String? senderName,
  ) {
    final resourceIndex = _resources.indexWhere((r) => r.id == requestId);
    if (resourceIndex >= 0) {
      final resource = _resources[resourceIndex];
      final updatedResource = resource.copyWith(
        filePath: filePath,
        providedBy: sender,
        providedByName: senderName ?? 'Unknown User',
      );
      updateResource(updatedResource);

      _incomingResourceRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    }
  }

  Future<void> _logActivity(ActivityType type, String description) async {
    if (_currentUser == null) return;
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.id,
      type: type,
      description: description,
      timestamp: DateTime.now(),
    );
    await DatabaseService.insertActivity(activity);
  }
}
