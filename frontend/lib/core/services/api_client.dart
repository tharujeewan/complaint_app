import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'token_service.dart';
import '../exceptions/typed_exceptions.dart';

abstract class IApiClient {
  Future<http.Response> get(String endpoint);
  Future<http.Response> post(String endpoint, Map<String, dynamic> body);
  Future<http.Response> put(String endpoint, Map<String, dynamic> body);
  Future<http.Response> delete(String endpoint);
  Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<Map<String, dynamic>>? files,
    String fileField = 'photos',
  });
}

class ApiClientImpl implements IApiClient {
  final ITokenService _tokenService;

  static const bool isPhysicalDevice = false;
  static const String _physicalBaseUrl = "http://192.168.1.11:5000/api";
  static const String _emulatorBaseUrl = "http://10.0.2.2:5000/api";

  ApiClientImpl(this._tokenService);

  String get baseUrl => isPhysicalDevice ? _physicalBaseUrl : _emulatorBaseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = _tokenService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Internal refresh logic ensuring the ApiClient doesn't depend on AuthProvider/AuthService
  Future<bool> _refreshToken() async {
    final refreshToken = _tokenService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/auth/refresh');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _tokenService.saveTokens(data['accessToken'], data['refreshToken']);
          return true;
        }
      }
    } catch (_) {}

    await _tokenService.clearTokens();
    return false;
  }

  Future<T> _handleRequest<T>(
    Future<T> Function(Map<String, String>) requestFunc,
  ) async {
    try {
      final headers = await _getHeaders();
      var response = await requestFunc(headers);

      // Check for 401 via generic response handling since we process both Response and StreamedResponse
      bool isUnauthorized = false;
      if (response is http.Response && response.statusCode == 401) {
        isUnauthorized = true;
      } else if (response is http.StreamedResponse && response.statusCode == 401) {
        isUnauthorized = true;
      }

      if (isUnauthorized) {
        final refreshSuccess = await _refreshToken();

        if (refreshSuccess) {
          final newHeaders = await _getHeaders();
          response = await requestFunc(newHeaders);
        } else {
          throw UnauthorizedException("Session expired, please log in again.");
        }
      }

      return response;
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    }
  }

  @override
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.post(url, headers: headers, body: jsonEncode(body));
    });
  }

  @override
  Future<http.Response> get(String endpoint) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.get(url, headers: headers);
    });
  }

  @override
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.put(url, headers: headers, body: jsonEncode(body));
    });
  }

  @override
  Future<http.Response> delete(String endpoint) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.delete(url, headers: headers);
    });
  }

  @override
  Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<Map<String, dynamic>>? files,
    String fileField = 'photos',
  }) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (files != null && files.isNotEmpty) {
        for (var fileMap in files) {
          final bytes = fileMap['bytes'] as List<int>;
          final fileName = fileMap['fileName'] as String;
          final ext = fileName.split('.').last.toLowerCase();
          final mimeSubtype = ext == 'jpg' ? 'jpeg' : ext;
          request.files.add(
            http.MultipartFile.fromBytes(
              fileField,
              bytes,
              filename: fileName,
              contentType: MediaType('image', mimeSubtype),
            ),
          );
        }
      }

      return await request.send();
    });
  }
}
