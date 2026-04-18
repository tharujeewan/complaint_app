import 'dart:convert';
import '../../core/services/api_client.dart';
import '../../core/exceptions/typed_exceptions.dart';
import '../../core/models/api_response.dart';

// Assuming NotificationModel exists, or will be created dynamically
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['type'] != null ? json['type'].toString().toUpperCase() : 'Notification',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<ApiResponse<bool>> markAsRead(int id);
  Future<ApiResponse<bool>> markAllAsRead();
}

class NotificationRepositoryImpl implements INotificationRepository {
  final IApiClient _apiClient;

  NotificationRepositoryImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final res = await _apiClient.get('/notifications');
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode >= 500) throw ServerException('Failed to fetch notifications');

    final data = jsonDecode(res.body);
    if (data['success'] == true && data['notifications'] != null) {
      final list = data['notifications'] as List;
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<ApiResponse<bool>> markAsRead(int id) async {
    final res = await _apiClient.put('/notifications/$id/read', {});
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 404) throw NotFoundException('Notification not found');
    if (res.statusCode >= 500) throw ServerException();

    return ApiResponse<bool>.fromJson(jsonDecode(res.body), (json) => true);
  }

  @override
  Future<ApiResponse<bool>> markAllAsRead() async {
    final res = await _apiClient.put('/notifications/read-all', {});
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode >= 500) throw ServerException();

    return ApiResponse<bool>.fromJson(jsonDecode(res.body), (json) => true);
  }
}
