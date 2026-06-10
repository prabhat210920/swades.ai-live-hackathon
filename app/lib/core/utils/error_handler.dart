/// Represents a parsed, user-friendly error from the API or network layer.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  const AppException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  @override
  String toString() => message;
}

/// Thrown when a booking slot is already taken (HTTP 409).
class SlotTakenException extends AppException {
  const SlotTakenException()
    : super(
        message: 'This slot was just booked by someone else. Please pick another.',
        statusCode: 409,
      );
}

/// Thrown when the user session has expired and refresh failed.
class SessionExpiredException extends AppException {
  const SessionExpiredException()
    : super(message: 'Session expired. Please log in again.', statusCode: 401);
}

/// Parses DRF error response bodies into an [AppException].
///
/// DRF can return:
///   { "detail": "Not found." }
///   { "phone_number": ["This field is required."] }
///   { "non_field_errors": ["Unable to log in."] }
AppException parseApiError(dynamic data, int? statusCode) {
  if (data == null) {
    return AppException(
      message: 'An unexpected error occurred.',
      statusCode: statusCode,
    );
  }

  if (data is Map<String, dynamic>) {
    // Single detail message
    if (data.containsKey('detail')) {
      return AppException(
        message: data['detail'].toString(),
        statusCode: statusCode,
      );
    }

    // Non-field errors (e.g. wrong credentials)
    if (data.containsKey('non_field_errors')) {
      final errors = data['non_field_errors'];
      if (errors is List && errors.isNotEmpty) {
        return AppException(
          message: errors.first.toString(),
          statusCode: statusCode,
        );
      }
    }

    // Field-level errors — collect into map and show first one as message
    final fieldErrors = <String, List<String>>{};
    String? firstMessage;

    data.forEach((key, value) {
      if (value is List) {
        final messages = value.map((e) => e.toString()).toList();
        fieldErrors[key] = messages;
        firstMessage ??= messages.isNotEmpty ? '${_formatField(key)}: ${messages.first}' : null;
      } else if (value is String) {
        fieldErrors[key] = [value];
        firstMessage ??= '${_formatField(key)}: $value';
      }
    });

    return AppException(
      message: firstMessage ?? 'Validation error. Please check your inputs.',
      statusCode: statusCode,
      fieldErrors: fieldErrors.isNotEmpty ? fieldErrors : null,
    );
  }

  return AppException(
    message: data.toString(),
    statusCode: statusCode,
  );
}

String _formatField(String key) {
  return key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
