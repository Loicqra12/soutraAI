import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/provider.dart';
import '../models/service_request.dart';
import '../models/user.dart';

class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();
  DataService._();

  List<Provider>? _providers;
  List<Map<String, dynamic>>? _services;
  
  // Charger les prestataires depuis le dataset
  Future<List<Provider>> loadProviders() async {
    if (_providers != null) return _providers!;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/providers.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      _providers = jsonData.map((json) => Provider.fromJson(json)).toList();
      return _providers!;
    } catch (e) {
      print('Erreur lors du chargement des prestataires: $e');
      return [];
    }
  }

  // Charger les services depuis le dataset
  Future<List<Map<String, dynamic>>> loadServices() async {
    if (_services != null) return _services!;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/services.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      _services = jsonData.cast<Map<String, dynamic>>();
      return _services!;
    } catch (e) {
      print('Erreur lors du chargement des services: $e');
      return [];
    }
  }

  // Rechercher des prestataires par service
  Future<List<Provider>> searchProvidersByService(String serviceType) async {
    final providers = await loadProviders();
    
    return providers.where((provider) {
      return provider.services.any((service) => 
        service.toLowerCase().contains(serviceType.toLowerCase())
      );
    }).toList();
  }

  // Rechercher des prestataires par localisation
  Future<List<Provider>> searchProvidersByLocation(String neighborhood) async {
    final providers = await loadProviders();
    
    return providers.where((provider) {
      return provider.location.neighborhood.toLowerCase() == neighborhood.toLowerCase() ||
             provider.location.serviceAreas.any((area) => 
               area.toLowerCase().contains(neighborhood.toLowerCase())
             );
    }).toList();
  }

  // Rechercher des prestataires disponibles
  Future<List<Provider>> getAvailableProviders() async {
    final providers = await loadProviders();
    return providers.where((provider) => provider.isAvailable).toList();
  }

  // Obtenir un prestataire par ID
  Future<Provider?> getProviderById(String id) async {
    final providers = await loadProviders();
    try {
      return providers.firstWhere((provider) => provider.id == id);
    } catch (e) {
      return null;
    }
  }

  // Rechercher des prestataires avec filtres multiples
  Future<List<Provider>> searchProvidersWithFilters({
    String? serviceType,
    String? neighborhood,
    bool? isAvailable,
    double? minRating,
    double? maxPrice,
  }) async {
    final providers = await loadProviders();
    
    return providers.where((provider) {
      // Filtre par type de service
      if (serviceType != null && serviceType.isNotEmpty) {
        bool hasService = provider.services.any((service) => 
          service.toLowerCase().contains(serviceType.toLowerCase())
        );
        if (!hasService) return false;
      }

      // Filtre par quartier
      if (neighborhood != null && neighborhood.isNotEmpty) {
        bool inArea = provider.location.neighborhood.toLowerCase() == neighborhood.toLowerCase() ||
                     provider.location.serviceAreas.any((area) => 
                       area.toLowerCase().contains(neighborhood.toLowerCase())
                     );
        if (!inArea) return false;
      }

      // Filtre par disponibilité
      if (isAvailable != null && provider.isAvailable != isAvailable) {
        return false;
      }

      // Filtre par note minimale
      if (minRating != null && provider.rating.average < minRating) {
        return false;
      }

      // Filtre par prix maximum (prendre le prix moyen des services)
      if (maxPrice != null && serviceType != null) {
        final servicePrice = provider.prices[serviceType];
        if (servicePrice != null && servicePrice > maxPrice) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Obtenir les suggestions IA pour un service
  Future<List<String>> getAISuggestions(String serviceType) async {
    final services = await loadServices();
    
    try {
      final service = services.firstWhere(
        (s) => s['name'].toString().toLowerCase() == serviceType.toLowerCase()
      );
      return List<String>.from(service['aiSuggestions'] ?? []);
    } catch (e) {
      return [
        'Décrivez précisément votre besoin',
        'Indiquez votre localisation',
        'Précisez vos préférences'
      ];
    }
  }

  // Estimer le prix d'un service
  Future<Map<String, double>> estimateServicePrice(String serviceType) async {
    final services = await loadServices();
    
    try {
      final service = services.firstWhere(
        (s) => s['name'].toString().toLowerCase() == serviceType.toLowerCase()
      );
      
      return {
        'average': service['averagePrice'].toDouble(),
        'min': service['priceRange']['min'].toDouble(),
        'max': service['priceRange']['max'].toDouble(),
      };
    } catch (e) {
      return {
        'average': 15000.0,
        'min': 5000.0,
        'max': 50000.0,
      };
    }
  }

  // Obtenir les services populaires
  Future<List<Map<String, dynamic>>> getPopularServices() async {
    final services = await loadServices();
    
    // Trier par popularité
    services.sort((a, b) => b['popularity'].compareTo(a['popularity']));
    
    return services.take(5).toList();
  }

  // Obtenir les statistiques globales
  Future<Map<String, dynamic>> getGlobalStatistics() async {
    final providers = await loadProviders();
    final services = await loadServices();

    // Compter les prestataires par profession
    Map<String, int> providersByProfession = {};
    for (var provider in providers) {
      providersByProfession[provider.profession] = 
        (providersByProfession[provider.profession] ?? 0) + 1;
    }

    // Compter les prestataires par quartier
    Map<String, int> providersByNeighborhood = {};
    for (var provider in providers) {
      providersByNeighborhood[provider.location.neighborhood] = 
        (providersByNeighborhood[provider.location.neighborhood] ?? 0) + 1;
    }

    // Calculer la note moyenne globale
    double totalRating = providers.fold(0.0, (sum, provider) => sum + provider.rating.average);
    double averageRating = totalRating / providers.length;

    return {
      'totalProviders': providers.length,
      'availableProviders': providers.where((p) => p.isAvailable).length,
      'totalServices': services.length,
      'providersByProfession': providersByProfession,
      'providersByNeighborhood': providersByNeighborhood,
      'averageRating': averageRating,
      'totalReviews': providers.fold(0, (sum, provider) => sum + provider.rating.totalReviews),
    };
  }

  // Simuler l'IA de matching
  Future<List<Provider>> getAIMatchedProviders({
    required String serviceType,
    required String neighborhood,
    bool isUrgent = false,
  }) async {
    var providers = await searchProvidersWithFilters(
      serviceType: serviceType,
      neighborhood: neighborhood,
      isAvailable: true,
    );

    // Trier par score IA (simulation)
    providers.sort((a, b) {
      double scoreA = _calculateAIScore(a, serviceType, neighborhood, isUrgent);
      double scoreB = _calculateAIScore(b, serviceType, neighborhood, isUrgent);
      return scoreB.compareTo(scoreA);
    });

    return providers.take(5).toList();
  }

  // Calculer le score IA (simulation)
  double _calculateAIScore(Provider provider, String serviceType, String neighborhood, bool isUrgent) {
    double score = 0.0;

    // Score basé sur la note
    score += provider.rating.average * 20;

    // Score basé sur le nombre d'avis
    score += (provider.rating.totalReviews / 10).clamp(0, 10);

    // Score basé sur la spécialisation
    if (provider.services.any((s) => s.toLowerCase() == serviceType.toLowerCase())) {
      score += 30;
    }

    // Score basé sur la localisation
    if (provider.location.neighborhood.toLowerCase() == neighborhood.toLowerCase()) {
      score += 20;
    } else if (provider.location.serviceAreas.any((area) => 
        area.toLowerCase().contains(neighborhood.toLowerCase()))) {
      score += 10;
    }

    // Bonus si disponible et urgent
    if (provider.isAvailable && isUrgent) {
      score += 15;
    }

    return score;
  }

  // Nettoyer le cache
  void clearCache() {
    _providers = null;
    _services = null;
  }
}
