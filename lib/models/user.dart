import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserType type;
  final List<String> preferredLanguages;
  final Location? location;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.type,
    required this.preferredLanguages,
    this.location,
    required this.preferences,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Location {
  final String address;
  final String neighborhood;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class UserPreferences {
  final bool enableNotifications;
  final bool enableLocationServices;
  final String preferredCurrency;
  final double maxSearchRadius; // in kilometers
  final List<String> favoriteServiceTypes;

  UserPreferences({
    required this.enableNotifications,
    required this.enableLocationServices,
    required this.preferredCurrency,
    required this.maxSearchRadius,
    required this.favoriteServiceTypes,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

enum UserType {
  client,
  provider,
  admin
}
