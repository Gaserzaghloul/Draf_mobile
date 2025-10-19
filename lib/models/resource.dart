enum ResourceType { document, image, video, audio, other }

enum ResourceStatus { available, downloading, downloaded, failed }

enum ResourceRequestType {
  request, // User is requesting a resource
  provide, // User is providing a resource
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
  final ResourceRequestType requestType; // Request or Provide
  final String? requestedBy; // ID of user who requested (if this is a request)
  final String?
  providedBy; // ID of user who provided (if this is provided for a request)
  final String? ownerName; // Name of the user who owns/requested the resource
  final String? providedByName; // Name of the user who provided the resource

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
    this.requestType = ResourceRequestType.request,
    this.requestedBy,
    this.providedBy,
    this.ownerName,
    this.providedByName,
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
      'requestType': requestType.name,
      'requestedBy': requestedBy,
      'providedBy': providedBy,
      'ownerName': ownerName,
      'providedByName': providedByName,
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
      requestType: map['requestType'] != null
          ? ResourceRequestType.values.firstWhere(
              (e) => e.name == map['requestType'],
            )
          : ResourceRequestType.request,
      requestedBy: map['requestedBy'],
      providedBy: map['providedBy'],
      ownerName: map['ownerName'],
      providedByName: map['providedByName'],
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
    ResourceRequestType? requestType,
    String? requestedBy,
    String? providedBy,
    String? ownerName,
    String? providedByName,
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
      requestType: requestType ?? this.requestType,
      requestedBy: requestedBy ?? this.requestedBy,
      providedBy: providedBy ?? this.providedBy,
      ownerName: ownerName ?? this.ownerName,
      providedByName: providedByName ?? this.providedByName,
    );
  }
}
