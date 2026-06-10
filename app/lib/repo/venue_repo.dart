import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/network/dio_client.dart';
import '../core/utils/error_handler.dart';
import '../model/venue_model.dart';
import '../model/slot_model.dart';

class VenueRepo {
  VenueRepo({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<List<Venue>> getVenues() async {
    try {
      final response = await _dio.get(AppConstants.venuesEndpoint);
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Venue.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // Handle paginated DRF response
      if (data is Map && data['results'] is List) {
        return (data['results'] as List)
            .map((e) => Venue.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Venue> getVenueDetail(int id) async {
    try {
      final response = await _dio.get('${AppConstants.venuesEndpoint}$id/');
      return Venue.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Slot>> getSlots(int venueId, String date) async {
    try {
      final response = await _dio.get(
        '${AppConstants.venuesEndpoint}$venueId/slots/',
        queryParameters: {'date': date},
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Slot.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map && data['results'] is List) {
        return (data['results'] as List)
            .map((e) => Slot.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    return parseApiError(e.response?.data, e.response?.statusCode);
  }
}

final venueRepoProvider = Provider<VenueRepo>((ref) => VenueRepo());
