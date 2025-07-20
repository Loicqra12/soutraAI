import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/provider.dart';

class MatchingService {
  static MatchingService? _instance;
  static MatchingService get instance => _instance ??= MatchingService._();
  MatchingService._();

  // Charger les demandes de matching depuis le fichier JSON
  static Future<List<Map<String, dynamic>>> loadMatchingRequests() async {
    try {
      final String response = await rootBundle.loadString('assets/data/matching_requests.json');
      final List<dynamic> data = json.decode(response);
      print('✅ ${data.length} demandes de matching chargées');
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Erreur lors du chargement des demandes de matching: $e');
      return [];
    }
  }

  // Calculer le score de matching entre une demande et un prestataire
  static double calculateMatchingScore(
    Map<String, dynamic> request,
    Provider provider,
  ) {
    double score = 0.0;

    // 1. Correspondance du service (40% du score)
    String requestService = (request['service'] ?? '').toString().toLowerCase();
    bool serviceMatch = provider.services.any((service) => 
      service.toLowerCase().contains(requestService) || 
      requestService.contains(service.toLowerCase())
    );
    if (serviceMatch) score += 40.0;

    // 2. Proximité géographique (25% du score)
    String requestQuartier = (request['quartier'] ?? '').toString();
    if (provider.location.neighborhood.toLowerCase() == requestQuartier.toLowerCase()) {
      score += 25.0;
    } else if (_isNearbyQuartier(provider.location.neighborhood, requestQuartier)) {
      score += 15.0; // Score réduit pour les quartiers proches
    }

    // 3. Note du prestataire (20% du score)
    score += (provider.rating.average / 5.0) * 20.0;

    // 4. Urgence (10% du score)
    bool isUrgent = request['urgence'] ?? false;
    if (isUrgent && provider.isAvailable) {
      score += 10.0;
    } else if (!isUrgent) {
      score += 5.0; // Bonus pour les demandes non urgentes
    }

    // 5. Correspondance des mots-clés (5% du score)
    List<String> requestKeywords = List<String>.from(request['mots_cles'] ?? []);
    int keywordMatches = 0;
    for (String keyword in requestKeywords) {
      if (provider.specialties.any((specialty) => 
        specialty.toLowerCase().contains(keyword.toLowerCase()))) {
        keywordMatches++;
      }
    }
    if (requestKeywords.isNotEmpty) {
      score += (keywordMatches / requestKeywords.length) * 5.0;
    }

    return score.clamp(0.0, 100.0);
  }

  // Vérifier si deux quartiers sont proches
  static bool _isNearbyQuartier(String quartier1, String quartier2) {
    // Quartiers proches d'Abidjan
    Map<String, List<String>> nearbyQuartiers = {
      'Cocody': ['Riviera', 'Plateau'],
      'Plateau': ['Cocody', 'Adjamé'],
      'Yopougon': ['Abobo', 'Attécoubé'],
      'Marcory': ['Treichville', 'Port-Bouët'],
      'Adjamé': ['Plateau', 'Abobo'],
      'Abobo': ['Yopougon', 'Adjamé'],
      'Treichville': ['Marcory', 'Port-Bouët'],
      'Riviera': ['Cocody', 'Bingerville'],
    };

    return nearbyQuartiers[quartier1]?.contains(quartier2) ?? false;
  }

  // Obtenir les meilleurs prestataires pour une demande
  static Future<List<Map<String, dynamic>>> getBestMatches(
    Map<String, dynamic> request,
    List<Provider> providers,
  ) async {
    List<Map<String, dynamic>> matches = [];

    for (Provider provider in providers) {
      double score = calculateMatchingScore(request, provider);
      
      if (score > 20.0) { // Seuil minimum de pertinence
        matches.add({
          'provider': provider,
          'score': score,
          'match_reasons': _getMatchReasons(request, provider, score),
        });
      }
    }

    // Trier par score décroissant
    matches.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    
    // Retourner les 10 meilleurs résultats
    return matches.take(10).toList();
  }

  // Obtenir les raisons du matching
  static List<String> _getMatchReasons(
    Map<String, dynamic> request,
    Provider provider,
    double score,
  ) {
    List<String> reasons = [];

    String requestService = (request['service'] ?? '').toString().toLowerCase();
    bool serviceMatch = provider.services.any((service) => 
      service.toLowerCase().contains(requestService)
    );
    if (serviceMatch) {
      reasons.add('Service correspondant');
    }

    String requestQuartier = (request['quartier'] ?? '').toString();
    if (provider.location.neighborhood.toLowerCase() == requestQuartier.toLowerCase()) {
      reasons.add('Même quartier');
    } else if (_isNearbyQuartier(provider.location.neighborhood, requestQuartier)) {
      reasons.add('Quartier proche');
    }

    if (provider.rating.average >= 4.0) {
      reasons.add('Excellente note (${provider.rating.average}/5)');
    }

    bool isUrgent = request['urgence'] ?? false;
    if (isUrgent && provider.isAvailable) {
      reasons.add('Disponible immédiatement');
    }

    if (score >= 80.0) {
      reasons.add('Match parfait IA');
    } else if (score >= 60.0) {
      reasons.add('Très bon match IA');
    }

    return reasons;
  }

  // Analyser les tendances de demandes
  static Future<Map<String, dynamic>> analyzeMatchingTrends() async {
    final requests = await loadMatchingRequests();
    
    Map<String, int> serviceCount = {};
    Map<String, int> quartierCount = {};
    Map<String, int> heureCount = {};
    int urgentCount = 0;

    for (var request in requests) {
      String service = request['service'] ?? '';
      String quartier = request['quartier'] ?? '';
      String heure = request['heure'] ?? '';
      bool urgence = request['urgence'] ?? false;
      
      serviceCount[service] = (serviceCount[service] ?? 0) + 1;
      quartierCount[quartier] = (quartierCount[quartier] ?? 0) + 1;
      heureCount[heure] = (heureCount[heure] ?? 0) + 1;
      if (urgence) urgentCount++;
    }

    return {
      'totalRequests': requests.length,
      'urgentRequests': urgentCount,
      'urgentPercentage': requests.isEmpty ? 0 : (urgentCount / requests.length * 100).round(),
      'topServices': serviceCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      'topQuartiers': quartierCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      'topHeures': heureCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    };
  }

  // Prédire la demande pour un service dans un quartier
  static Future<double> predictDemand(String service, String quartier) async {
    final requests = await loadMatchingRequests();
    
    int matchingRequests = requests.where((r) => 
      (r['service'] ?? '').toString().toLowerCase() == service.toLowerCase() &&
      (r['quartier'] ?? '').toString().toLowerCase() == quartier.toLowerCase()
    ).length;

    // Simulation de prédiction basée sur l'historique
    double baseDemand = matchingRequests.toDouble();
    double seasonalFactor = 1.0; // Facteur saisonnier
    double trendFactor = 1.1; // Facteur de croissance

    return baseDemand * seasonalFactor * trendFactor;
  }

  // Obtenir les statistiques de matching
  static Future<Map<String, dynamic>> getMatchingStats() async {
    final requests = await loadMatchingRequests();
    
    Map<String, int> statusCount = {};
    for (var request in requests) {
      String status = request['status'] ?? 'pending';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    return {
      'total': requests.length,
      'pending': statusCount['pending'] ?? 0,
      'matched': statusCount['matched'] ?? 0,
      'in_progress': statusCount['in_progress'] ?? 0,
      'completed': statusCount['completed'] ?? 0,
      'success_rate': requests.isEmpty ? 0 : 
        ((statusCount['completed'] ?? 0) / requests.length * 100).round(),
    };
  }
}
