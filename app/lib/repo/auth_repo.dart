import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/app_constants.dart';
import '../core/network/dio_client.dart';
import '../core/utils/error_handler.dart';
import '../model/auth_model.dart';

class AuthRepo {
  AuthRepo({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? DioClient.instance.dio,
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<AuthResponse> register({
    required String phoneNumber,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'password_confirm': passwordConfirm,
        },
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _persistTokens(auth);
      return auth;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {'phone_number': phoneNumber, 'password': password},
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _persistTokens(auth);
      return auth;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userIdKey);
    await _storage.delete(key: AppConstants.userPhoneKey);
  }

  Future<bool> hasValidToken() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getStoredPhone() async {
    return _storage.read(key: AppConstants.userPhoneKey);
  }

  Future<int?> getStoredUserId() async {
    final id = await _storage.read(key: AppConstants.userIdKey);
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> _persistTokens(AuthResponse auth) async {
    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: auth.access,
    );
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: auth.refresh,
    );
    await _storage.write(
      key: AppConstants.userIdKey,
      value: auth.user.id.toString(),
    );
    await _storage.write(
      key: AppConstants.userPhoneKey,
      value: auth.user.phoneNumber,
    );
  }

  AppException _handleDioError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    return parseApiError(e.response?.data, e.response?.statusCode);
  }
}

// ─── Riverpod provider ───────────────────────────────────────────────────────

final authRepoProvider = Provider<AuthRepo>((ref) => AuthRepo());
