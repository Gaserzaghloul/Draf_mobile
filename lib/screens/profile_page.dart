import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/voice_command_service.dart';

class ProfilePage extends StatefulWidget {
  final bool isFirstTime;

  const ProfilePage({super.key, this.isFirstTime = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyPhone1Controller = TextEditingController();
  final _emergencyPhone2Controller = TextEditingController();
  String? _selectedSex;
  String? _selectedBloodType;
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // If first time, automatically enable editing
    if (widget.isFirstTime) {
      _isEditing = true;
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

  void _loadUserProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      _nameController.text = userProvider.currentUser!.name;
      _emailController.text = userProvider.currentUser!.email;
      _addressController.text = userProvider.currentUser!.address ?? '';
      _emergencyPhone1Controller.text =
          userProvider.currentUser!.emergencyPhone1 ?? '';
      _emergencyPhone2Controller.text =
          userProvider.currentUser!.emergencyPhone2 ?? '';
      _selectedSex = userProvider.currentUser!.sex;
      _selectedBloodType = userProvider.currentUser!.bloodType;
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.currentUser != null) {
        try {
          final updatedUser = userProvider.currentUser!.copyWith(
            name: _nameController.text,
            email: _emailController.text,
            sex: _selectedSex,
            address: _addressController.text.isEmpty
                ? null
                : _addressController.text,
            emergencyPhone1: _emergencyPhone1Controller.text.isEmpty
                ? null
                : _emergencyPhone1Controller.text,
            emergencyPhone2: _emergencyPhone2Controller.text.isEmpty
                ? null
                : _emergencyPhone2Controller.text,
            bloodType: _selectedBloodType,
            updatedAt: DateTime.now(),
            isProfileComplete: true, // Mark profile as complete
          );

          await userProvider.updateUser(updatedUser);

          if (mounted) {
            setState(() {
              _isEditing = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // If first time, navigate to landing page after saving
            if (widget.isFirstTime) {
              Navigator.pushReplacementNamed(context, '/');
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating profile: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading:
            !widget.isFirstTime, // Disable back button for first-time users
        actions: [
          IconButton(
            onPressed: () async {
              // Initialize voice service if needed (though usually done at app start)
              await VoiceCommandService().initialize();

              if (context.mounted) {
                await VoiceCommandService().startListening(
                  context: context,
                  intents: {
                    'start editing': (ctx) async {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    'save profile': (ctx) async => _saveProfile(),
                    'cancel editing': (ctx) async {
                      setState(() {
                        _isEditing = false;
                        _loadUserProfile();
                      });
                    },
                  },
                );
              }
            },
            icon: const Icon(Icons.mic),
            tooltip: 'Voice commands (English)',
          ),
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
              ),
            );
          }

          if (userProvider.currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No user profile found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please restart the app to create a profile',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
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
                          backgroundColor: const Color(0xFF1E3A8A),
                          child: Text(
                            userProvider.currentUser!.name.isNotEmpty
                                ? userProvider.currentUser!.name[0]
                                      .toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userProvider.currentUser!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userProvider.currentUser!.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
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
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete Your Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please fill in your details to continue using BEACON',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange[800],
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
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                            _loadUserProfile(); // Reset to original values
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
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
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
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
            if (label.contains('Phone')) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Phone must contain only digits';
                }
                if (value.length < 10) {
                  return 'Phone number too short';
                }
              }
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.message,
                label: 'Messages',
                value: '0',
              ),
              _buildStatItem(icon: Icons.devices, label: 'Devices', value: '0'),
              _buildStatItem(icon: Icons.share, label: 'Resources', value: '0'),
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
        Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          // Using initialValue as value is deprecated in newer Flutter versions
          // Ensure key is updated if value changes externally to force rebuild
          key: ValueKey(value),
          initialValue: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
