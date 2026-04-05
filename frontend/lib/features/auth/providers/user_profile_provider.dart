import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/services/token_service.dart';

class UserProfileProvider with ChangeNotifier {
  final IAuthRepository _repository;
  final ITokenService _tokenService;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  UserProfileProvider(this._repository, this._tokenService) {
    if (_tokenService.isLoggedIn()) {
      fetchProfile();
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.getProfile();
      if (!hasListeners) return;
      _user = res.data;
    } catch (e) {
      if (!hasListeners) return;
      _errorMessage = e.toString();
      _user = null;
      await _tokenService.clearTokens();
    } finally {
      if (hasListeners) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearProfile() {
    _user = null;
    notifyListeners();
  }
}
