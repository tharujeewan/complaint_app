import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class LocalCareApp extends StatelessWidget {
  const LocalCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
