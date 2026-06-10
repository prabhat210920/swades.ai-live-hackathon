import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/network/dio_client.dart';
import '../core/utils/error_handler.dart';
import '../model/booking_model.dart';

class BookingRepo {
  BookingRepo({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<Booking> createBooking({
    required int slotId,
    String notes = '',
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.bookingsEndpoint,
        data: {'slot': slotId, 'notes': notes},
      );
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _dio.get(AppConstants.bookingsEndpoint);
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map && data['results'] is List) {
        return (data['results'] as List)
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await _dio.delete('${AppConstants.bookingsEndpoint}$bookingId/');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    return parseApiError(e.response?.data, e.response?.statusCode);
  }
}

final bookingRepoProvider = Provider<BookingRepo>((ref) => BookingRepo());
