import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/repositories/complaint_repository.dart';
import '../../../shared/models/complaint_model.dart';

class UserComplaintProvider with ChangeNotifier {
  final IComplaintRepository _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  
  List<ComplaintModel> _allComplaints = [];
  List<ComplaintModel> _filteredList = [];
  List<ComplaintModel> _searchedList = [];
  String _searchQuery = '';
  Timer? _debounce;

  String _filterStatus = 'all';

  UserComplaintProvider(this._repository);

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<ComplaintModel> get complaints => _allComplaints;

  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;

  // Used by Issues screen (Filter ONLY)
  List<ComplaintModel> get filteredComplaints {
    if (_filterStatus == 'all') return _allComplaints;
    return _filteredList;
  }

  // Used by Home screen (Search ONLY)
  List<ComplaintModel> get searchedComplaints {
    if (_searchQuery.trim().isEmpty) return _allComplaints;
    return _searchedList;
  }

  void setSearchQuery(String q) {
    if (_searchQuery == q) return;
    _searchQuery = q;
    notifyListeners();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _applyRemoteSearch();
    });
  }

  void setFilterStatus(String status) {
    if (_filterStatus == status) return;
    _filterStatus = status;
    notifyListeners();
    _applyRemoteFilterOnly();
  }

  int get activeCount =>
      _allComplaints.where((c) => c.status != 'resolved').length;

  int get resolvedCount =>
      _allComplaints.where((c) => c.status == 'resolved').length;

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
      _allComplaints = result;
      
      // Separate remote calls so they stay independent
      if (_searchQuery.trim().isNotEmpty) {
        _searchedList = await _repository.getMyComplaints(search: _searchQuery.trim());
      }
      if (_filterStatus != 'all') {
        _filteredList = await _repository.getMyComplaints(status: _filterStatus);
      }
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

  Future<void> _applyRemoteSearch() async {
    if (_searchQuery.trim().isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getMyComplaints(search: _searchQuery.trim());
      if (!hasListeners) return;
      _searchedList = result;
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

  Future<void> _applyRemoteFilterOnly() async {
    if (_filterStatus == 'all') {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getMyComplaints(status: _filterStatus);
      if (!hasListeners) return;
      _filteredList = result;
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
        _allComplaints.insert(0, res.data!);
        _filteredList.insert(0, res.data!);
        _searchedList.insert(0, res.data!);
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
    final index = _allComplaints.indexWhere((c) => c.id == updatedComplaint.id);
    if (index != -1) {
      _allComplaints[index] = updatedComplaint;

      final fIndex = _filteredList.indexWhere((c) => c.id == updatedComplaint.id);
      if (fIndex != -1) _filteredList[fIndex] = updatedComplaint;

      final sIndex = _searchedList.indexWhere((c) => c.id == updatedComplaint.id);
      if (sIndex != -1) _searchedList[sIndex] = updatedComplaint;

      notifyListeners();
    }
  }

  void clear() {
    _allComplaints = [];
    _searchedList = [];
    _filteredList = [];
    _searchQuery = '';
    _filterStatus = 'all';
    notifyListeners();
  }
}
