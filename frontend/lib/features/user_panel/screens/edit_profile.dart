import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../widgets/custom_info_card.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  void _showUpdateNameModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _UpdateNameForm(),
    );
  }

  void _showUpdatePasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _UpdatePasswordForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Change Name Option
            CustomInfoCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.badge_outlined, color: AppColors.primaryTeal),
                title: const Text(
                  'Change Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => _showUpdateNameModal(context),
              ),
            ),

            // Change Password Option
            CustomInfoCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: AppColors.primaryTeal),
                title: const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => _showUpdatePasswordModal(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Update Name Form
// -----------------------------------------------------------------------------

class _UpdateNameForm extends StatefulWidget {
  const _UpdateNameForm();

  @override
  State<_UpdateNameForm> createState() => _UpdateNameFormState();
}

class _UpdateNameFormState extends State<_UpdateNameForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProfileProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final user = provider.user;
    if (user == null) return;

    final success = await provider.updateProfile(user.id, {
      'name': _nameController.text.trim(),
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update name'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Change Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryTeal),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Consumer<UserProfileProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Update Password Form
// -----------------------------------------------------------------------------

class _UpdatePasswordForm extends StatefulWidget {
  const _UpdatePasswordForm();

  @override
  State<_UpdatePasswordForm> createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends State<_UpdatePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final user = provider.user;
    if (user == null) return;

    final success = await provider.updateProfile(user.id, {
      'currentPassword': _currentPasswordController.text,
      'newPassword': _newPasswordController.text,
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Current Password
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                  color: AppColors.primaryTeal,
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryTeal),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // New Password
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                  color: AppColors.primaryTeal,
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryTeal),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                // Check if it matches backend validation: at least 1 uppercase, 1 lowercase, 1 number
                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                  return 'Must contain uppercase, lowercase & number';
                }
                if (value == _currentPasswordController.text) {
                  return 'New password must be different from current';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  color: AppColors.primaryTeal,
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryTeal),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            Consumer<UserProfileProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
