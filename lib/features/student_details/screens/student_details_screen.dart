import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/services/auth_service.dart';

class StudentDetailsScreen extends StatefulWidget {
  const StudentDetailsScreen({Key? key}) : super(key: key);

  @override
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Mandatory
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  // College Dropdown
  String _selectedCollege = 'P.I.E.T. (Panipat Institute of Engg. & Tech.)';

  final List<Map<String, dynamic>> _colleges = [
    {
      'name': 'P.I.E.T. (Panipat Institute of Engg. & Tech.)',
      'enabled': true,
    },
    {
      'name': 'IIT Delhi (Coming Soon)',
      'enabled': false,
    },
    {
      'name': 'NIT Kurukshetra (Coming Soon)',
      'enabled': false,
    },
    {
      'name': 'PEC Chandigarh (Coming Soon)',
      'enabled': false,
    },
  ];

  // Optional
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  void _submitDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.updateProfile(
          name: _nameController.text.trim(),
          college: _selectedCollege,
          rollNo: _rollNoController.text.trim(),
          year: _yearController.text.trim(),
          branch: _branchController.text.trim(),
          block: _blockController.text.trim(),
          classRoom: _classController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile completed successfully! 🍅'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save details: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isMandatory = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: isMandatory ? '$label *' : label,
        ),
        validator: isMandatory
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Don't allow back to signup easily
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Just a few more details...',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your college and help us locate you quickly on campus.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                // College Selection Dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCollege,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select College *',
                      prefixIcon: Icon(Icons.account_balance_rounded),
                    ),
                    items: _colleges.map((college) {
                      final bool isEnabled = college['enabled'] as bool;
                      return DropdownMenuItem<String>(
                        value: college['name'] as String,
                        enabled: isEnabled,
                        child: Text(
                          college['name'] as String,
                          style: TextStyle(
                            color: isEnabled
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).disabledColor,
                            fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCollege = newValue;
                        });
                      }
                    },
                  ),
                ),
                
                _buildTextField('Full Name', _nameController, isMandatory: true),
                _buildTextField('Roll No.', _rollNoController, isMandatory: true),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField('Year', _yearController, isMandatory: true, type: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Branch', _branchController, isMandatory: true)),
                  ],
                ),
                
                const Divider(height: 40),
                Text(
                  'Optional Information',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField('Block/Hostel', _blockController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Class/Room', _classController)),
                  ],
                ),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitDetails,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Continue to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
