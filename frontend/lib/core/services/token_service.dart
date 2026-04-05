import 'package:shared_preferences/shared_preferences.dart';

/// Define the contract for token management.
/// Fully swappable, mockable, and satisfies the Interface Segregation/Dependency Inversion principles.
abstract class ITokenService {
  Future<void> saveTokens(String authToken, String refreshToken);
  String? getAuthToken();
  String? getRefreshToken();
  bool isLoggedIn();
  Future<void> clearTokens();
}

/// SharedPreferences implementation of ITokenService
class TokenServiceImpl implements ITokenService {
  // We require SharedPreferences at creation so we don't have to await it 
  // every time a synchronous get is called.
  final SharedPreferences _prefs;

  static const String _authKey = 'auth_token';
  static const String _refreshKey = 'refresh_token';

  TokenServiceImpl(this._prefs);

  @override
  Future<void> saveTokens(String authToken, String refreshToken) async {
    await _prefs.setString(_authKey, authToken);
    await _prefs.setString(_refreshKey, refreshToken);
  }

  @override
  String? getAuthToken() {
    return _prefs.getString(_authKey);
  }

  @override
  String? getRefreshToken() {
    return _prefs.getString(_refreshKey);
  }

  @override
  bool isLoggedIn() {
    return getAuthToken() != null;
  }

  @override
  Future<void> clearTokens() async {
    await _prefs.remove(_authKey);
    await _prefs.remove(_refreshKey);
  }
}
