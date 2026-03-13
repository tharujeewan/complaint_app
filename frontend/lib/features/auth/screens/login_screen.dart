import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../app/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, AppRoutes.userHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Logo & Title
                  Image.asset(
                    'assets/images/logo.png',
                    // height: 200,
                    // width: 200,
                  ),
                  const SizedBox(height: 60),
                  
                  // Clean Custom Fields
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Enter email' : null,
                  ),
                  
                  CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    validator: (val) => val!.length < 6 ? 'Password too short' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Custom Button with Loading state built-in
                  CustomButton(
                    text: 'Login',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                    child: const Text('Don\'t have an account? Sign Up', style: TextStyle(color: AppColors.primaryTeal)),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}