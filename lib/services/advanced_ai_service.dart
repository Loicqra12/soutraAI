import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soutra_ai/services/gemini_service.dart';

/// Service d'IA avancée inspiré du dépôt externe
/// Implémente RAG (Retrieval-Augmented Generation) avec nos datasets locaux
class AdvancedAIService {
  static AdvancedAIService? _instance;
  static AdvancedAIService get instance => _instance ??= AdvancedAIService._();
  AdvancedAIService._();
  static List<Map<String, dynamic>> _servicesKnowledge = [];
  static List<Map<String, dynamic>> _pricingKnowledge = [];
  static List<Map<String, dynamic>> _matchingKnowledge = [];
  static List<String> _conversationHistory = [];
  static bool _isInitialized = false;

  /// Initialise la base de connaissances RAG
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Charger tous nos datasets pour créer la base de connaissances
      await _loadKnowledgeBase();
      _isInitialized = true;
      print('✅ AdvancedAIService initialisé avec RAG local');
    } catch (e) {
      print('❌ Erreur initialisation AdvancedAIService: $e');
    }
  }

  /// Charge la base de connaissances depuis nos datasets
  static Future<void> _loadKnowledgeBase() async {
    // Charger les services
    try {
      final String servicesResponse = await rootBundle.loadString('assets/data/services.json');
      final List<dynamic> servicesData = json.decode(servicesResponse);
      _servicesKnowledge = servicesData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('⚠️ Services knowledge non chargé: $e');
    }

    // Charger les données de pricing
    try {
      final String pricingResponse = await rootBundle.loadString('assets/data/pricing_data.json');
      final List<dynamic> pricingData = json.decode(pricingResponse);
      _pricingKnowledge = pricingData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('⚠️ Pricing knowledge non chargé: $e');
    }

    // Charger les données de matching
    try {
      final String matchingResponse = await rootBundle.loadString('assets/data/matching_requests.json');
      final List<dynamic> matchingData = json.decode(matchingResponse);
      _matchingKnowledge = matchingData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('⚠️ Matching knowledge non chargé: $e');
    }
  }

  /// Recherche contextuelle dans la base de connaissances (RAG)
  static List<Map<String, dynamic>> _retrieveRelevantContext(String query) {
    List<Map<String, dynamic>> relevantContext = [];
    String queryLower = query.toLowerCase();

    // Recherche dans les services
    for (var service in _servicesKnowledge) {
      if (_isRelevant(service, queryLower)) {
        relevantContext.add({
          'type': 'service',
          'data': service,
          'relevance': _calculateRelevance(service, queryLower)
        });
      }
    }

    // Recherche dans les prix
    for (var pricing in _pricingKnowledge) {
      if (_isRelevant(pricing, queryLower)) {
        relevantContext.add({
          'type': 'pricing',
          'data': pricing,
          'relevance': _calculateRelevance(pricing, queryLower)
        });
      }
    }

    // Recherche dans les demandes de matching
    for (var matching in _matchingKnowledge) {
      if (_isRelevant(matching, queryLower)) {
        relevantContext.add({
          'type': 'matching',
          'data': matching,
          'relevance': _calculateRelevance(matching, queryLower)
        });
      }
    }

    // Trier par pertinence et limiter à 10 résultats
    relevantContext.sort((a, b) => b['relevance'].compareTo(a['relevance']));
    return relevantContext.take(10).toList();
  }

  /// Vérifie si un élément est pertinent pour la requête
  static bool _isRelevant(Map<String, dynamic> item, String query) {
    String itemText = item.values.join(' ').toLowerCase();
    List<String> queryWords = query.split(' ');
    
    return queryWords.any((word) => 
      word.length > 2 && itemText.contains(word)
    );
  }

  /// Calcule un score de pertinence
  static double _calculateRelevance(Map<String, dynamic> item, String query) {
    String itemText = item.values.join(' ').toLowerCase();
    List<String> queryWords = query.split(' ');
    double score = 0.0;

    for (String word in queryWords) {
      if (word.length > 2) {
        int occurrences = word.allMatches(itemText).length;
        score += occurrences * word.length;
      }
    }

    return score;
  }

  /// Génère une réponse avec RAG (Retrieval-Augmented Generation)
  static Future<String> generateRAGResponse(String userQuery) async {
    await initialize();

    try {
      // 1. Retrieval : Récupérer le contexte pertinent
      List<Map<String, dynamic>> relevantContext = _retrieveRelevantContext(userQuery);

      // 2. Construire le contexte pour Gemini
      String contextString = _buildContextString(relevantContext);

      // 3. Construire l'historique de conversation
      String conversationContext = _conversationHistory.isNotEmpty 
        ? 'Historique récent:\n${_conversationHistory.length > 3 ? _conversationHistory.sublist(_conversationHistory.length - 3).join('\n') : _conversationHistory.join('\n')}\n\n'
        : '';

      // 4. Prompt optimisé pour RAG
      String ragPrompt = '''
Tu es SoutraAI, l'assistant intelligent spécialisé dans les services en Côte d'Ivoire.

$conversationContext

CONTEXTE PERTINENT TROUVÉ:
$contextString

QUESTION DE L'UTILISATEUR:
$userQuery

INSTRUCTIONS:
- Utilise UNIQUEMENT les informations du contexte fourni
- Réponds en français avec quelques expressions nouchi quand approprié
- Sois précis sur les prix, quartiers et services disponibles
- Si tu n'as pas l'information dans le contexte, dis-le clairement
- Reste dans le domaine des services en Côte d'Ivoire

RÉPONSE:''';

      // 5. Générer la réponse avec Gemini
      String response = await GeminiService.instance.generateContent(ragPrompt);

      // 6. Ajouter à l'historique
      _addToHistory(userQuery, response);

      return response;

    } catch (e) {
      print('❌ Erreur RAG: $e');
      return 'Désolé, j\'ai un petit problème technique. Peux-tu reformuler ta question ?';
    }
  }

  /// Construit le contexte string pour Gemini
  static String _buildContextString(List<Map<String, dynamic>> context) {
    if (context.isEmpty) {
      return 'Aucune information spécifique trouvée dans la base de données.';
    }

    StringBuffer contextBuffer = StringBuffer();
    
    for (var item in context) {
      String type = item['type'];
      Map<String, dynamic> data = item['data'];
      
      switch (type) {
        case 'service':
          contextBuffer.writeln('SERVICE: ${data['name']} - ${data['description']}');
          break;
        case 'pricing':
          contextBuffer.writeln('PRIX: ${data['metier']} à ${data['quartier']} = ${data['prix_reel']} FCFA (${data['saison']}, ${data['jour']} ${data['heure']})');
          break;
        case 'matching':
          contextBuffer.writeln('DEMANDE: ${data['service']} à ${data['quartier']} (urgence: ${data['urgence']}, ${data['jour']} ${data['heure']})');
          break;
      }
    }

    return contextBuffer.toString();
  }

  /// Ajoute un échange à l'historique de conversation
  static void _addToHistory(String question, String response) {
    _conversationHistory.add('Utilisateur: $question');
    _conversationHistory.add('SoutraAI: $response');
    
    // Limiter l'historique à 10 échanges
    if (_conversationHistory.length > 20) {
      _conversationHistory = _conversationHistory.sublist(_conversationHistory.length - 20);
    }
  }

  /// Extraction intelligente d'informations (inspiré du dépôt externe)
  static Map<String, String?> extractServiceInfo(String text) {
    String textLower = text.toLowerCase();
    
    // Extraction du service
    String? service = _extractService(textLower);
    
    // Extraction du quartier
    String? quartier = _extractQuartier(textLower);
    
    // Extraction de l'urgence
    String? urgence = _extractUrgence(textLower);
    
    // Extraction du créneau
    String? creneau = _extractCreneau(textLower);

    return {
      'service': service,
      'quartier': quartier,
      'urgence': urgence,
      'creneau': creneau,
    };
  }

  /// Extrait le type de service depuis le texte
  static String? _extractService(String text) {
    List<String> services = [
      'coiffure', 'plomberie', 'électricité', 'ménage', 'jardinage',
      'menuiserie', 'mécanique', 'climatisation', 'informatique', 'couture',
      'peinture', 'massage', 'livraison', 'cuisine', 'sécurité', 'transport',
      'traduction', 'photographie', 'enseignement', 'réparation', 'nettoyage'
    ];

    for (String service in services) {
      if (text.contains(service)) {
        return service;
      }
    }
    return null;
  }

  /// Extrait le quartier depuis le texte
  static String? _extractQuartier(String text) {
    List<String> quartiers = [
      'cocody', 'plateau', 'marcory', 'yopougon', 'adjamé', 'abobo',
      'treichville', 'koumassi', 'port-bouët', 'bingerville', 'songon',
      'attécoubé', 'vridi', 'bassam', 'anyama', 'dabou', 'riviera'
    ];

    for (String quartier in quartiers) {
      if (text.contains(quartier)) {
        return quartier.substring(0, 1).toUpperCase() + quartier.substring(1);
      }
    }
    return null;
  }

  /// Extrait l'urgence depuis le texte
  static String? _extractUrgence(String text) {
    if (text.contains('urgent') || text.contains('vite') || text.contains('rapidement')) {
      return 'Oui';
    }
    if (text.contains('pas urgent') || text.contains('normal') || text.contains('quand vous pouvez')) {
      return 'Non';
    }
    return null;
  }

  /// Extrait le créneau horaire depuis le texte
  static String? _extractCreneau(String text) {
    if (text.contains('matin')) return 'Matin';
    if (text.contains('après-midi') || text.contains('apres-midi')) return 'Après-midi';
    if (text.contains('soir')) return 'Soir';
    return null;
  }

  /// Analyse de sentiment et recommandations contextuelles
  static Future<Map<String, dynamic>> analyzeAndRecommend(String userInput) async {
    await initialize();

    // Extraction d'informations
    Map<String, String?> extractedInfo = extractServiceInfo(userInput);
    
    // Recherche de services similaires
    List<Map<String, dynamic>> recommendations = [];
    
    if (extractedInfo['service'] != null) {
      // Trouver des prix pour ce service
      var pricingInfo = _pricingKnowledge
          .where((p) => p['metier'].toString().toLowerCase() == extractedInfo['service']!.toLowerCase())
          .toList();
      
      if (pricingInfo.isNotEmpty) {
        recommendations.add({
          'type': 'pricing',
          'message': 'Prix moyen pour ${extractedInfo['service']}: ${_calculateAveragePrice(pricingInfo)} FCFA',
          'data': pricingInfo.take(3).toList()
        });
      }
    }

    return {
      'extracted_info': extractedInfo,
      'recommendations': recommendations,
      'confidence': _calculateExtractionConfidence(extractedInfo),
    };
  }

  /// Calcule le prix moyen pour un service
  static int _calculateAveragePrice(List<Map<String, dynamic>> pricingData) {
    if (pricingData.isEmpty) return 0;
    
    int total = pricingData.fold(0, (sum, item) => sum + (item['prix_reel'] as int));
    return total ~/ pricingData.length;
  }

  /// Calcule la confiance de l'extraction
  static double _calculateExtractionConfidence(Map<String, String?> extracted) {
    int filledFields = extracted.values.where((v) => v != null).length;
    return filledFields / extracted.length;
  }

  /// Nettoie l'historique de conversation
  static void clearHistory() {
    _conversationHistory.clear();
  }

  /// Obtient les statistiques de la base de connaissances
  static Map<String, int> getKnowledgeStats() {
    return {
      'services': _servicesKnowledge.length,
      'pricing_entries': _pricingKnowledge.length,
      'matching_requests': _matchingKnowledge.length,
      'conversation_history': _conversationHistory.length,
    };
  }
}
