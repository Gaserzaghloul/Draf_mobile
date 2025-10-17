import 'package:flutter/material.dart';

class ResourceSharingLayoutOnly extends StatelessWidget {
  const ResourceSharingLayoutOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resource Coordination')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEntrySheet(context),
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(children: [
        _buildCategoriesBar(),
        Expanded(child: _buildListPlaceholder()),
      ]),
    );
  }

  Widget _buildCategoriesBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: const Row(
        children: [
          _CategoryChip(icon: Icons.medical_services, label: 'MEDICAL', color: Colors.red),
          SizedBox(width: 8),
          _CategoryChip(icon: Icons.house, label: 'SHELTER', color: Colors.orange),
          SizedBox(width: 8),
          _CategoryChip(icon: Icons.restaurant, label: 'FOOD', color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildListPlaceholder() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => const _ResourceCard(),
    );
  }

  void _showCreateEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Coordination Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: const [
                    ChoiceChip(label: Text('medical'), selected: true),
                    ChoiceChip(label: Text('shelter'), selected: false),
                    ChoiceChip(label: Text('food'), selected: false),
                  ],
                ),
                const SizedBox(height: 12),
                const TextField(decoration: InputDecoration(labelText: 'Item/Request')),
                const SizedBox(height: 8),
                const TextField(decoration: InputDecoration(labelText: 'Details')),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Create')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _CategoryChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.4))),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.category, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Item name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Item description', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
            child: const Text('AVAILABLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.person, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text('Owner: user-id', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const Spacer(),
          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text('Today', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.volunteer_activism, size: 16), label: const Text('Offer Help'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1E3A8A))),
          const SizedBox(width: 8),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.check_circle, size: 16), label: const Text('Mark Fulfilled'),
              style: TextButton.styleFrom(foregroundColor: Colors.green)),
        ]),
      ]),
    );
  }
}


