import 'package:json_annotation/json_annotation.dart';

part 'service_request.g.dart';

@JsonSerializable()
class ServiceRequest {
  final String id;
  final String clientId;
  final String serviceType;
  final String description;
  final Location location;
  final bool isUrgent;
  final DateTime preferredDateTime;
  final ServiceRequestStatus status;
  final double? estimatedPrice;
  final List<String> aiSuggestions;
  final List<String> matchedProviderIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceRequest({
    required this.id,
    required this.clientId,
    required this.serviceType,
    required this.description,
    required this.location,
    required this.isUrgent,
    required this.preferredDateTime,
    required this.status,
    this.estimatedPrice,
    required this.aiSuggestions,
    required this.matchedProviderIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => _$ServiceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceRequestToJson(this);
}

@JsonSerializable()
class Location {
  final String address;
  final String neighborhood;
  final String city;
  final double latitude;
  final double longitude;

  Location({
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

enum ServiceRequestStatus {
  pending,
  matched,
  inProgress,
  completed,
  cancelled
}
