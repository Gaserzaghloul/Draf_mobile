import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/activity.dart';
import '../database/database_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isProfileComplete => _currentUser?.isProfileComplete ?? false;

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> createUser(
    String name,
    String email, {
    bool isProfileComplete = false,
  }) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isProfileComplete: isProfileComplete,
    );

    await DatabaseService.insertUser(user);
    _currentUser = user;

    // Log activity
    await _addActivity(ActivityType.profileUpdated, 'User profile created');

    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    await DatabaseService.updateUser(updatedUser);
    _currentUser = updatedUser;

    // Log activity
    await _addActivity(ActivityType.profileUpdated, 'User profile updated');

    notifyListeners();
  }

  Future<void> loadUserData() async {
    if (_currentUser == null) return;
    // Reload user from DB to ensure fresh state
    final user = await DatabaseService.getUser(_currentUser!.id);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  // Helper to log activities related to user actions
  Future<void> _addActivity(ActivityType type, String description) async {
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
