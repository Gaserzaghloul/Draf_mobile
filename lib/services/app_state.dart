import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/connected_device.dart';
import '../models/message.dart';
import '../models/resource.dart';
import '../models/activity.dart';
import '../database/database_service.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  List<ConnectedDevice> _connectedDevices = [];
  List<Message> _messages = [];
  List<Resource> _resources = [];
  List<Activity> _activities = [];
  bool _isConnected = false;
  bool _isDiscovering = false;
  bool _isAdvertising = false;

  // Getters
  User? get currentUser => _currentUser;
  List<ConnectedDevice> get connectedDevices => _connectedDevices;
  List<Message> get messages => _messages;
  List<Resource> get resources => _resources;
  List<Activity> get activities => _activities;
  bool get isConnected => _isConnected;
  bool get isDiscovering => _isDiscovering;
  bool get isAdvertising => _isAdvertising;

  // User management
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> createUser(String name, String email) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await DatabaseService.insertUser(user);
    _currentUser = user;
    
    // Add activity
    await _addActivity(
      ActivityType.profileUpdated,
      'User profile created',
    );
    
    notifyListeners();
  }

  // Device management
  void addConnectedDevice(ConnectedDevice device) {
    _connectedDevices.add(device);
    _isConnected = _connectedDevices.isNotEmpty;
    notifyListeners();
  }

  void removeConnectedDevice(String deviceId) {
    _connectedDevices.removeWhere((device) => device.deviceId == deviceId);
    _isConnected = _connectedDevices.isNotEmpty;
    notifyListeners();
  }

  void updateConnectedDevice(ConnectedDevice updatedDevice) {
    final index = _connectedDevices.indexWhere(
      (device) => device.deviceId == updatedDevice.deviceId,
    );
    if (index != -1) {
      _connectedDevices[index] = updatedDevice;
      notifyListeners();
    }
  }

  // Message management
  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void updateMessage(Message updatedMessage) {
    final index = _messages.indexWhere(
      (message) => message.id == updatedMessage.id,
    );
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  List<Message> getMessagesForUser(String userId) {
    return _messages.where((message) => 
      message.senderId == userId || message.receiverId == userId
    ).toList();
  }

  // Resource management
  void addResource(Resource resource) {
    _resources.add(resource);
    notifyListeners();
  }

  void updateResource(Resource updatedResource) {
    final index = _resources.indexWhere(
      (resource) => resource.id == updatedResource.id,
    );
    if (index != -1) {
      _resources[index] = updatedResource;
      notifyListeners();
    }
  }

  void removeResource(String resourceId) {
    _resources.removeWhere((resource) => resource.id == resourceId);
    notifyListeners();
  }

  // Activity management
  Future<void> _addActivity(ActivityType type, String description, {Map<String, dynamic>? metadata}) async {
    if (_currentUser == null) return;
    
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.id,
      type: type,
      description: description,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
    
    await DatabaseService.insertActivity(activity);
    _activities.insert(0, activity); // Add to beginning
    
    // Keep only last 100 activities
    if (_activities.length > 100) {
      _activities = _activities.take(100).toList();
    }
    
    notifyListeners();
  }

  // Network operations
  void setDiscovering(bool discovering) {
    _isDiscovering = discovering;
    notifyListeners();
  }

  void setAdvertising(bool advertising) {
    _isAdvertising = advertising;
    notifyListeners();
  }

  void setConnected(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  // Data loading
  Future<void> loadUserData() async {
    if (_currentUser == null) return;
    
    try {
      // Load messages
      final messages = await DatabaseService.getAllMessages();
      _messages = messages;
      
      // Load resources
      final resources = await DatabaseService.getAllResources();
      _resources = resources;
      
      // Load activities
      final activities = await DatabaseService.getActivitiesForUser(_currentUser!.id);
      _activities = activities;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> loadConnectedDevices() async {
    try {
      final devices = await DatabaseService.getAllConnectedDevices();
      _connectedDevices = devices;
      _isConnected = devices.isNotEmpty;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading connected devices: $e');
    }
  }

  // Utility methods
  void clearAllData() {
    _currentUser = null;
    _connectedDevices.clear();
    _messages.clear();
    _resources.clear();
    _activities.clear();
    _isConnected = false;
    _isDiscovering = false;
    _isAdvertising = false;
    notifyListeners();
  }

  // Statistics
  int get totalMessages => _messages.length;
  int get totalResources => _resources.length;
  int get totalDevices => _connectedDevices.length;
  int get onlineDevices => _connectedDevices.where((d) => d.isConnected).length;

  // Search functionality
  List<Message> searchMessages(String query) {
    if (query.isEmpty) return _messages;
    
    return _messages.where((message) =>
      message.content.toLowerCase().contains(query.toLowerCase()) ||
      message.senderId.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<Resource> searchResources(String query) {
    if (query.isEmpty) return _resources;
    
    return _resources.where((resource) =>
      resource.name.toLowerCase().contains(query.toLowerCase()) ||
      resource.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<ConnectedDevice> searchDevices(String query) {
    if (query.isEmpty) return _connectedDevices;
    
    return _connectedDevices.where((device) =>
      device.name.toLowerCase().contains(query.toLowerCase()) ||
      device.deviceId.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
