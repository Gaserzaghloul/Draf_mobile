import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/resource_provider.dart';
import '../services/user_provider.dart';
import '../services/network_provider.dart';
import '../models/resource.dart';

enum ResourceCategory { medical, shelter, food }

class ResourceSharingPage extends StatefulWidget {
  const ResourceSharingPage({super.key});

  @override
  State<ResourceSharingPage> createState() => _ResourceSharingPageState();
}

class _ResourceSharingPageState extends State<ResourceSharingPage> {
  bool _showRequestedResources = false; // Track if showing requested resources
  String? _lastFulfilledRequestId; // Track fulfillment for alerts.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Sharing'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Consumer3<ResourceProvider, UserProvider, NetworkProvider>(
        builder:
            (context, resourceProvider, userProvider, networkProvider, child) {
              // Build alert for fulfilled requests.
              _checkForFulfillments(resourceProvider);

              return Column(
                children: [
                  // Two main action buttons
                  _buildActionButtons(resourceProvider),

                  // Content area
                  Expanded(
                    child: _showRequestedResources
                        ? _buildRequestedResourcesList(
                            resourceProvider,
                            userProvider,
                            networkProvider,
                          )
                        : _buildAllResourcesList(
                            resourceProvider,
                            userProvider,
                            networkProvider,
                          ),
                  ),
                ],
              );
            },
      ),
    );
  }

  // Build the two main buttons: Request Resource and Provide Resource
  Widget _buildActionButtons(ResourceProvider resourceProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showRequestedResources = false;
                });
                _showRequestResourceDialog();
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Request Resource'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRequestedResources = true;
                    });
                  },
                  icon: const Icon(Icons.handshake),
                  label: const Text('Provide Resource'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                // Show badge for incoming requests.
                if (resourceProvider.incomingResourceRequestsCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          resourceProvider.incomingResourceRequestsCount > 9
                              ? '9+'
                              : resourceProvider.incomingResourceRequestsCount
                                    .toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build list of all resources (requests and provides)
  Widget _buildAllResourcesList(
    ResourceProvider resourceProvider,
    UserProvider userProvider,
    NetworkProvider networkProvider,
  ) {
    final items = resourceProvider.resources;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No resources yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Request or provide resources to help others',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final resource = items[index];
        return _buildResourceCard(resource, userProvider, networkProvider);
      },
    );
  }

  // Build list of requested resources (for Provide Resource view)
  Widget _buildRequestedResourcesList(
    ResourceProvider resourceProvider,
    UserProvider userProvider,
    NetworkProvider networkProvider,
  ) {
    // Combine local and incoming P2P requests.
    final requestedResources = resourceProvider.resources
        .where((r) => r.requestType == ResourceRequestType.request)
        .toList();

    final allRequests = <Resource>[...requestedResources];
    for (var incoming in resourceProvider.incomingResourceRequests) {
      if (!allRequests.any((r) => r.id == incoming.id)) {
        allRequests.add(incoming);
      }
    }

    if (allRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No resource requests',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no pending resource requests.\nYou can help by providing resources when requests are made.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allRequests.length,
      itemBuilder: (context, index) {
        final resource = allRequests[index];
        return _buildRequestedResourceCard(
          resource,
          userProvider,
          networkProvider,
        );
      },
    );
  }

  // Helper to get user name
  String _getUserName(
    String userId,
    UserProvider userProvider,
    NetworkProvider networkProvider, {
    String? storedName,
  }) {
    // 1. Check if it's me
    if (userId == userProvider.currentUser?.id) {
      return 'You';
    }

    // 2. Use stored name in Resource if available
    if (storedName != null &&
        storedName.isNotEmpty &&
        storedName != 'Unknown User') {
      return storedName;
    }

    // 3. Fallback: Check connected devices
    final device = networkProvider.connectedDevices.cast<dynamic>().firstWhere(
      (d) =>
          d.deviceId == userId ||
          d.id == userId, // Assuming deviceId matches userId for simplicity
      orElse: () => null,
    );

    if (device != null) {
      return device.name;
    }

    return 'Unknown User ($userId)'; // Final Fallback
  }

  // Build card for requested resource (in Provide Resource view)
  Widget _buildRequestedResourceCard(
    Resource resource,
    UserProvider userProvider,
    NetworkProvider networkProvider,
  ) {
    final ownerName = _getUserName(
      resource.ownerId,
      userProvider,
      networkProvider,
      storedName: resource.ownerName,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.orange[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Requested by: $ownerName',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                _formatDate(resource.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Only show Provide button if this is NOT the current user's request
          if (resource.ownerId != userProvider.currentUser?.id &&
              resource.providedBy == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _provideResourceForRequest(resource),
                icon: const Icon(Icons.volunteer_activism, size: 18),
                label: const Text('Provide This Resource'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          // Show message if this is the current user's request
          if (resource.ownerId == userProvider.currentUser?.id &&
              resource.providedBy == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is your request. Waiting for others to provide.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Build card for all resources
  Widget _buildResourceCard(
    Resource resource,
    UserProvider userProvider,
    NetworkProvider networkProvider,
  ) {
    final isRequest = resource.requestType == ResourceRequestType.request;
    final ownerName = _getUserName(
      resource.ownerId,
      userProvider,
      networkProvider,
      storedName: resource.ownerName,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRequest ? Colors.orange[200]! : Colors.green[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isRequest ? Colors.orange : Colors.green).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isRequest ? Icons.help_outline : Icons.check_circle,
                  color: isRequest ? Colors.orange[700] : Colors.green[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isRequest ? 'REQUEST' : 'PROVIDED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isRequest
                                ? Colors.orange[700]
                                : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                isRequest
                    ? 'Requested by: $ownerName'
                    : 'Provided by: $ownerName',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatDate(resource.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          if (isRequest && resource.providedBy != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Provided by: ${_getUserName(resource.providedBy!, userProvider, networkProvider, storedName: resource.providedByName)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Show dialog to request a resource
  void _showRequestResourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final descController = TextEditingController();
        ResourceCategory selected = ResourceCategory.medical;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Request Resource'),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  minWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: ResourceCategory.values.map((c) {
                        return ChoiceChip(
                          label: Text(c.name),
                          selected: selected == c,
                          onSelected: (_) => setState(() => selected = c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Resource Name',
                        hintText: 'e.g., Medical supplies, Food, Shelter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe what you need...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final resourceProvider = Provider.of<ResourceProvider>(
                    context,
                    listen: false,
                  );
                  final userProvider = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );

                  if (userProvider.currentUser != null &&
                      nameController.text.isNotEmpty) {
                    final resource = Resource(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      description: descController.text,
                      type: _resourceTypeForCategory(selected),
                      filePath: '',
                      fileName: '',
                      fileSize: 0,
                      ownerId: userProvider.currentUser!.id,
                      ownerName: userProvider.currentUser!.name,
                      createdAt: DateTime.now(),
                      requestType: ResourceRequestType.request,
                      requestedBy: userProvider.currentUser!.id,
                    );

                    resourceProvider.addResource(resource);

                    // Broadcast request. // REC-2
                    resourceProvider
                        .broadcastResourceRequest(
                          // REC-2
                          resource, // Changed from newResource to resource
                        )
                        .then((sent) {
                          if (context.mounted) {
                            if (sent) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Resource request broadcasted successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Request saved locally. Will retry sending automatically.',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        });

                    Navigator.pop(context);
                  }
                },
                child: const Text('Request'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Provide resource for a request
  void _provideResourceForRequest(Resource requestedResource) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final descController = TextEditingController();

        return AlertDialog(
          title: const Text('Provide Resource'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You are providing: ${requestedResource.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  hintText:
                      'Add any details about the resource you are providing...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final resourceProvider = Provider.of<ResourceProvider>(
                  context,
                  listen: false,
                );
                final networkProvider = Provider.of<NetworkProvider>(
                  context,
                  listen: false,
                ); // REC-3
                final currentUser = userProvider.currentUser!;

                // Create a provided resource entry
                final providedResource = Resource(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: 'Provided: ${requestedResource.name}',
                  description: descController.text.isNotEmpty
                      ? descController.text
                      : 'Resource provided for request',
                  type: requestedResource.type,
                  filePath: '',
                  fileName: '',
                  fileSize: 0,
                  ownerId: currentUser.id,
                  ownerName: currentUser.name,
                  createdAt: DateTime.now(),
                  requestType: ResourceRequestType.provide,
                  providedBy: currentUser.id,
                  providedByName: currentUser.name,
                );

                // Update the requested resource to mark it as provided
                final updatedRequest = requestedResource.copyWith(
                  providedBy: currentUser.id,
                  providedByName: currentUser.name,
                );

                resourceProvider.addResource(providedResource);
                resourceProvider.updateResource(updatedRequest);

                // Broadcast fulfillment.
                // Note: filePath would normally come from file picker, using empty for now
                final filePath =
                    ''; // In real implementation, get from file picker
                resourceProvider
                    .broadcastResourceFulfilled(requestedResource.id, filePath)
                    .then((sent) {
                      if (sent) {
                        debugPrint(
                          'ResourceSharingPage: Resource fulfillment broadcasted',
                        );
                      }
                    });

                // Send alert to the requester (via message)
                resourceProvider.sendProvisionMessage(
                  requestedResource.ownerId,
                  'Your resource request "${requestedResource.name}" has been provided by ${currentUser.name}!',
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Resource provided! The requester has been alerted.',
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Provide Resource'),
            ),
          ],
        );
      },
    );
  }

  ResourceType _resourceTypeForCategory(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.medical:
        return ResourceType.document;
      case ResourceCategory.shelter:
        return ResourceType.other;
      case ResourceCategory.food:
        return ResourceType.other;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Check for new fulfillments.
  void _checkForFulfillments(ResourceProvider resourceProvider) {
    // Find resources that were just fulfilled (have providedBy and filePath)
    final fulfilledResources = resourceProvider.resources.where((r) {
      return r.requestType == ResourceRequestType.request &&
          r.providedBy != null &&
          r.filePath.isNotEmpty &&
          r.id != _lastFulfilledRequestId;
    }).toList();

    if (fulfilledResources.isNotEmpty) {
      // Show green alert for each new fulfillment
      for (var resource in fulfilledResources) {
        // Check for fulfillments. // REC-2
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkForFulfillments(resourceProvider); // REC-2

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resource request fulfilled: ${resource.name}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        });
      }
    }
  }
}
