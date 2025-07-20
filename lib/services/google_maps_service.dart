import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapsService {
  static const String _apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // À remplacer
  static const String _placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _geocodingBaseUrl = 'https://maps.googleapis.com/maps/api/geocode';

  // Obtenir la position actuelle de l'utilisateur
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Erreur lors de l\'obtention de la localisation: $e');
      return null;
    }
  }

  // Rechercher des lieux par texte
  static Future<List<PlaceResult>> searchPlaces(String query) async {
    try {
      final url = Uri.parse(
        '$_placesBaseUrl/textsearch/json?query=$query&key=$_apiKey&language=fr&region=ci',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        return results.map((place) => PlaceResult.fromJson(place)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur lors de la recherche de lieux: $e');
      return [];
    }
  }

  // Obtenir les détails d'un lieu
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        '$_placesBaseUrl/details/json?place_id=$placeId&key=$_apiKey&language=fr',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlaceDetails.fromJson(data['result']);
      }
      return null;
    } catch (e) {
      print('Erreur lors de l\'obtention des détails du lieu: $e');
      return null;
    }
  }

  // Rechercher des lieux à proximité
  static Future<List<PlaceResult>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
    int radius = 5000,
  }) async {
    try {
      final url = Uri.parse(
        '$_placesBaseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$_apiKey&language=fr',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        return results.map((place) => PlaceResult.fromJson(place)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur lors de la recherche de lieux à proximité: $e');
      return [];
    }
  }

  // Géocodage : convertir une adresse en coordonnées
  static Future<LocationCoordinates?> geocodeAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LocationCoordinates(
          latitude: location.latitude,
          longitude: location.longitude,
        );
      }
      return null;
    } catch (e) {
      print('Erreur lors du géocodage: $e');
      return null;
    }
  }

  // Géocodage inverse : convertir des coordonnées en adresse
  static Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
      return null;
    } catch (e) {
      print('Erreur lors du géocodage inverse: $e');
      return null;
    }
  }

  // Calculer la distance entre deux points
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Obtenir les quartiers d'Abidjan
  static List<String> getAbidjanNeighborhoods() {
    return [
      'Cocody',
      'Plateau',
      'Marcory',
      'Treichville',
      'Adjamé',
      'Yopougon',
      'Abobo',
      'Koumassi',
      'Port-Bouët',
      'Attécoubé',
      'Deux Plateaux',
      'Riviera',
      'Zone 4',
      'Angré',
      'Bingerville'
    ];
  }
}

class PlaceResult {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final String? photoReference;

  PlaceResult({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.photoReference,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return PlaceResult(
      placeId: json['place_id'],
      name: json['name'],
      address: json['formatted_address'] ?? '',
      latitude: geometry['lat'].toDouble(),
      longitude: geometry['lng'].toDouble(),
      rating: json['rating']?.toDouble(),
      photoReference: json['photos']?[0]?['photo_reference'],
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final String? phone;
  final String? website;
  final List<String> openingHours;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    this.phone,
    this.website,
    required this.openingHours,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return PlaceDetails(
      placeId: json['place_id'],
      name: json['name'],
      address: json['formatted_address'] ?? '',
      phone: json['formatted_phone_number'],
      website: json['website'],
      openingHours: (json['opening_hours']?['weekday_text'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      latitude: geometry['lat'].toDouble(),
      longitude: geometry['lng'].toDouble(),
    );
  }
}

class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });
}
