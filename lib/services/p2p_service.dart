// Manages P2P connections using WiFi Direct and BLE for discovery.
// Handles automatic peer discovery and group creation.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import '../models/connected_device.dart';
import '../models/resource.dart';
import '../database/database_service.dart';

class P2PService {
  // Host instance for managing the network.
  FlutterP2pHost? _p2pHost;

  // Client instance for joining networks.
  FlutterP2pClient? _p2pClient;

  bool _isInitialized = false;
  bool _isDiscovering = false;
  bool _isAdvertising = false;
  bool _isHostMode = false;

  StreamSubscription<HotspotHostState>? _hostStateSubscription;
  StreamSubscription<HotspotClientState>? _clientStateSubscription;
  StreamSubscription<String>? _messagesSubscription;
  StreamSubscription<List<P2pClientInfo>>? _clientsSubscription;
  StreamSubscription<List<BleDiscoveredDevice>>? _bleScanSubscription;
  Timer? _scanTimeoutTimer;
  bool _hasFoundDevices = false;

  // Discovery and connection callbacks.
  Function(List<ConnectedDevice>)? onDevicesDiscovered;
  Function(String)? onMessageReceived;
  Function(String)? onConnectionStatusChanged;
  Function()? onScanTimeout; // Callback triggered when scanning times out.
  Function(Resource)?
  onResourceRequestReceived; // Callback for receiving resource requests.
  Function(String, String, String, String?)?
  onResourceFulfilledReceived; // Callback for resource fulfillment.
  Function(String, bool)?
  onDeviceStatusChanged; // Callback for device status updates.

  // Initialize P2P service.
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Request necessary permissions.
      // We'll request permissions when needed (host or client mode)

      _isInitialized = true;

      return true;
    } catch (e) {
      debugPrint('P2P Service: Initialization error: $e');
      return false;
    }
  }

  // Start advertising this device as a host.
  Future<bool> startAdvertising({String? deviceName}) async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('P2P Service: Initialization failed');
          return false;
        }
      }

      // Initialize host instance.
      _p2pHost = FlutterP2pHost();
      await _p2pHost!.initialize();

      // Request permissions for host mode.
      try {
        await _p2pHost!.askP2pPermissions();
      } catch (e) {
        debugPrint('P2P Service: P2P permissions error: $e');
      }

      try {
        await _p2pHost!.askStoragePermission();
      } catch (e) {
        debugPrint('P2P Service: Storage permission error: $e');
      }

      try {
        await _p2pHost!.askBluetoothPermissions();
      } catch (e) {
        debugPrint('P2P Service: Bluetooth permissions error: $e');
      }

      // Enable required services.
      try {
        await _p2pHost!.enableWifiServices();
      } catch (e) {
        debugPrint('P2P Service: WiFi services error: $e');
      }

      try {
        await _p2pHost!.enableLocationServices();
      } catch (e) {
        debugPrint('P2P Service: Location services error: $e');
      }

      try {
        await _p2pHost!.enableBluetoothServices();
      } catch (e) {
        debugPrint('P2P Service: Bluetooth services error: $e');
      }

      try {
        await _p2pHost!.createGroup();
      } catch (e, stackTrace) {
        debugPrint('P2P Service: ❌ ERROR in createGroup(): $e');
        debugPrint('P2P Service: Stack trace: $stackTrace');
        return false;
      }

      // Wait for group creation and BLE advertising.
      await Future.delayed(const Duration(seconds: 3));

      // Verify group creation.
      final isGroupCreated = _p2pHost!.isGroupCreated;

      if (!isGroupCreated) {
        debugPrint(
          'P2P Service: ❌ FAILED - isGroupCreated is false after createGroup()',
        );
        debugPrint('P2P Service: This usually means:');
        debugPrint('P2P Service: 1. WiFi permissions not granted');
        debugPrint('P2P Service: 2. Another app is using WiFi hotspot');
        debugPrint('P2P Service: 3. Device does not support WiFi Direct');
        debugPrint('P2P Service: 4. WiFi services not enabled');
        return false;
      }

      // Verify hotspot activity.
      try {
        final hotspotState = await _p2pHost!.streamHotspotState().first.timeout(
          const Duration(seconds: 5),
        );

        if (!hotspotState.isActive) {
          debugPrint(
            'P2P Service: WARNING - Hotspot is not active after creation!',
          );
        }
      } catch (e) {
        debugPrint('P2P Service: Could not get hotspot state: $e');
      }

      _isAdvertising = true;
      _isHostMode = true;

      // Monitor hotspot state.
      _hostStateSubscription?.cancel();
      _hostStateSubscription = _p2pHost!.streamHotspotState().listen((state) {
        if (onConnectionStatusChanged != null) {
          onConnectionStatusChanged!(
            state.isActive ? 'host_active' : 'host_inactive',
          );
        }
      });

      // Monitor connected clients.
      _clientsSubscription?.cancel();
      _clientsSubscription = _p2pHost!.streamClientList().listen((clients) {
        _handleConnectedClients(clients);
      });

      // Begin listening for messages.
      _startListeningHost();

      _startListeningHost();
      return true;
    } catch (e) {
      debugPrint('P2P Service: Advertising error: $e');
      _isAdvertising = false;
      _isHostMode = false;
      return false;
    }
  }

  // Stop advertising this device.
  Future<void> stopAdvertising() async {
    try {
      // Cancel subscriptions.
      await _hostStateSubscription?.cancel();
      await _clientsSubscription?.cancel();
      _hostStateSubscription = null;
      _clientsSubscription = null;

      // Cleanup host resources.
      if (_p2pHost != null) {
        if (_p2pHost!.isGroupCreated) {
          await _p2pHost!.removeGroup();
        }
        await _p2pHost!.dispose();
        _p2pHost = null;
      }

      _isAdvertising = false;
      _isHostMode = false;
      _isHostMode = false;
    } catch (e) {
      debugPrint('P2P Service: Stop advertising error: $e');
    }
  }

  // Start scanning for nearby devices.
  Future<bool> startScanning() async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('P2P Service: Initialization failed');
          return false;
        }
      }

      if (_isDiscovering) {
        debugPrint('P2P Service: Already scanning');
        return true;
      }

      // Initialize client instance.
      _p2pClient = FlutterP2pClient();
      await _p2pClient!.initialize();

      // Request client permissions.
      try {
        await _p2pClient!.askP2pPermissions();
      } catch (e) {
        debugPrint('P2P Service: P2P permissions error: $e');
      }

      try {
        await _p2pClient!.askStoragePermission();
      } catch (e) {
        debugPrint('P2P Service: Storage permission error: $e');
      }

      try {
        await _p2pClient!.askBluetoothPermissions();
      } catch (e) {
        debugPrint('P2P Service: Bluetooth permissions error: $e');
      }

      // Enable required services.
      try {
        await _p2pClient!.enableWifiServices();
      } catch (e) {
        debugPrint('P2P Service: WiFi services error: $e');
      }

      try {
        await _p2pClient!.enableLocationServices();
      } catch (e) {
        debugPrint('P2P Service: Location services error: $e');
      }

      try {
        await _p2pClient!.enableBluetoothServices();
      } catch (e) {
        debugPrint('P2P Service: Bluetooth services error: $e');
      }

      // Start BLE scanning.
      _isDiscovering = true;
      _hasFoundDevices = false;

      // Set up scan timeout.
      _scanTimeoutTimer?.cancel();
      _scanTimeoutTimer = Timer(const Duration(seconds: 30), () {
        // Timeout if no devices found.
        if (!_hasFoundDevices && _isDiscovering) {
          debugPrint(
            'P2P Service: Scan timeout - no devices found after 30 seconds',
          );
          if (onScanTimeout != null) {
            onScanTimeout!();
          }
          _isDiscovering = false;
        }
      });

      // Delay slightly to ensure services are ready.
      await Future.delayed(const Duration(milliseconds: 500));

      // Begin scan and handle results.
      _bleScanSubscription = await _p2pClient!.startScan(
        (devices) {
          if (devices.isNotEmpty) {
            _hasFoundDevices = true;
            _scanTimeoutTimer?.cancel();
            debugPrint('P2P Service: ✅ DEVICES FOUND! Processing...');
            for (var device in devices) {
              debugPrint(
                'P2P Service: ✅ Found device - Name: "${device.deviceName}", Address: "${device.deviceAddress}"',
              );
            }
          }
          _handleDiscoveredDevices(devices);
        },
        onDone: () {
          _isDiscovering = false;
          _scanTimeoutTimer?.cancel();
          debugPrint('P2P Service: Scan stream completed/closed');
        },
        timeout: const Duration(seconds: 30),
      );

      // Monitor client connection state.
      _clientStateSubscription?.cancel();
      _clientStateSubscription = _p2pClient!.streamHotspotState().listen((
        state,
      ) {
        debugPrint('P2P Service: Client state - Active: ${state.isActive}');
        if (onConnectionStatusChanged != null) {
          onConnectionStatusChanged!(
            state.isActive ? 'client_connected' : 'client_disconnected',
          );
        }
      });

      // Begin listening for messages.
      _startListeningClient();

      return true;
    } catch (e) {
      debugPrint('P2P Service: Scanning error: $e');
      _isDiscovering = false;
      return false;
    }
  }

  // Stop scanning for devices.
  Future<void> stopScanning() async {
    try {
      // Cancel timeout.
      _scanTimeoutTimer?.cancel();
      _scanTimeoutTimer = null;
      _hasFoundDevices = false;

      // Cancel subscriptions.
      await _bleScanSubscription?.cancel();
      await _clientStateSubscription?.cancel();
      _bleScanSubscription = null;
      _clientStateSubscription = null;

      // Cleanup client resources.
      if (_p2pClient != null) {
        try {
          await _p2pClient!.stopScan();
        } catch (e) {
          debugPrint('P2P Service: Error stopping scan: $e');
        }
        await _p2pClient!.dispose();
        _p2pClient = null;
      }

      _isDiscovering = false;
      debugPrint('P2P Service: Stopped scanning');
    } catch (e) {
      debugPrint('P2P Service: Stop scanning error: $e');
    }
  }

  // Process discovered BLE devices.
  void _handleDiscoveredDevices(List<BleDiscoveredDevice> devices) {
    debugPrint('P2P Service: ===== _handleDiscoveredDevices CALLED =====');
    debugPrint('P2P Service: Received ${devices.length} device(s)');

    if (devices.isEmpty) {
      debugPrint('P2P Service: ⚠️ Empty device list - no devices discovered');
      return;
    }

    final connectedDevices = <ConnectedDevice>[];

    for (var device in devices) {
      try {
        // Map BLE device to internal model.
        final deviceAddress = device.deviceAddress;
        final deviceName = device.deviceName;

        debugPrint(
          'P2P Service: Processing device - Name: "$deviceName", Address: "$deviceAddress"',
        );

        final connectedDevice = ConnectedDevice(
          id: deviceAddress.isNotEmpty
              ? deviceAddress
              : DateTime.now().millisecondsSinceEpoch.toString(),
          name: deviceName.isNotEmpty ? deviceName : 'Unknown Device',
          deviceId: deviceAddress.isNotEmpty ? deviceAddress : deviceName,
          ipAddress: deviceAddress.isNotEmpty ? deviceAddress : null,
          signalStrength: 75, // BLE devices typically have good signal
          lastSeen: DateTime.now(),
          isConnected: false,
          deviceType: 'Android',
        );

        connectedDevices.add(connectedDevice);
        debugPrint(
          'P2P Service: ✅ Added device: ${connectedDevice.name} (${connectedDevice.deviceId})',
        );

        // Persist discovered device.
        DatabaseService.insertConnectedDevice(connectedDevice).catchError((e) {
          debugPrint('P2P Service: Error saving device to DB: $e');
          return '';
        });
      } catch (e) {
        debugPrint('P2P Service: ❌ Error processing device: $e');
      }
    }

    // Notify listeners of discovery.
    debugPrint(
      'P2P Service: Total devices processed: ${connectedDevices.length}',
    );
    if (onDevicesDiscovered != null) {
      debugPrint(
        'P2P Service: ✅ Calling onDevicesDiscovered callback with ${connectedDevices.length} device(s)',
      );
      onDevicesDiscovered!(connectedDevices);
      debugPrint(
        'P2P Service: ✅ Callback executed - devices should appear in UI now',
      );
    } else {
      debugPrint(
        'P2P Service: ❌ WARNING - onDevicesDiscovered callback is NULL!',
      );
      debugPrint(
        'P2P Service: This means AppState did not set up the callback properly',
      );
    }
  }

  // Process connected clients.
  void _handleConnectedClients(List<P2pClientInfo> clients) {
    final connectedDevices = <ConnectedDevice>[];

    for (var client in clients) {
      if (client.isHost) continue; // Skip host itself

      try {
        // Map client to internal model.
        final device = ConnectedDevice(
          id: client.id,
          name: client.username,
          deviceId: client.id,
          ipAddress: null,
          signalStrength: 100, // Connected clients have full signal
          lastSeen: DateTime.now(),
          isConnected: true,
          deviceType: 'Android',
        );

        connectedDevices.add(device);

        // Persist client.
        DatabaseService.insertConnectedDevice(device).catchError((e) {
          debugPrint('P2P Service: Error saving client to DB: $e');
          return '';
        });
      } catch (e) {
        debugPrint('P2P Service: Error processing client: $e');
      }
    }

    // Notify listeners.
    if (onDevicesDiscovered != null) {
      onDevicesDiscovered!(connectedDevices);
    }
  }

  // Connect to a specific device.
  Future<bool> connectToDevice(String deviceAddress) async {
    try {
      if (_p2pClient == null) {
        debugPrint('P2P Service: Client not initialized');
        return false;
      }

      // Locate device details.
      final bleDevice = BleDiscoveredDevice(
        deviceName: 'Device $deviceAddress',
        deviceAddress: deviceAddress,
      );

      // Establish connection.
      await _p2pClient!.connectWithDevice(bleDevice);

      // Re-establish message listeners.
      // This ensures the client can send AND receive messages after reconnecting
      debugPrint(
        'P2P Service: Re-establishing message listeners after connection...',
      );
      _startListeningClient();
      debugPrint('P2P Service: Message listeners re-established');

      // Update device status.
      try {
        final allDevices = await DatabaseService.getAllConnectedDevices();
        final device = allDevices.firstWhere(
          (d) => d.deviceId == deviceAddress,
          orElse: () => ConnectedDevice(
            id: deviceAddress,
            name: 'Device $deviceAddress',
            deviceId: deviceAddress,
            ipAddress: deviceAddress,
            signalStrength: 100,
            lastSeen: DateTime.now(),
            isConnected: true,
            deviceType: 'Android',
          ),
        );

        final updatedDevice = device.copyWith(
          isConnected: true,
          lastSeen: DateTime.now(),
        );

        await DatabaseService.updateConnectedDevice(updatedDevice);
      } catch (e) {
        debugPrint('P2P Service: Error updating device in DB: $e');
      }

      if (onConnectionStatusChanged != null) {
        onConnectionStatusChanged!('connected:$deviceAddress');
      }

      debugPrint('P2P Service: Connected to device $deviceAddress');
      return true;
    } catch (e) {
      debugPrint('P2P Service: Connection error: $e');
      if (onConnectionStatusChanged != null) {
        onConnectionStatusChanged!('error:$deviceAddress');
      }
      return false;
    }
  }

  // Disconnect from device.
  Future<void> disconnectFromDevice(ConnectedDevice device) async {
    try {
      if (_p2pClient != null) {
        await _p2pClient!.disconnect();
      }

      // Update status.
      final updatedDevice = device.copyWith(
        isConnected: false,
        lastSeen: DateTime.now(),
      );

      await DatabaseService.updateConnectedDevice(updatedDevice);

      if (onConnectionStatusChanged != null) {
        onConnectionStatusChanged!('disconnected:${device.deviceId}');
      }

      debugPrint('P2P Service: Disconnected from device ${device.name}');
    } catch (e) {
      debugPrint('P2P Service: Disconnect error: $e');
    }
  }

  // Listen for incoming host messages.
  void _startListeningHost() {
    if (_p2pHost == null) return;

    // Subscribe to text stream.
    _messagesSubscription?.cancel();
    _messagesSubscription = _p2pHost!.streamReceivedTexts().listen((message) {
      debugPrint('P2P Service: Received message (Host): $message');
      // Parse received messages.
      _handleReceivedMessage(message);
    });
  }

  // Listen for incoming client messages.
  void _startListeningClient() {
    if (_p2pClient == null) return;

    // Subscribe to text stream.
    _messagesSubscription?.cancel();
    _messagesSubscription = _p2pClient!.streamReceivedTexts().listen((message) {
      debugPrint('P2P Service: Received message (Client): $message');
      // Parse received messages.
      _handleReceivedMessage(message);
    });
  }

  // Parse type-specific messages (commands, statuses, etc).
  void _handleReceivedMessage(String message) {
    try {
      final jsonData = message.trim();
      // Check for JSON format.
      if (jsonData.startsWith('{') && jsonData.endsWith('}')) {
        final Map<String, dynamic> json = jsonDecode(jsonData);
        final type = json['type'] as String?;

        if (type == 'resource_request') {
          // Handle resource request.
          final resourceMap = json['resource'] as Map<String, dynamic>?;
          if (resourceMap != null) {
            final resource = Resource.fromMap(resourceMap);
            debugPrint(
              'P2P Service: Received resource request: ${resource.name}',
            );
            // Notify listeners.
            if (onResourceRequestReceived != null) {
              onResourceRequestReceived!(resource);
            }
            return; // Don't pass to regular message handler
          }
        } else if (type == 'resource_fulfilled') {
          // Handle resource fulfillment.
          final requestId = json['requestId'] as String?;
          final filePath = json['filePath'] as String? ?? '';
          final sender = json['sender'] as String? ?? '';
          final senderName = json['senderName'] as String?; // Optional now
          if (requestId != null) {
            debugPrint(
              'P2P Service: Received resource fulfillment: $requestId from $sender ($senderName)',
            );
            // Update resource status.
            if (onResourceFulfilledReceived != null) {
              onResourceFulfilledReceived!(
                requestId,
                filePath,
                sender,
                senderName,
              );
            }
            return; // Don't pass to regular message handler
          }
        } else if (type == 'device_status') {
          // Handle device status update.
          final deviceId = json['deviceId'] as String?;
          final isOnline = json['isOnline'] as bool? ?? false;
          if (deviceId != null) {
            debugPrint(
              'P2P Service: Received device status: $deviceId is ${isOnline ? "ONLINE" : "OFFLINE"}',
            );
            // Notify listeners.
            if (onDeviceStatusChanged != null) {
              onDeviceStatusChanged!(deviceId, isOnline);
            }
            return; // Don't pass to regular message handler
          }
        }
      }
    } catch (e) {
      debugPrint('P2P Service: Error parsing message JSON: $e');
    }

    // Pass standard messages to callback.
    if (onMessageReceived != null) {
      onMessageReceived!(message);
    }
  }

  // Broadcast text message to peers.
  Future<bool> sendMessage(String message) async {
    try {
      // Works for both host and client modes.
      if (_isHostMode && _p2pHost != null) {
        await _p2pHost!.broadcastText(message);
        debugPrint('P2P Service: Sent message (Host): $message');
        return true;
      } else if (_p2pClient != null) {
        await _p2pClient!.broadcastText(message);
        debugPrint('P2P Service: Sent message (Client): $message');
        return true;
      }

      debugPrint('P2P Service: Cannot send message - no active connection');
      return false;
    } catch (e) {
      debugPrint('P2P Service: Send message error: $e');
      return false;
    }
  }

  // Check if currently discovering.
  bool get isDiscovering => _isDiscovering;

  // Check if currently advertising.
  bool get isAdvertising => _isAdvertising;

  // Check if initialized.
  bool get isInitialized => _isInitialized;

  // Check if in host mode.
  bool get isHostMode => _isHostMode;

  // Cleanup and dispose resources.
  Future<void> dispose() async {
    try {
      await stopScanning();
      await stopAdvertising();
      await _messagesSubscription?.cancel();
      await _hostStateSubscription?.cancel();
      await _clientStateSubscription?.cancel();
      await _clientsSubscription?.cancel();
      await _bleScanSubscription?.cancel();
      _scanTimeoutTimer?.cancel();
      _messagesSubscription = null;
      _hostStateSubscription = null;
      _clientStateSubscription = null;
      _clientsSubscription = null;
      _bleScanSubscription = null;
      _scanTimeoutTimer = null;
      _isInitialized = false;
      debugPrint('P2P Service: Disposed');
    } catch (e) {
      debugPrint('P2P Service: Dispose error: $e');
    }
  }
}
