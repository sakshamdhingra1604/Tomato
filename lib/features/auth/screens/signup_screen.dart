import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _selectedRole = 'student';

  double _passwordStrength = 0;
  String _strengthLabel = 'Weak';
  Color _strengthColor = Colors.red;

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      if (strength < 0.5) {
        _strengthLabel = 'Weak';
        _strengthColor = Colors.red;
      } else if (strength < 0.75) {
        _strengthLabel = 'Medium';
        _strengthColor = Colors.orange;
      } else {
        _strengthLabel = 'Strong';
        _strengthColor = Colors.green;
      }
    });
  }

  void _signup() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final name = email.split('@')[0]; // Extract name from email prefix

      final res = await _authService.signup(
        name: name,
        email: email,
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully as ${res['user']['name']}!')),
        );
        // Navigate to complete profile
        context.go('/student_details');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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

  void _signupWithGoogle() {
    // TODO: Implement backend integration for Google Sign-Up here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Signup logic goes here')),
    );
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
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Join the campus delivery network',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'student'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'student'
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedRole == 'student'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor.withOpacity(0.3),
                            width: _selectedRole == 'student' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.restaurant_rounded,
                              color: _selectedRole == 'student'
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Student / Orderer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _selectedRole == 'student'
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'deliverer'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'deliverer'
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedRole == 'deliverer'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor.withOpacity(0.3),
                            width: _selectedRole == 'deliverer' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_walk_rounded,
                              color: _selectedRole == 'deliverer'
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Deliverer / Rider',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _selectedRole == 'deliverer'
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'College Email',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: _checkPasswordStrength,
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
              const SizedBox(height: 8),
              // Password Strength Indicator
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      backgroundColor: Theme.of(context).disabledColor.withOpacity(0.2),
                      color: _strengthColor,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _strengthLabel,
                    style: TextStyle(color: _strengthColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_reset),
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
                onPressed: _isLoading ? null : _signup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _signupWithGoogle,
                icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                label: const Text('Sign up with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Login'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Temporary Bypass for Testing
                  context.go('/student_details');
                },
                child: const Text('Bypass Testing', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
