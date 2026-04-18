import 'package:flutter/material.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final INotificationRepository _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];

  NotificationProvider(this._repository);

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getNotifications();
      if (!hasListeners) return;
      _notifications = result;
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

  Future<bool> markAsRead(int id) async {
    // Optimistic cache update immediately for snappy UI
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      final old = _notifications[index];
      _notifications[index] = NotificationModel(
        id: old.id,
        title: old.title,
        message: old.message,
        isRead: true,
        createdAt: old.createdAt,
      );
      notifyListeners();
      
      try {
        await _repository.markAsRead(id);
        return true;
      } catch (e) {
        // Revert on failure
        if (!hasListeners) return false;
        _notifications[index] = old;
        _errorMessage = e.toString();
        notifyListeners();
        return false;
      }
    }
    return true;
  }

  Future<bool> markAllAsRead() async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.markAllAsRead();
      if (!hasListeners) return true;
      
      // Update locally
      _notifications = _notifications.map((n) {
        if (n.isRead) return n;
        return NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
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

  void clear() {
    _notifications = [];
    notifyListeners();
  }
}
