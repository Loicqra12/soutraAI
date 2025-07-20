import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();
  GeminiService._();

  // Clé API Gemini (à configurer via variables d'environnement)
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyBY4H46SAJLa4UColqoMmJ2e2jBYvuRFF8', // Nouvelle clé API fournie
  );
  
  late final GenerativeModel _model;
  late final GenerativeModel _chatModel;
  bool _isInitialized = false;

  // Initialiser le service Gemini
  void initialize() {
    if (_isInitialized) return; // Éviter la double initialisation
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );

    _chatModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
      systemInstruction: Content.system(_getSoutraAISystemPrompt()),
    );
    
    _isInitialized = true;
  }

  // Prompt système pour Soutra AI
  String _getSoutraAISystemPrompt() {
    return '''
Tu es l'assistant IA de Soutra AI, une plateforme qui met en relation des clients et des prestataires de services en Côte d'Ivoire.

CONTEXTE SOUTRA AI :
- Services disponibles : coiffure, plomberie, électricité, mécanique, nettoyage, jardinage, cuisine, massage, livraison, transport, sécurité, informatique, couture, peinture, etc.
- Quartiers d'Abidjan : Cocody, Plateau, Yopougon, Marcory, Adjamé, Abobo, Treichville, Riviera, Koumassi, Port-Bouët, Bingerville, Songon, Attécoubé, Vridi, Bassam, Anyama, Dabou
- Langues : Français et Nouchi (argot ivoirien)
- Monnaie : Franc CFA (FCFA)

TON RÔLE :
- Aide les clients à trouver le bon prestataire
- Conseille sur les prix et négociations
- Traduis entre français et nouchi
- Donne des conseils pratiques sur les services
- Reste toujours poli, professionnel et bienveillant

STYLE DE RÉPONSE :
- Utilise un ton amical et professionnel
- Adapte-toi au niveau de langue de l'utilisateur
- Sois concis mais informatif
- Utilise des emojis appropriés
- Mentionne les spécificités locales ivoiriennes

EXEMPLES DE TRADUCTION NOUCHI :
- "Mo bɛ coiffeur dɛ" → "Je cherche un coiffeur"
- "A ka gbɛlɛ wari ye?" → "Combien ça coûte?"
- "Mo bɛ sɛbɛn na" → "Je veux écrire"
''';
  }

  // Chat avec Gemini (conversation continue)
  Future<String> chatWithGemini(String message, {List<Content>? history}) async {
    try {
      ChatSession chat;
      
      if (history != null && history.isNotEmpty) {
        chat = _chatModel.startChat(history: history);
      } else {
        chat = _chatModel.startChat();
      }

      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? 'Désolé, je n\'ai pas pu traiter votre demande.';
    } catch (e) {
      print('Erreur Gemini Chat: $e');
      return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }

  // Génération de contenu simple avec Gemini
  Future<String> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Aucune réponse générée.';
    } catch (e) {
      print('Erreur Gemini Generate: $e');
      return 'Une erreur s\'est produite lors de la génération.';
    }
  }

  // Traduire du nouchi vers le français
  Future<String> translateNouchiToFrench(String nouchiText) async {
    final prompt = '''
Traduis ce texte du nouchi (argot ivoirien) vers le français standard :
"$nouchiText"

Réponds uniquement avec la traduction française, sans explication.
''';
    return await generateContent(prompt);
  }

  // Suggérer des prestataires basé sur une demande
  Future<String> suggestProviders(String serviceType, String location, {bool isUrgent = false}) async {
    final prompt = '''
Un client cherche un service "$serviceType" à "$location" ${isUrgent ? '(URGENT)' : ''}.

Donne 3 conseils pratiques pour choisir le bon prestataire pour ce service en Côte d'Ivoire :
1. Critères de sélection
2. Fourchette de prix en FCFA
3. Questions à poser au prestataire

Réponds en français, sois concis et pratique.
''';
    return await generateContent(prompt);
  }

  // Estimer le prix d'un service
  Future<String> estimateServicePrice(String serviceType, String details) async {
    final prompt = '''
Estime le prix pour ce service en Côte d'Ivoire :
Service : $serviceType
Détails : $details

Donne :
- Prix minimum en FCFA
- Prix moyen en FCFA  
- Prix maximum en FCFA
- Facteurs qui influencent le prix

Réponds en français, format court et clair.
''';
    return await generateContent(prompt);
  }

  // Conseils de négociation
  Future<String> getNegotiationTips(String serviceType, int proposedPrice) async {
    final prompt = '''
Un client veut négocier le prix d'un service "$serviceType" proposé à $proposedPrice FCFA.

Donne 3 conseils de négociation adaptés au contexte ivoirien :
1. Comment négocier respectueusement
2. Arguments valables pour baisser le prix
3. Quand accepter le prix proposé

Réponds en français, sois pratique et culturellement approprié.
''';
    return await generateContent(prompt);
  }

  // Analyser une demande de service et donner des suggestions
  Future<Map<String, String>> analyzeServiceRequest(String service, String location, String details) async {
    final suggestions = await suggestProviders(service, location);
    final priceEstimate = await estimateServicePrice(service, details);
    
    return {
      'suggestions': suggestions,
      'priceEstimate': priceEstimate,
      'location': location,
      'service': service,
    };
  }

  // Générer une réponse contextuelle pour l'assistant IA
  Future<String> generateAssistantResponse(String userMessage, {
    String? currentService,
    String? currentLocation,
    List<String>? availableProviders,
  }) async {
    String context = '';
    
    if (currentService != null) {
      context += 'Service recherché : $currentService\n';
    }
    if (currentLocation != null) {
      context += 'Localisation : $currentLocation\n';
    }
    if (availableProviders != null && availableProviders.isNotEmpty) {
      context += 'Prestataires disponibles : ${availableProviders.join(', ')}\n';
    }

    final prompt = '''
$context

Message de l'utilisateur : "$userMessage"

Réponds comme l'assistant IA de Soutra AI. Sois utile, amical et professionnel.
Si l'utilisateur pose une question sur les services, donne des conseils pratiques.
Si c'est du nouchi, réponds en français mais montre que tu comprends.
''';

    return await generateContent(prompt);
  }

  // Vérifier si le service est initialisé
  bool get isInitialized => _model != null && _chatModel != null;
}
