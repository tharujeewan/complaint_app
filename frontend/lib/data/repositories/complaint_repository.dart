import 'dart:convert';
import '../../../shared/models/complaint_model.dart';
import '../../core/services/api_client.dart';
import '../../core/exceptions/typed_exceptions.dart';
import '../../core/models/api_response.dart';

abstract class IComplaintRepository {
  Future<List<ComplaintModel>> getMyComplaints({int page = 1, int limit = 20});
  Future<ApiResponse<ComplaintModel>> getComplaintById(int id);
  Future<ApiResponse<ComplaintModel>> createComplaint({
    required String title,
    required String description,
    String? location,
    List<Map<String, dynamic>>? files,
  });
  Future<ApiResponse<bool>> deleteComplaint(int id);
}

class ComplaintRepositoryImpl implements IComplaintRepository {
  final IApiClient _apiClient;

  ComplaintRepositoryImpl(this._apiClient);

  @override
  Future<List<ComplaintModel>> getMyComplaints({int page = 1, int limit = 20}) async {
    // Current backend doesn't seem to support pagination via query params yet in get '/complaints', 
    // but we pass them for future-proofing as requested.
    final res = await _apiClient.get('/complaints?page=$page&limit=$limit');
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode >= 500) throw ServerException('Failed to fetch complaints');
    
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['complaints'] != null) {
      final list = data['complaints'] as List;
      return list.map((e) => ComplaintModel.fromJson(e)).toList();
    }
    
    return [];
  }

  @override
  Future<ApiResponse<ComplaintModel>> getComplaintById(int id) async {
    final res = await _apiClient.get('/complaints/$id');
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 404) throw NotFoundException('Complaint not found');
    if (res.statusCode >= 500) throw ServerException();
    
    final data = jsonDecode(res.body);
    return ApiResponse<ComplaintModel>.fromJson(
      data,
      (json) => ComplaintModel.fromJson(data['complaint']),
    );
  }

  @override
  Future<ApiResponse<ComplaintModel>> createComplaint({
    required String title,
    required String description,
    String? location,
    List<Map<String, dynamic>>? files,
  }) async {
    final fields = {
      'title': title,
      'description': description,
    };
    if (location != null && location.isNotEmpty) {
      fields['location'] = location;
    }

    final res = await _apiClient.postMultipart(
      '/complaints',
      fields,
      files: files,
      fileField: 'photo',
    );

    final responseString = await res.stream.bytesToString();
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 400) throw BadRequestException('Invalid complaint data');
    if (res.statusCode >= 500) throw ServerException('Failed to submit complaint');

    final data = jsonDecode(responseString);
    return ApiResponse<ComplaintModel>.fromJson(
      data, 
      (json) => ComplaintModel.fromJson(data['complaint'] ?? data)
    );
  }

  @override
  Future<ApiResponse<bool>> deleteComplaint(int id) async {
    final res = await _apiClient.delete('/complaints/$id');
    
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 404) throw NotFoundException();
    if (res.statusCode >= 500) throw ServerException();
    
    return ApiResponse<bool>.fromJson(jsonDecode(res.body), (json) => true);
  }
}
