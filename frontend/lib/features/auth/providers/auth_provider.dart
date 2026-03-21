import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../shared/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get user => _user;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isAuthenticated = await AuthService.isLoggedIn();
    if (_isAuthenticated) {
      await fetchProfile();
    }
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      final data = await AuthService.getProfile();
      _user = UserModel.fromJson(data);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false; // if token is invalid, log out
      await AuthService.logout();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.login(email, password);
      _isAuthenticated = true;
      await fetchProfile(); // Fetch user data immediately after login
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.register(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
