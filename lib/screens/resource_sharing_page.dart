import 'package:flutter/material.dart';
import '../models/resource.dart';

class ResourceSharingPage extends StatefulWidget {
  const ResourceSharingPage({super.key});

  @override
  State<ResourceSharingPage> createState() => _ResourceSharingPageState();
}

class _ResourceSharingPageState extends State<ResourceSharingPage> {
  bool _showRequestedResources = false;

  // Dummy data for UI demonstration
  final List<Resource> _dummyRequests = [
    Resource(
      id: '1',
      requesterId: 'user1',
      requesterName: 'John Doe',
      resourceType: 'Medical Supplies',
      quantity: 'First Aid Kit',
      description: 'Need bandages and antiseptic',
      requestType: ResourceRequestType.request,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    Resource(
      id: '2',
      requesterId: 'user2',
      requesterName: 'Sarah Smith',
      resourceType: 'Food',
      quantity: '5 meals',
      description: 'Non-perishable food items',
      requestType: ResourceRequestType.request,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  final List<Resource> _dummyProvisions = [
    Resource(
      id: '3',
      requesterId: 'me',
      requesterName: 'Me',
      resourceType: 'Water',
      quantity: '10 bottles',
      description: 'Clean drinking water available',
      requestType: ResourceRequestType.provide,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Resource(
      id: '4',
      requesterId: 'me',
      requesterName: 'Me',
      resourceType: 'Shelter',
      quantity: '2 tents',
      description: 'Camping tents in good condition',
      requestType: ResourceRequestType.provide,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  void _showRequestDialog() {
    final resourceTypeController = TextEditingController();
    final quantityController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Resource'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: resourceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Resource Type',
                  hintText: 'e.g., Medical, Food, Water',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g., 5 units, 2 boxes',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Additional details',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (resourceTypeController.text.isNotEmpty) {
                setState(() {
                  _dummyRequests.insert(
                    0,
                    Resource(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      requesterId: 'me',
                      requesterName: 'Me',
                      resourceType: resourceTypeController.text,
                      quantity: quantityController.text,
                      description: descriptionController.text,
                      requestType: ResourceRequestType.request,
                      timestamp: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resource request created (UI Demo)'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showProvideDialog() {
    final resourceTypeController = TextEditingController();
    final quantityController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Provide Resource'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: resourceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Resource Type',
                  hintText: 'e.g., Medical, Food, Water',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g., 5 units, 2 boxes',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Additional details',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (resourceTypeController.text.isNotEmpty) {
                setState(() {
                  _dummyProvisions.insert(
                    0,
                    Resource(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      requesterId: 'me',
                      requesterName: 'Me',
                      resourceType: resourceTypeController.text,
                      quantity: quantityController.text,
                      description: descriptionController.text,
                      requestType: ResourceRequestType.provide,
                      timestamp: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resource provision created (UI Demo)'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Provide'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedResources = _showRequestedResources
        ? _dummyRequests
        : _dummyProvisions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Sharing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text('About Resource Sharing'),
                  content: Text(
                    'Request resources you need or provide resources you have available. '
                    'This helps coordinate emergency supplies across the network.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle between Requests and Provisions
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2631),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2C3E50)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          setState(() => _showRequestedResources = false),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: !_showRequestedResources
                              ? const Color(0xFFD4AF37)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.volunteer_activism,
                              color: !_showRequestedResources
                                  ? const Color(0xFF101820)
                                  : const Color(0xFFC0C0C0),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'I Provide',
                              style: TextStyle(
                                color: !_showRequestedResources
                                    ? const Color(0xFF101820)
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          setState(() => _showRequestedResources = true),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _showRequestedResources
                              ? const Color(0xFFD4AF37)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: _showRequestedResources
                                      ? const Color(0xFF101820)
                                      : const Color(0xFFC0C0C0),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'I Request',
                                  style: TextStyle(
                                    color: _showRequestedResources
                                        ? const Color(0xFF101820)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Show badge for incoming requests.
                            if (_dummyRequests.length > 1)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_dummyRequests.length - 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Resource List
          Expanded(
            child: displayedResources.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayedResources.length,
                    itemBuilder: (context, index) {
                      return _buildResourceCard(displayedResources[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRequestedResources
            ? _showRequestDialog
            : _showProvideDialog,
        backgroundColor: const Color(0xFFD4AF37),
        icon: Icon(
          _showRequestedResources ? Icons.add_alert : Icons.add,
          color: const Color(0xFF101820),
        ),
        label: Text(
          _showRequestedResources ? 'New Request' : 'Provide Resource',
          style: const TextStyle(
            color: Color(0xFF101820),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showRequestedResources
                ? Icons.help_outline
                : Icons.volunteer_activism,
            size: 80,
            color: Colors.grey[800],
          ),
          const SizedBox(height: 16),
          Text(
            _showRequestedResources
                ? 'No resource requests yet'
                : 'No resources provided yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _showRequestedResources
                ? 'Tap + to request resources'
                : 'Tap + to share your resources',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(Resource resource) {
    final isMyResource = resource.requesterId == 'me';
    final isRequest = resource.requestType == ResourceRequestType.request;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2631),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRequest
              ? Colors.orange.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRequest
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRequest ? Icons.help_outline : Icons.volunteer_activism,
                    color: isRequest ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.resourceType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        resource.requesterName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRequest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEEDED',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (resource.quantity.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: Color(0xFFC0C0C0),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      resource.quantity,
                      style: const TextStyle(color: Color(0xFFC0C0C0)),
                    ),
                  ],
                ),
              ),
            if (resource.description != null &&
                resource.description!.isNotEmpty)
              Text(
                resource.description!,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimestamp(resource.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (!isMyResource && isRequest)
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Responding to ${resource.resourceType} request (UI Demo)',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('I Can Help'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
