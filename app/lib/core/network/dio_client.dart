import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

/// Singleton Dio client with JWT Bearer token injection and automatic
/// token refresh on 401 responses.
class DioClient {
  DioClient._();

  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AuthInterceptor(dio, _storage));

    return dio;
  }
}

/// Intercepts every request to:
///   1. Attach the stored JWT access token as a Bearer header.
///   2. On 401 → attempt refresh → retry original request.
///   3. On refresh failure → throw [SessionExpiredException].
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio, this._storage);

  final Dio _dio;
  final FlutterSecureStorage _storage;

  // Guard against recursive refresh loops
  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints
    final isAuthEndpoint = options.path == AppConstants.loginEndpoint ||
        options.path == AppConstants.registerEndpoint ||
        options.path == AppConstants.tokenRefreshEndpoint;

    if (!isAuthEndpoint) {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final newAccessToken = await _refreshAccessToken();
        if (newAccessToken != null) {
          // Retry the original request with the new token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final response = await _dio.fetch(retryOptions);
          _isRefreshing = false;
          handler.resolve(response);
          return;
        }
      } catch (_) {
        // Refresh failed — clear tokens and signal session expiry
        await _clearTokens();
        _isRefreshing = false;
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const SessionExpiredException(),
            type: DioExceptionType.unknown,
          ),
        );
        return;
      }
    }

    // For non-401 errors or already retried, convert to AppException
    final statusCode = err.response?.statusCode;
    if (statusCode == 409) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const SlotTakenException(),
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
      return;
    }

    handler.next(err);
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    // Use a fresh Dio instance to avoid interceptor loops
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final response = await refreshDio.post(
      AppConstants.tokenRefreshEndpoint,
      data: {'refresh': refreshToken},
    );

    final newAccess = response.data['access'] as String?;
    if (newAccess != null) {
      await _storage.write(
        key: AppConstants.accessTokenKey,
        value: newAccess,
      );
    }
    return newAccess;
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userIdKey);
    await _storage.delete(key: AppConstants.userPhoneKey);
  }
}
