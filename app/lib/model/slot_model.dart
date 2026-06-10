class Slot {
  final int id;
  final int venue;
  final String venueName;
  final String date;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  const Slot({
    required this.id,
    required this.venue,
    required this.venueName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'] as int,
      venue: json['venue'] as int,
      venueName: json['venue_name'] as String? ?? '',
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'venue': venue,
    'venue_name': venueName,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    'is_available': isAvailable,
  };

  /// Returns formatted time like "09:00 - 10:00"
  String get timeRange {
    final start = startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
    final end = endTime.length >= 5 ? endTime.substring(0, 5) : endTime;
    return '$start - $end';
  }

  /// Returns start hour label like "09:00"
  String get startLabel {
    return startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
  }
}
