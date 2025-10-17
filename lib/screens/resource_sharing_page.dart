import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/resource.dart';
import '../services/voice_command_service.dart';

enum ResourceCategory { medical, shelter, food }

class ResourceSharingPage extends StatefulWidget {
  const ResourceSharingPage({super.key});

  @override
  State<ResourceSharingPage> createState() => _ResourceSharingPageState();
}

class _ResourceSharingPageState extends State<ResourceSharingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Coordination'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await VoiceCommandService().startListening(
                context: context,
                intents: {
                  'new medical request': (ctx) async =>
                      _createQuickRequest(ResourceCategory.medical),
                  'new shelter offer': (ctx) async =>
                      _createQuickRequest(ResourceCategory.shelter),
                  'new food request': (ctx) async =>
                      _createQuickRequest(ResourceCategory.food),
                },
              );
            },
            icon: const Icon(Icons.mic),
            tooltip: 'Voice commands',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              _buildCategoriesBar(),
              Expanded(child: _buildCoordinationLists(appState)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEntrySheet,
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoriesBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildCategoryChip(
            ResourceCategory.medical,
            Icons.medical_services,
            Colors.red,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            ResourceCategory.shelter,
            Icons.house,
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            ResourceCategory.food,
            Icons.restaurant,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    ResourceCategory category,
    IconData icon,
    Color color,
  ) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(category.name.toUpperCase()),
      backgroundColor: color.withOpacity(0.1),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.4))),
    );
  }

  Widget _buildCoordinationLists(AppState appState) {
    final items = appState.resources;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No coordination entries yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the + button to add a request or offer',
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
        return _buildCoordinationCard(resource);
      },
    );
  }

  Widget _buildCoordinationCard(Resource resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: _getResourceTypeColor(resource.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getResourceTypeIcon(resource.type),
                  color: _getResourceTypeColor(resource.type),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(resource.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  resource.status.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
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
                'Owner: ${resource.ownerId}',
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
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.volunteer_activism, size: 16),
                label: const Text('Offer Help'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle, size: 16),
                label: const Text('Mark Fulfilled'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getResourceTypeIcon(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        // Use a neutral icon instead of a document/PDF icon
        return Icons.category;
      case ResourceType.image:
        return Icons.image;
      case ResourceType.video:
        return Icons.videocam;
      case ResourceType.audio:
        return Icons.audiotrack;
      case ResourceType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getResourceTypeColor(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        return Colors.blue;
      case ResourceType.image:
        return Colors.green;
      case ResourceType.video:
        return Colors.purple;
      case ResourceType.audio:
        return Colors.orange;
      case ResourceType.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(ResourceStatus status) {
    switch (status) {
      case ResourceStatus.available:
        return Colors.green;
      case ResourceStatus.downloading:
        return Colors.blue;
      case ResourceStatus.downloaded:
        return Colors.grey;
      case ResourceStatus.failed:
        return Colors.red;
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

  

  void _showCreateEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final nameController = TextEditingController();
        final descController = TextEditingController();
        ResourceCategory selected = ResourceCategory.medical;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Coordination Entry',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ResourceCategory.values
                        .map(
                          (c) => ChoiceChip(
                            label: Text(c.name),
                            selected: selected == c,
                            onSelected: (_) => setState(() => selected = c),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item/Request',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Details'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final appState = Provider.of<AppState>(
                          context,
                          listen: false,
                        );
                        if (appState.currentUser != null) {
                          final resource = Resource(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text.isEmpty
                                ? _defaultNameForCategory(selected)
                                : nameController.text,
                            description: descController.text.isEmpty
                                ? _defaultDescForCategory(selected)
                                : descController.text,
                            type: _resourceTypeForCategory(selected),
                            filePath: '',
                            fileName: '',
                            fileSize: 0,
                            ownerId: appState.currentUser!.id,
                            createdAt: DateTime.now(),
                          );
                          appState.addResource(resource);
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _createQuickRequest(ResourceCategory category) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentUser == null) return;
    final resource = Resource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _defaultNameForCategory(category),
      description: _defaultDescForCategory(category),
      type: _resourceTypeForCategory(category),
      filePath: '',
      fileName: '',
      fileSize: 0,
      ownerId: appState.currentUser!.id,
      createdAt: DateTime.now(),
    );
    appState.addResource(resource);
  }

  

  String _defaultNameForCategory(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.medical:
        return 'Request: Medical supplies';
      case ResourceCategory.shelter:
        return 'Offer: Shelter space';
      case ResourceCategory.food:
        return 'Request: Food and water';
    }
  }

  String _defaultDescForCategory(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.medical:
        return 'First aid kit, bandages, antiseptic';
      case ResourceCategory.shelter:
        return 'Temporary shelter available';
      case ResourceCategory.food:
        return 'Non-perishable food and bottled water needed';
    }
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
}
