import 'dart:convert';
import 'dart:io';
import '../../../core/services/api_service.dart';
import '../../../shared/models/complaint_model.dart';

class ComplaintService {
  static Future<Map<String, dynamic>> createComplaint({
    required String title,
    required String description,
    String? location,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final fields = {
      'title': title,
      'description': description,
    };

    if (location != null && location.isNotEmpty) {
      fields['location'] = location;
    }

    final response = await ApiService.postMultipart(
      '/complaints',
      fields,
      fileBytes: fileBytes,
      fileName: fileName,
      fileField: 'photo',
    );

    final responseString = await response.stream.bytesToString();
    final data = jsonDecode(responseString);

    if (response.statusCode == 201 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create complaint');
    }
  }

  static Future<List<ComplaintModel>> getComplaints() async {
    final response = await ApiService.get('/complaints');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['complaints'] != null) {
        final list = decoded['complaints'] as List;
        return list.map((e) => ComplaintModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load complaints from database');
    }
  }
}
