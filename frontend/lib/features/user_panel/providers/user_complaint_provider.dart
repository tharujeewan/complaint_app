import 'package:flutter/material.dart';
import '../../../data/repositories/complaint_repository.dart';
import '../../../shared/models/complaint_model.dart';

class UserComplaintProvider with ChangeNotifier {
  final IComplaintRepository _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<ComplaintModel> _complaints = [];

  UserComplaintProvider(this._repository);

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

  Future<void> fetchMyComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getMyComplaints();
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

  Future<bool> createComplaint({
    required String title,
    required String description,
    String? location,
    List<Map<String, dynamic>>? files,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.createComplaint(
        title: title, 
        description: description, 
        location: location, 
        files: files
      );
      
      if (!hasListeners) return true;
      
      // Update local list
      if (res.data != null) {
        _complaints.insert(0, res.data!);
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

  void updateLocal(ComplaintModel updatedComplaint) {
    final index = _complaints.indexWhere((c) => c.id == updatedComplaint.id);
    if (index != -1) {
      _complaints[index] = updatedComplaint;
      notifyListeners();
    }
  }
}
