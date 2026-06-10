class UserDto {
  final int id;
  final String phoneNumber;

  const UserDto({required this.id, required this.phoneNumber});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      phoneNumber: json['phone_number'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone_number': phoneNumber,
  };
}

class AuthResponse {
  final String access;
  final String refresh;
  final UserDto user;

  const AuthResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
