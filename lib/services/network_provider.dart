import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/connected_device.dart';
import '../models/user.dart';
import '../models/activity.dart';
import '../database/database_service.dart';
import 'p2p_service.dart';

class NetworkProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Services
  final P2PService _p2pService = P2PService();

  // State
  final List<ConnectedDevice> _connectedDevices = [];
  bool _isConnected = false;
  bool _isDiscovering = false;
  bool _isAdvertising = false;
  User? _currentUser; // Updated via setter/method from UserProvider

  // Getters
  List<ConnectedDevice> get connectedDevices => _connectedDevices;
  bool get isConnected => _isConnected;
  bool get isDiscovering => _isDiscovering;
  bool get isAdvertising => _isAdvertising;
  P2PService get p2pService => _p2pService;

  // External Callbacks (to be set by MessageProvider/ResourceProvider)
  Function(String)? onMessageReceived;
  Function(dynamic)? onResourceRequestReceived;
  Function(String, String, String, String?)? onResourceFulfilledReceived;

  NetworkProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _p2pService.dispose();
    super.dispose();
  }

  // Update current user (called by ProxyProvider in main.dart)
  void updateUser(User? user) {
    _currentUser = user;
    // Potentially broadcast status update if user changed while connected?
    // For now just storing it.
  }

  // Lifecycle Management
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_currentUser == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App backgrounded - broadcast offline

      _broadcastDeviceStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      // App foregrounded - broadcast online
      _broadcastDeviceStatus(true);
    }
  }

  void _broadcastDeviceStatus(bool isOnline) {
    if (_currentUser == null) return;

    final statusMessage = jsonEncode({
      'type': 'device_status',
      'deviceId': _currentUser!.id,
      'deviceName': _currentUser!.name,
      'isOnline': isOnline,
    });

    _p2pService.sendMessage(statusMessage).catchError((e) {
      debugPrint('NetworkProvider: Error broadcasting device status: $e');
      return false;
    });
  }

  // Initialization
  Future<bool> initializeP2P() async {
    try {
      _p2pService.onDevicesDiscovered = _updateDiscoveredDevices;
      _p2pService.onMessageReceived = _handleIncomingMessage;
      _p2pService.onConnectionStatusChanged = _handleConnectionStatus;
      _p2pService.onScanTimeout = _handleScanTimeout;

      // Pass resource events up (to be handled by ResourceProvider via callback)
      _p2pService.onResourceRequestReceived = (resource) {
        onResourceRequestReceived?.call(resource);
      };

      _p2pService.onResourceFulfilledReceived =
          (requestId, filePath, sender, senderName) {
            onResourceFulfilledReceived?.call(
              requestId,
              filePath,
              sender,
              senderName,
            );
          };

      _p2pService.onDeviceStatusChanged = _handleDeviceStatusChanged;

      return await _p2pService.initialize();
    } catch (e) {
      debugPrint('NetworkProvider: P2P initialization error: $e');
      return false;
    }
  }

  // Network Actions
  Future<bool> startNewNetwork() async {
    if (_currentUser == null) {
      return false;
    }

    try {
      _connectedDevices.clear();

      if (!_p2pService.isInitialized) {
        if (!await initializeP2P()) return false;
      }

      final advertisingStarted = await _p2pService.startAdvertising(
        deviceName: _currentUser!.name,
      );

      if (advertisingStarted) {
        _isAdvertising = true;
        _isDiscovering = false;
        _isConnected = true;

        await _logActivity(
          ActivityType.deviceConnected,
          'Started new P2P network',
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('NetworkProvider: Start network error: $e');
      return false;
    }
  }

  Future<bool> joinExistingNetwork() async {
    try {
      // Note: Only clear devices if we're NOT already connected.
      // This prevents losing connection state during rejoin/refresh.
      if (!_isConnected && _connectedDevices.every((d) => !d.isConnected)) {
        _connectedDevices.clear();
      }

      if (!_p2pService.isInitialized) {
        if (!await initializeP2P()) return false;
      }

      final scanningStarted = await _p2pService.startScanning();

      if (scanningStarted) {
        _isDiscovering = true;
        await _logActivity(
          ActivityType.deviceConnected,
          'Joined existing P2P network',
        );
        notifyListeners();

        // Timeout fallback
        Future.delayed(const Duration(seconds: 30), () {
          if (_isDiscovering && _connectedDevices.isEmpty) {
            _isDiscovering = false;
            notifyListeners();
          }
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('NetworkProvider: Join network error: $e');
      return false;
    }
  }

  Future<void> stopNetwork() async {
    await _p2pService.stopScanning();
    await _p2pService.stopAdvertising();
    _isDiscovering = false;
    _isAdvertising = false;
    _isConnected = false;

    await _logActivity(ActivityType.deviceDisconnected, 'Stopped P2P network');
    notifyListeners();
  }

  // Refresh devices while preserving state.
  Future<void> refreshDevices() async {
    try {
      if (_isAdvertising) {
        // Host mode: Just refresh UI state, don't restart advertising
        notifyListeners();
        await _logActivity(
          ActivityType.deviceConnected,
          'Refreshed network state (Host mode)',
        );
      } else if (_p2pService.isInitialized) {
        // Client mode: Re-scan without breaking existing connections

        // Don't clear connected devices - joinExistingNetwork now handles this
        await joinExistingNetwork();

        await _logActivity(
          ActivityType.deviceConnected,
          'Refreshed device list (Client mode)',
        );
      } else {
        // Not initialized yet, do nothing
        // Not initialized yet, do nothing
      }
    } catch (e) {
      debugPrint('NetworkProvider: Refresh error: $e');
    }
  }

  Future<bool> connectToDevice(ConnectedDevice device) async {
    try {
      final connected = await _p2pService.connectToDevice(device.deviceId);
      if (connected) {
        final updatedDevice = device.copyWith(
          isConnected: true,
          lastSeen: DateTime.now(),
        );
        _updateConnectedDeviceInList(updatedDevice);
        _isConnected = true;

        await _logActivity(
          ActivityType.deviceConnected,
          'Connected to device: ${device.name}',
        );
        notifyListeners();
      }
      return connected;
    } catch (e) {
      debugPrint('NetworkProvider: Connect error: $e');
      return false;
    }
  }

  Future<void> disconnectFromDevice(ConnectedDevice device) async {
    await _p2pService.disconnectFromDevice(device);
    final updatedDevice = device.copyWith(
      isConnected: false,
      lastSeen: DateTime.now(),
    );
    _updateConnectedDeviceInList(updatedDevice);

    _isConnected = _connectedDevices.any((d) => d.isConnected);
    await _logActivity(
      ActivityType.deviceDisconnected,
      'Disconnected from device: ${device.name}',
    );
    notifyListeners();
  }

  // Internal Handlers
  void _updateDiscoveredDevices(List<ConnectedDevice> devices) {
    // In Host mode, this list is authoritative (current connected clients).
    // If it's empty, it means everyone disconnected. We must NOT return early.
    // In Client mode (Scanning), it's additive/discovery, so empty list might just mean "no new devices this scan".

    if (_isAdvertising) {
      // HOST MODE: Synchronize list (The incoming 'devices' IS the list of connected clients)
      // 1. Mark existing devices as disconnected if they are not in the new list
      //    (Or just replace the list, but we want to keep some metadata if possible?
      //     Actually for P2P Host, if they aren't in the list, they are GONE.)

      // Better approach for Host: Replace the list but preserve "Known" devices if we want?
      // For now, per user request "disappear from host screen", let's clear those not present.

      final newDeviceIds = devices.map((d) => d.deviceId).toSet();

      // Remove devices that are no longer in the list
      _connectedDevices.removeWhere((d) => !newDeviceIds.contains(d.deviceId));

      // Add/Update devices
      for (var device in devices) {
        final index = _connectedDevices.indexWhere(
          (d) => d.deviceId == device.deviceId,
        );
        if (index >= 0) {
          _connectedDevices[index] = device.copyWith(
            lastSeen: DateTime.now(),
            isConnected: true,
          );
        } else {
          _connectedDevices.add(device);
        }
      }

      _isConnected = true; // Host is always "connected" to the network
      notifyListeners();
      return;
    }

    // CLIENT MODE (Scanning): Additive
    if (devices.isEmpty) return;

    for (var device in devices) {
      // Deduplication Logic:
      // 1. Check exact ID match (normal)
      // 2. Check Name match if ID differs (handles MAC randomization on some Androids)
      // 3. Check if already connected (don't add "Scanned" version of "Connected" device)

      final existingIndex = _connectedDevices.indexWhere(
        (d) =>
            d.deviceId == device.deviceId ||
            (d.name == device.name && d.name != 'Unknown Device'),
      );

      if (existingIndex >= 0) {
        // If it's already in the list, update it (e.g. signal strength, last seen)
        // But preserve 'isConnected' state from the existing entry if it's true
        final existing = _connectedDevices[existingIndex];
        if (existing.isConnected) {
          // Don't overwrite a connected device with a scanned one (which usually has isConnected=false)
          // Just update LastSeen
          _connectedDevices[existingIndex] = existing.copyWith(
            lastSeen: DateTime.now(),
          );
        } else {
          _connectedDevices[existingIndex] = device.copyWith(
            lastSeen: DateTime.now(),
          );
        }
      } else {
        // New device found
        _connectedDevices.add(device);
      }
    }
    _isConnected = _connectedDevices.any((d) => d.isConnected);
    notifyListeners();
  }

  void _handleIncomingMessage(String message) {
    // This is raw string, MessageProvider will parse it.
    // However, P2PService parses JSON types.
    // If it's a regular message, P2PService calls onMessageReceived.
    onMessageReceived?.call(message);
  }

  void _handleDeviceStatusChanged(String deviceId, bool isOnline) {
    final index = _connectedDevices.indexWhere(
      (d) => d.deviceId == deviceId || d.id == deviceId,
    );
    if (index >= 0) {
      if (isOnline) {
        final device = _connectedDevices[index];
        final updated = device.copyWith(
          isConnected: true,
          lastSeen: DateTime.now(),
        );
        _connectedDevices[index] = updated;
        DatabaseService.updateConnectedDevice(updated);
      } else {
        final device = _connectedDevices[index];
        _connectedDevices.removeAt(index);
        DatabaseService.deleteConnectedDevice(
          device.id,
        ); // Or keep it marked offline? The original code removed it.
      }
      notifyListeners();
    }
  }

  void _handleScanTimeout() {
    _isDiscovering = false;
    notifyListeners();
  }

  void _handleConnectionStatus(String status) {
    // Can implement more specific logic here if needed
  }

  void _updateConnectedDeviceInList(ConnectedDevice updatedDevice) {
    final index = _connectedDevices.indexWhere(
      (d) => d.deviceId == updatedDevice.deviceId,
    );
    if (index != -1) {
      _connectedDevices[index] = updatedDevice;
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
