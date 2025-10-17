enum ResourceType {
  document,
  image,
  video,
  audio,
  other,
}

enum ResourceStatus {
  available,
  downloading,
  downloaded,
  failed,
}

class Resource {
  final String id;
  final String name;
  final String description;
  final ResourceType type;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String ownerId;
  final DateTime createdAt;
  final ResourceStatus status;
  final String? checksum;

  Resource({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.ownerId,
    required this.createdAt,
    this.status = ResourceStatus.available,
    this.checksum,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'checksum': checksum,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: ResourceType.values.firstWhere((e) => e.name == map['type']),
      filePath: map['filePath'],
      fileName: map['fileName'],
      fileSize: map['fileSize'],
      ownerId: map['ownerId'],
      createdAt: DateTime.parse(map['createdAt']),
      status: ResourceStatus.values.firstWhere((e) => e.name == map['status']),
      checksum: map['checksum'],
    );
  }

  Resource copyWith({
    String? id,
    String? name,
    String? description,
    ResourceType? type,
    String? filePath,
    String? fileName,
    int? fileSize,
    String? ownerId,
    DateTime? createdAt,
    ResourceStatus? status,
    String? checksum,
  }) {
    return Resource(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      checksum: checksum ?? this.checksum,
    );
  }
}
