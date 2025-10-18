import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  final bool isFirstTime;

  const ProfilePage({super.key, this.isFirstTime = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Dummy data initialization
  final _nameController = TextEditingController(text: "Emergency Responder");
  final _emailController = TextEditingController(text: "responder@beacon.com");
  final _addressController = TextEditingController(
    text: "123 Safety St, Secure City",
  );
  final _emergencyPhone1Controller = TextEditingController(text: "5551234567");
  final _emergencyPhone2Controller = TextEditingController(text: "5559876543");

  String? _selectedSex = 'Male';
  String? _selectedBloodType = 'O+';

  bool _isEditing = false;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFirstTime) {
      _isEditing = true;
      // Clear dummy data for first time experience
      _nameController.clear();
      _emailController.clear();
      _addressController.clear();
      _emergencyPhone1Controller.clear();
      _emergencyPhone2Controller.clear();
      _selectedSex = null;
      _selectedBloodType = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyPhone1Controller.dispose();
    _emergencyPhone2Controller.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Simulate saving delay
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saving profile...'),
            duration: Duration(milliseconds: 500),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully (UI Demo)'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.isFirstTime) {
          Navigator.pop(context); // Or navigate to dashboard
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1B3B5A), // Deep Navy
        foregroundColor: const Color(0xFFD4AF37), // Gold
        automaticallyImplyLeading: !widget.isFirstTime,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Voice commands not available in UI Demo"),
                ),
              );
            },
            icon: const Icon(Icons.mic, color: Color(0xFFD4AF37)),
            tooltip: 'Voice commands (English)',
          ),
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFF1B3B5A),
                            child: Text(
                              _nameController.text.isNotEmpty
                                  ? _nameController.text[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _nameController.text.isEmpty
                                ? 'New User'
                                : _nameController.text,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _emailController.text.isEmpty
                                ? 'email@example.com'
                                : _emailController.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // First-time user banner
                    if (widget.isFirstTime) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFFD4AF37),
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Complete Your Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Please fill in your details to continue using BEACON',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Profile Form
                    _buildFormField(
                      label: 'Name',
                      controller: _nameController,
                      enabled: _isEditing,
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 20),

                    _buildFormField(
                      label: 'Email',
                      controller: _emailController,
                      enabled: _isEditing,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    // Sex dropdown
                    _buildDropdownField(
                      label: 'Sex',
                      value: _selectedSex,
                      items: ['Male', 'Female'],
                      enabled: _isEditing,
                      icon: Icons.person_outline,
                      onChanged: (value) {
                        setState(() {
                          _selectedSex = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildFormField(
                      label: 'Address',
                      controller: _addressController,
                      enabled: _isEditing,
                      icon: Icons.location_on,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),

                    _buildFormField(
                      label: 'Emergency Phone 1',
                      controller: _emergencyPhone1Controller,
                      enabled: _isEditing,
                      icon: Icons.phone,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    const SizedBox(height: 20),

                    _buildFormField(
                      label: 'Emergency Phone 2',
                      controller: _emergencyPhone2Controller,
                      enabled: _isEditing,
                      icon: Icons.phone,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    const SizedBox(height: 20),

                    // Blood Type dropdown
                    _buildDropdownField(
                      label: 'Blood Type',
                      value: _selectedBloodType,
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                      enabled: _isEditing,
                      icon: Icons.bloodtype,
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 40),

                    // Profile Stats
                    _buildStatsCard(),

                    const SizedBox(height: 40),

                    // Action Buttons
                    if (_isEditing) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101820),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              // In a real app, revert text controllers here
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFD4AF37)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFC0C0C0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C3E50)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            filled: true,
            fillColor: enabled
                ? const Color(0xFF1B2631)
                : const Color(0xFF101820),
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
          validator: (value) {
            if (label == 'Name' || label == 'Email') {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
            }
            if (label == 'Email' && !value!.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2631),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C3E50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.message,
                label: 'Messages',
                value: '12',
              ),
              _buildStatItem(icon: Icons.devices, label: 'Devices', value: '3'),
              _buildStatItem(icon: Icons.share, label: 'Resources', value: '4'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required bool enabled,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: const Color(0xFF1B2631),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFC0C0C0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C3E50)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            filled: true,
            fillColor: enabled
                ? const Color(0xFF1B2631)
                : const Color(0xFF101820),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
