import 'package:flutter/material.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../shared/models/user_model.dart';

class AdminUserProvider with ChangeNotifier {
  final IAdminRepository _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<UserModel> _users = [];

  AdminUserProvider(this._repository);

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<UserModel> get users => _users;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getUsers();
      if (!hasListeners) return;
      _users = result;
    } catch (e) {
      if (!hasListeners) return;
      _errorMessage = e.toString();
    } finally {
      if (hasListeners) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> blockUser(int id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.blockUser(id);
      return true;
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
}
