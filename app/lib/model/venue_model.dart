class Venue {
  final int id;
  final String name;
  final String address;
  final String city;
  final String description;

  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.description,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'city': city,
    'description': description,
  };
}
