import 'dart:convert';
import 'package:flutter/services.dart';

class PricingService {
  static List<Map<String, dynamic>> _pricingData = [];
  static bool _isLoaded = false;

  /// Charge le dataset de pricing depuis le fichier JSON
  static Future<void> loadPricingData() async {
    if (_isLoaded) return;
    
    try {
      final String response = await rootBundle.loadString('assets/data/pricing_data.json');
      final List<dynamic> data = json.decode(response);
      _pricingData = data.cast<Map<String, dynamic>>();
      _isLoaded = true;
      print('✅ ${_pricingData.length} données de pricing chargées');
    } catch (e) {
      print('❌ Erreur lors du chargement des données de pricing: $e');
      _pricingData = [];
    }
  }

  /// Estime le prix d'un service selon les critères contextuels
  static Future<Map<String, dynamic>> estimatePrice({
    required String metier,
    required String quartier,
    String? jour,
    String? heure,
    String? saison,
  }) async {
    await loadPricingData();
    
    if (_pricingData.isEmpty) {
      return _getDefaultPriceEstimate(metier);
    }

    // Filtrer les données par métier
    List<Map<String, dynamic>> relevantData = _pricingData
        .where((item) => item['metier'].toString().toLowerCase() == metier.toLowerCase())
        .toList();

    if (relevantData.isEmpty) {
      return _getDefaultPriceEstimate(metier);
    }

    // Scoring contextuel pour chaque prix
    List<Map<String, dynamic>> scoredPrices = relevantData.map((item) {
      double score = 1.0;
      
      // Bonus quartier identique
      if (quartier.isNotEmpty && item['quartier'].toString().toLowerCase() == quartier.toLowerCase()) {
        score += 0.5;
      }
      
      // Bonus jour identique
      if (jour != null && item['jour'].toString().toLowerCase() == jour.toLowerCase()) {
        score += 0.3;
      }
      
      // Bonus heure identique
      if (heure != null && item['heure'].toString().toLowerCase() == heure.toLowerCase()) {
        score += 0.2;
      }
      
      // Bonus saison identique
      if (saison != null && item['saison'].toString().toLowerCase() == saison.toLowerCase()) {
        score += 0.2;
      }

      return {
        ...item,
        'score': score,
      };
    }).toList();

    // Trier par score décroissant
    scoredPrices.sort((a, b) => b['score'].compareTo(a['score']));

    // Calculer la fourchette de prix
    List<int> prices = scoredPrices.map((item) => item['prix_reel'] as int).toList();
    
    int minPrice = prices.reduce((a, b) => a < b ? a : b);
    int maxPrice = prices.reduce((a, b) => a > b ? a : b);
    int avgPrice = (prices.reduce((a, b) => a + b) / prices.length).round();

    // Ajustements contextuels
    Map<String, dynamic> adjustments = _getContextualAdjustments(quartier, jour, heure, saison);
    
    double multiplier = adjustments['multiplier'];
    avgPrice = (avgPrice * multiplier).round();
    minPrice = (minPrice * multiplier * 0.8).round();
    maxPrice = (maxPrice * multiplier * 1.2).round();

    return {
      'prix_estime': avgPrice,
      'fourchette_min': minPrice,
      'fourchette_max': maxPrice,
      'confiance': _calculateConfidence(scoredPrices.length, scoredPrices.first['score']),
      'contexte': adjustments['contexte'],
      'echantillon': scoredPrices.length,
      'metier': metier,
      'quartier': quartier,
    };
  }

  /// Ajustements contextuels selon les critères
  static Map<String, dynamic> _getContextualAdjustments(String quartier, String? jour, String? heure, String? saison) {
    double multiplier = 1.0;
    List<String> contexte = [];

    // Ajustements par quartier (zones huppées vs populaires)
    Map<String, double> quartierMultipliers = {
      'cocody': 1.3,
      'plateau': 1.25,
      'marcory': 1.1,
      'treichville': 1.0,
      'adjamé': 0.9,
      'yopougon': 0.85,
      'abobo': 0.8,
      'koumassi': 0.85,
    };
    
    String quartierLower = quartier.toLowerCase();
    if (quartierMultipliers.containsKey(quartierLower)) {
      multiplier *= quartierMultipliers[quartierLower]!;
      if (quartierMultipliers[quartierLower]! > 1.1) {
        contexte.add('Zone huppée (+${((quartierMultipliers[quartierLower]! - 1) * 100).round()}%)');
      }
    }

    // Ajustements par jour (weekend vs semaine)
    if (jour != null) {
      String jourLower = jour.toLowerCase();
      if (['samedi', 'dimanche'].contains(jourLower)) {
        multiplier *= 1.15;
        contexte.add('Weekend (+15%)');
      }
    }

    // Ajustements par heure (urgence soir/nuit)
    if (heure != null) {
      String heureLower = heure.toLowerCase();
      if (heureLower == 'soir') {
        multiplier *= 1.1;
        contexte.add('Horaire soir (+10%)');
      }
    }

    // Ajustements par saison (pluie = plus cher)
    if (saison != null) {
      String saisonLower = saison.toLowerCase();
      if (saisonLower == 'pluie') {
        multiplier *= 1.05;
        contexte.add('Saison pluies (+5%)');
      }
    }

    return {
      'multiplier': multiplier,
      'contexte': contexte,
    };
  }

  /// Calcule le niveau de confiance de l'estimation
  static String _calculateConfidence(int sampleSize, double bestScore) {
    if (sampleSize >= 5 && bestScore > 1.5) return 'Très élevée';
    if (sampleSize >= 3 && bestScore > 1.2) return 'Élevée';
    if (sampleSize >= 2) return 'Moyenne';
    return 'Faible';
  }

  /// Prix par défaut si aucune donnée n'est trouvée
  static Map<String, dynamic> _getDefaultPriceEstimate(String metier) {
    Map<String, int> defaultPrices = {
      'coiffure': 6000,
      'plomberie': 12000,
      'électricité': 15000,
      'ménage': 8000,
      'livraison': 3500,
      'jardinage': 10000,
      'peinture': 20000,
      'climatisation': 25000,
    };

    int basePrice = defaultPrices[metier.toLowerCase()] ?? 10000;
    
    return {
      'prix_estime': basePrice,
      'fourchette_min': (basePrice * 0.7).round(),
      'fourchette_max': (basePrice * 1.3).round(),
      'confiance': 'Estimation générale',
      'contexte': ['Prix de base pour $metier'],
      'echantillon': 0,
      'metier': metier,
      'quartier': 'Général',
    };
  }

  /// Obtient les statistiques de pricing par métier
  static Future<Map<String, dynamic>> getPricingStats(String metier) async {
    await loadPricingData();
    
    List<Map<String, dynamic>> metierData = _pricingData
        .where((item) => item['metier'].toString().toLowerCase() == metier.toLowerCase())
        .toList();

    if (metierData.isEmpty) {
      return {'error': 'Aucune donnée trouvée pour $metier'};
    }

    List<int> prices = metierData.map((item) => item['prix_reel'] as int).toList();
    
    return {
      'metier': metier,
      'nombre_services': metierData.length,
      'prix_moyen': (prices.reduce((a, b) => a + b) / prices.length).round(),
      'prix_min': prices.reduce((a, b) => a < b ? a : b),
      'prix_max': prices.reduce((a, b) => a > b ? a : b),
      'quartiers_couverts': metierData.map((item) => item['quartier']).toSet().length,
    };
  }

  /// Formate le prix en FCFA
  static String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
  }

  /// Formate une fourchette de prix
  static String formatPriceRange(int minPrice, int maxPrice) {
    return '${formatPrice(minPrice)} - ${formatPrice(maxPrice)}';
  }
}
