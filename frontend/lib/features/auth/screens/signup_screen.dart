import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to Home
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.primaryTeal)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              CustomTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              CustomTextField(
                label: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? 'Invalid Email' : null,
              ),

              CustomTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isConfirmPasswordVisible,
                onTogglePassword: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (v != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),

              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
              ),

              const SizedBox(height: 20),
              CustomButton(
                text: 'Sign Up',
                isLoading: _isLoading,
                onPressed: _handleSignup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}