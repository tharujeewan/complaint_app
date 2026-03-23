import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/services/auth_service.dart';

class ApiService {
  // 🔁 Toggle this when switching device
  static const bool isPhysicalDevice = true;

  // 🔌 URLs
  static const String _physicalBaseUrl = "http://192.168.1.4:5000/api";
  static const String _emulatorBaseUrl = "http://10.0.2.2:5000/api";

  static String get baseUrl {
    return isPhysicalDevice ? _physicalBaseUrl : _emulatorBaseUrl;
  }

  // 🔐 Headers with token
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 🔁 Handle token refresh automatically
  static Future<http.Response> _handleRequest(
    Future<http.Response> Function(Map<String, String>) requestFunc,
  ) async {
    final headers = await _getHeaders();
    var response = await requestFunc(headers);

    if (response.statusCode == 401) {
      final refreshSuccess = await AuthService.refreshToken();

      if (refreshSuccess) {
        final newHeaders = await _getHeaders();
        response = await requestFunc(newHeaders);
      }
    }

    return response;
  }

  // 📤 POST
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return http.post(url, headers: headers, body: jsonEncode(body));
    });
  }

  // 📥 GET
  static Future<http.Response> get(String endpoint) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return http.get(url, headers: headers);
    });
  }

  // ✏️ PUT
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return http.put(url, headers: headers, body: jsonEncode(body));
    });
  }

  // ❌ DELETE
  static Future<http.Response> delete(String endpoint) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return http.delete(url, headers: headers);
    });
  }

  // 📸 Multipart (Image Upload)
  static Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<int>? fileBytes,
    String? fileName,
    String fileField = 'photo',
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');

    Future<http.StreamedResponse> sendRequest(
        Map<String, String> authHeaders) async {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(authHeaders);
      request.fields.addAll(fields);

      if (fileBytes != null && fileName != null) {
        // Derive MIME type from file extension so multer accepts it as an image
        final ext = fileName.split('.').last.toLowerCase();
        final mimeSubtype = ext == 'jpg' ? 'jpeg' : ext; // jpg -> jpeg
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
            contentType: MediaType('image', mimeSubtype),
          ),
        );
      }

      return await request.send();
    }

    var response = await sendRequest(headers);

    if (response.statusCode == 401) {
      final refreshSuccess = await AuthService.refreshToken();

      if (refreshSuccess) {
        final newHeaders = await _getHeaders();
        response = await sendRequest(newHeaders);
      }
    }

    return response;
  }
}
