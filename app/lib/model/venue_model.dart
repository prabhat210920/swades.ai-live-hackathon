class Venue {
  final int id;
  final String name;
  final String address;
  final String city;
  final String description;
  final String imageUrl;
  final List<String> sports;
  final double pricePerHour;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.description,
    required this.imageUrl,
    required this.sports,
    required this.pricePerHour,
    this.createdAt,
    this.updatedAt,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',

      // Safely parse the list of sports
      sports: (json['sports'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],

      // Safely parse the string price to a double for calculations
      pricePerHour: json['price_per_hour'] != null
          ? double.tryParse(json['price_per_hour'].toString()) ?? 0.0
          : 0.0,

      // Safely parse ISO 8601 date strings to DateTime objects
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'city': city,
        'description': description,
        'image_url': imageUrl,
        'sports': sports,
        // Convert the double back to a two-decimal string format for the API
        'price_per_hour': pricePerHour.toStringAsFixed(2),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
