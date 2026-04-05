import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final IAuthRepository _repository;

  bool _isSubmitting = false;
  String? _errorMessage;
  UserModel? _user;

  AuthProvider(this._repository);

  bool get isSubmitting => _isSubmitting;
  bool get isLoading => _isSubmitting;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.login(email, password);
      if (res.success) {
        try {
          final profileRes = await _repository.getProfile();
          if (profileRes.success) {
            _user = profileRes.data;
          }
        } catch (e) {
             // Handle profile fetch error gracefully if needed
        }
      }
      return res.success;
    } catch (e) {
      if (!hasListeners) return false;
      _errorMessage = e.toString();
      return false;
    } finally {
      if (hasListeners) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.register(name, email, password);
      return res.success;
    } catch (e) {
      if (!hasListeners) return false;
      _errorMessage = e.toString();
      return false;
    } finally {
      if (hasListeners) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }
}
