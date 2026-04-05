import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/token_service.dart';
import '../services/api_client.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/complaint_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/notification_repository.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/user_profile_provider.dart';
import '../../features/user_panel/providers/user_complaint_provider.dart';
import '../../features/admin_panel/providers/admin_complaint_provider.dart';
import '../../features/admin_panel/providers/admin_user_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─────────────────────────────────────────────────────────────
  // Layer 1 — Core (Singletons)
  // ─────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  
  // SharedPreferences is inherently a singleton instance we awaited.
  // TokenService and ApiClient live for the entire app lifecycle.
  sl.registerSingleton<ITokenService>(TokenServiceImpl(prefs));
  sl.registerSingleton<IApiClient>(ApiClientImpl(sl<ITokenService>()));

  // ─────────────────────────────────────────────────────────────
  // Layer 2 — Repositories (Lazy Singletons)
  // ─────────────────────────────────────────────────────────────
  // Instantiated only when first requested to save memory on app start.
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<IApiClient>(), sl<ITokenService>()),
  );
  sl.registerLazySingleton<IComplaintRepository>(
    () => ComplaintRepositoryImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<IAdminRepository>(
    () => AdminRepositoryImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(sl<IApiClient>()),
  );

  // ─────────────────────────────────────────────────────────────
  // Layer 3 — Providers (Factories)
  // ─────────────────────────────────────────────────────────────
  // We register these as factories so multi_provider can instantiate them cleanly,
  // returning a fresh instance if requested independently.
  sl.registerFactory<AuthProvider>(
    () => AuthProvider(sl<IAuthRepository>()),
  );
  sl.registerFactory<UserProfileProvider>(
    () => UserProfileProvider(sl<IAuthRepository>(), sl<ITokenService>()),
  );
  sl.registerFactory<UserComplaintProvider>(
    () => UserComplaintProvider(sl<IComplaintRepository>()),
  );
  sl.registerFactory<AdminComplaintProvider>(
    () => AdminComplaintProvider(sl<IAdminRepository>()),
  );
  sl.registerFactory<AdminUserProvider>(
    () => AdminUserProvider(sl<IAdminRepository>()),
  );
  sl.registerFactory<NotificationProvider>(
    () => NotificationProvider(sl<INotificationRepository>()),
  );
}
