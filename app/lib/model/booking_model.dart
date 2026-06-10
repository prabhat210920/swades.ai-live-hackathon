import 'slot_model.dart';

class Booking {
  final int id;
  final int user;
  final String userPhone;
  final int slot;
  final Slot? slotDetail;
  final String status;
  final String bookedAt;
  final String notes;

  const Booking({
    required this.id,
    required this.user,
    required this.userPhone,
    required this.slot,
    this.slotDetail,
    required this.status,
    required this.bookedAt,
    required this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    Slot? slotDetail;
    final slotData = json['slot_detail'];
    if (slotData is Map<String, dynamic>) {
      slotDetail = Slot.fromJson(slotData);
    }

    return Booking(
      id: json['id'] as int,
      user: json['user'] as int,
      userPhone: json['user_phone'] as String? ?? '',
      slot: json['slot'] as int,
      slotDetail: slotDetail,
      status: json['status'] as String? ?? 'confirmed',
      bookedAt: json['booked_at'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'user_phone': userPhone,
    'slot': slot,
    'status': status,
    'booked_at': bookedAt,
    'notes': notes,
  };

  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';

  /// Returns "Sat, 24 Oct • 18:00 - 19:00" style string
  String get displayDateTime {
    if (slotDetail == null) return '';
    return '${slotDetail!.date} • ${slotDetail!.timeRange}';
  }
}
