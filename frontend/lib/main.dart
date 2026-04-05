import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/user_profile_provider.dart';
import 'features/user_panel/providers/user_complaint_provider.dart';
import 'features/admin_panel/providers/admin_complaint_provider.dart';
import 'features/admin_panel/providers/admin_user_provider.dart';
import 'features/notifications/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection container
  await initDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => sl<UserProfileProvider>()),
        ChangeNotifierProvider(create: (_) => sl<UserComplaintProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AdminComplaintProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AdminUserProvider>()),
        ChangeNotifierProvider(create: (_) => sl<NotificationProvider>()),
      ],
      child: const LocalCareApp(),
    ),
  );
}
