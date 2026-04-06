import 'dart:convert';
import '../../../shared/models/user_model.dart';
import '../../core/services/api_client.dart';
import '../../core/services/token_service.dart';
import '../../core/exceptions/typed_exceptions.dart';
import '../../core/models/api_response.dart';

abstract class IAuthRepository {
  Future<ApiResponse<String>> login(String email, String password);
  Future<ApiResponse<String>> register(String name, String email, String password);
  Future<void> logout();
  Future<ApiResponse<UserModel>> getProfile();
}

class AuthRepositoryImpl implements IAuthRepository {
  final IApiClient _apiClient;
  final ITokenService _tokenService;

  AuthRepositoryImpl(this._apiClient, this._tokenService);

  @override
  Future<ApiResponse<String>> login(String email, String password) async {
    final res = await _apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (res.statusCode == 401) throw UnauthorizedException('Invalid credentials');
    if (res.statusCode == 404) throw NotFoundException('User not found');
    if (res.statusCode >= 500) throw ServerException('Server error during login');
    if (res.statusCode != 200) throw BadRequestException('Failed to login');

    final data = jsonDecode(res.body);
    final response = ApiResponse<String>.fromJson(data, (json) => data['accessToken']);
    
    if (response.success && data['accessToken'] != null && data['refreshToken'] != null) {
      await _tokenService.saveTokens(data['accessToken'], data['refreshToken']);
    }
    
    return response;
  }

  @override
  Future<ApiResponse<String>> register(String name, String email, String password) async {
    final res = await _apiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    if (res.statusCode == 400) throw BadRequestException('Invalid registration data');
    if (res.statusCode >= 500) throw ServerException('Server error during registration');
    if (res.statusCode != 201) throw BadRequestException('Failed to register');

    final data = jsonDecode(res.body);
    final response = ApiResponse<String>.fromJson(data, (json) => data['accessToken']);
    
    if (response.success && data['accessToken'] != null && data['refreshToken'] != null) {
      await _tokenService.saveTokens(data['accessToken'], data['refreshToken']);
    }

    return response;
  }

  @override
  Future<void> logout() async {
    await _tokenService.clearTokens();
  }

  @override
  Future<ApiResponse<UserModel>> getProfile() async {
    final res = await _apiClient.get('/auth/me');

    if (res.statusCode == 401) throw UnauthorizedException('Session expired');
    if (res.statusCode == 404) throw NotFoundException('User not found');
    if (res.statusCode >= 500) throw ServerException();

    final data = jsonDecode(res.body);
    return ApiResponse<UserModel>.fromJson(
      data,
      (json) => UserModel.fromJson(data['user']),
    );
  }
}
