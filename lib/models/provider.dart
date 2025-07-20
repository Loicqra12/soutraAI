import 'package:json_annotation/json_annotation.dart';

part 'provider.g.dart';

@JsonSerializable()
class Provider {
  final String id;
  final String name;
  final String profession;
  final String description;
  final List<String> services;
  final List<String> languages;
  final Location location;
  final ContactInfo contact;
  final Rating rating;
  final List<String> specialties;
  final Map<String, double> prices; // service -> price in FCFA
  final bool isAvailable;
  final String profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Provider({
    required this.id,
    required this.name,
    required this.profession,
    required this.description,
    required this.services,
    required this.languages,
    required this.location,
    required this.contact,
    required this.rating,
    required this.specialties,
    required this.prices,
    required this.isAvailable,
    required this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Provider.fromJson(Map<String, dynamic> json) => _$ProviderFromJson(json);
  Map<String, dynamic> toJson() => _$ProviderToJson(this);
}

@JsonSerializable()
class Location {
  final String address;
  final String neighborhood;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final List<String> serviceAreas; // zones d'intervention

  Location({
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.serviceAreas,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class ContactInfo {
  final String phone;
  final String? email;
  final String? whatsapp;
  final Map<String, String> socialMedia; // platform -> handle

  ContactInfo({
    required this.phone,
    this.email,
    this.whatsapp,
    required this.socialMedia,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) => _$ContactInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ContactInfoToJson(this);
}

@JsonSerializable()
class Rating {
  final double average;
  final int totalReviews;
  final Map<int, int> distribution; // star -> count

  Rating({
    required this.average,
    required this.totalReviews,
    required this.distribution,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
  Map<String, dynamic> toJson() => _$RatingToJson(this);
}
