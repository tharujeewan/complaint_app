import 'package:flutter/material.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../shared/models/complaint_model.dart';
import '../../../shared/models/user_model.dart';

class AdminComplaintProvider with ChangeNotifier {
  final IAdminRepository _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<ComplaintModel> _complaints = [];

  AdminComplaintProvider(this._repository);

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<ComplaintModel> get complaints => _complaints;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> fetchAllComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getAllComplaints(page: 1, limit: 100);
      if (!hasListeners) return;
      _complaints = result;
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

  Future<bool> updateStatus({required int id, required String status}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.updateStatus(id, status);
      if (!hasListeners) return true;

      // Update local list directly without refetching from server
      if (res.data != null) {
        final index = _complaints.indexWhere((c) => c.id == id);
        if (index != -1) {
          _complaints[index] = res.data!;
        }
      }
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
