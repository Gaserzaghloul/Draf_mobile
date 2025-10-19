class ConnectedDevice {
  final String id;
  final String name;
  final String deviceId;
  final String? ipAddress;
  final int signalStrength;
  final DateTime lastSeen;
  final bool isConnected;
  final String? deviceType;

  ConnectedDevice({
    required this.id,
    required this.name,
    required this.deviceId,
    this.ipAddress,
    required this.signalStrength,
    required this.lastSeen,
    this.isConnected = false,
    this.deviceType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'deviceId': deviceId,
      'ipAddress': ipAddress,
      'signalStrength': signalStrength,
      'lastSeen': lastSeen.toIso8601String(),
      'isConnected': isConnected ? 1 : 0,
      'deviceType': deviceType,
    };
  }

  factory ConnectedDevice.fromMap(Map<String, dynamic> map) {
    return ConnectedDevice(
      id: map['id'],
      name: map['name'],
      deviceId: map['deviceId'],
      ipAddress: map['ipAddress'],
      signalStrength: map['signalStrength'],
      lastSeen: DateTime.parse(map['lastSeen']),
      isConnected: map['isConnected'] == 1,
      deviceType: map['deviceType'],
    );
  }

  ConnectedDevice copyWith({
    String? id,
    String? name,
    String? deviceId,
    String? ipAddress,
    int? signalStrength,
    DateTime? lastSeen,
    bool? isConnected,
    String? deviceType,
  }) {
    return ConnectedDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
      isConnected: isConnected ?? this.isConnected,
      deviceType: deviceType ?? this.deviceType,
    );
  }
}
