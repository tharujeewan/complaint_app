import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../../../core/services/token_service.dart';
import '../../../core/di/injection_container.dart';
import '../../../app/routes.dart';
import '../../../core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Allow the first frame to render before running checks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() async {
    final tokenService = sl<ITokenService>();
    if (!tokenService.isLoggedIn()) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      return;
    }

    if (!mounted) return;
    
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    
    // If it's already fetched, we can route immediately
    if (profileProvider.user != null) {
      _routeUser(profileProvider.user!.role);
      return;
    }

    // Wait until it finishes loading, or if it failed
    profileProvider.addListener(_profileListener);
    
    // If it's not currently loading and it doesn't have a user, trigger fetch
    if (!profileProvider.isLoading && profileProvider.user == null) {
      await profileProvider.fetchProfile();
    }
  }

  void _profileListener() {
    if (!mounted) return;
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    if (!profileProvider.isLoading) {
      profileProvider.removeListener(_profileListener);
      
      if (profileProvider.user != null) {
        _routeUser(profileProvider.user!.role);
      } else {
        // Fetch failed (token likely expired or network issue)
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  void _routeUser(String? role) {
    if (role?.toLowerCase() == 'admin') {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.userHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: AppColors.primaryTeal,
            ),
          ],
        ),
      ),
    );
  }
}
