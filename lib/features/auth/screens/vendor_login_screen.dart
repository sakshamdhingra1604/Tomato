import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class VendorLoginScreen extends StatefulWidget {
  const VendorLoginScreen({Key? key}) : super(key: key);

  @override
  _VendorLoginScreenState createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  bool _obscurePassword = true;
  String? _selectedVendor;
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final List<String> _vendorOptions = [
    'Bunny\'s Kitchen',
    'Froot Shoot',
    'One Stop',
    'College Cafe',
    'Cafe14',
    'Nescafe',
    'Old Canteen',
    'Deepak\'s Cafe',
    'College Mess',
  ];

  final Map<String, String> _vendorIdMap = {
    'Bunny\'s Kitchen': 'bunny kitchen',
    'Froot Shoot': 'froot shoot',
    'One Stop': 'one stop',
    'Cafe14': 'cafe14',
    'Nescafe': 'nescafe',
    'Old Canteen': 'old canteen',
    'College Cafe': 'college cafe',
    'Deepak\'s Cafe': 'deepak\'s cafe',
    'College Mess': 'college mess',
  };

  void _vendorLogin() async {
    if (_selectedVendor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your cafe/canteen')),
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the password')),
      );
      return;
    }

    final String expectedPassword = '${_selectedVendor!.replaceAll(' ', '').replaceAll('\'', '')}@123';

    // Mock bypass for testing frontend Vendor Portal (allows CafeName@123 and 123456)
    if (_passwordController.text == expectedPassword || _passwordController.text == '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged in successfully as $_selectedVendor! 🍅'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.go('/vendor_dashboard');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final backendVendorId = _vendorIdMap[_selectedVendor] ?? _selectedVendor!.toLowerCase();
      final res = await _authService.vendorLogin(
        vendorId: backendVendorId,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged in successfully as ${res['vendor']['name']}! 🍅'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.go('/vendor_dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Icon(Icons.storefront, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              Text(
                'Vendor Portal',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your campus orders',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Dropdown for Vendor Selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Canteen / Cafe',
                  prefixIcon: Icon(Icons.store),
                ),
                value: _selectedVendor,
                items: _vendorOptions.map((String vendor) {
                  return DropdownMenuItem<String>(
                    value: vendor,
                    child: Text(vendor),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVendor = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _vendorLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Login as Vendor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
