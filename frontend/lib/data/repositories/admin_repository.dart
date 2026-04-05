import 'dart:convert';
import '../../../shared/models/complaint_model.dart';
import '../../../shared/models/user_model.dart';
import '../../core/services/api_client.dart';
import '../../core/exceptions/typed_exceptions.dart';
import '../../core/models/api_response.dart';

abstract class IAdminRepository {
  Future<List<ComplaintModel>> getAllComplaints({int page = 1, int limit = 50});
  Future<ApiResponse<ComplaintModel>> updateStatus(int id, String status);
  Future<List<UserModel>> getUsers();
  Future<ApiResponse<bool>> blockUser(int id);
}

class AdminRepositoryImpl implements IAdminRepository {
  final IApiClient _apiClient;

  AdminRepositoryImpl(this._apiClient);

  @override
  Future<List<ComplaintModel>> getAllComplaints({int page = 1, int limit = 50}) async {
    final res = await _apiClient.get('/admin/complaints?page=$page&limit=$limit');
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 403) throw UnauthorizedException('Admin access required');
    if (res.statusCode >= 500) throw ServerException('Failed to fetch all complaints');

    final data = jsonDecode(res.body);
    if (data['success'] == true && data['complaints'] != null) {
      final list = data['complaints'] as List;
      return list.map((e) => ComplaintModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<ApiResponse<ComplaintModel>> updateStatus(int id, String status) async {
    final res = await _apiClient.put('/complaints/$id/status', {
      'status': status,
    });

    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 403) throw UnauthorizedException('Admin access required');
    if (res.statusCode == 404) throw NotFoundException('Complaint not found');
    if (res.statusCode >= 500) throw ServerException('Failed to update status');

    final data = jsonDecode(res.body);
    return ApiResponse<ComplaintModel>.fromJson(
      data,
      (json) => ComplaintModel.fromJson(data['complaint'] ?? data),
    );
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final res = await _apiClient.get('/admin/users');
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 403) throw UnauthorizedException('Admin access required');
    if (res.statusCode >= 500) throw ServerException('Failed to fetch users');

    final data = jsonDecode(res.body);
    if (data['success'] == true && data['users'] != null) {
      final list = data['users'] as List;
      return list.map((e) => UserModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<ApiResponse<bool>> blockUser(int id) async {
    final res = await _apiClient.put('/admin/users/$id/block', {});

    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 403) throw UnauthorizedException('Admin access required');
    if (res.statusCode == 404) throw NotFoundException('User not found');
    if (res.statusCode >= 500) throw ServerException('Failed to block user');

    return ApiResponse<bool>.fromJson(jsonDecode(res.body), (json) => true);
  }
}
