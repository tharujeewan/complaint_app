import 'package:flutter/material.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/user_panel/screens/user_home_screen.dart';
import '../features/admin_panel/screens/admin_dashboard_screen.dart';

class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // User Panel
  static const String userHome = '/user-home';

  // Admin Panel
  static const String adminDashboard = '/admin-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case userHome:
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
