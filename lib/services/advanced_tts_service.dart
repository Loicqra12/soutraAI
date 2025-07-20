import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

/// Service de synthèse vocale avancé inspiré du dépôt externe
/// Optimisé pour le français avec configuration premium
class AdvancedTTSService {
  static FlutterTts? _flutterTts;
  static bool _isInitialized = false;
  static bool _isSpeaking = false;

  /// Initialise le service TTS avec configuration optimisée
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();
      await _configureOptimalSettings();
      _isInitialized = true;
      print('✅ AdvancedTTSService initialisé avec configuration premium');
    } catch (e) {
      print('❌ Erreur initialisation AdvancedTTSService: $e');
    }
  }

  /// Configure les paramètres optimaux pour le français
  static Future<void> _configureOptimalSettings() async {
    if (_flutterTts == null) return;

    try {
      // Configuration de base
      await _flutterTts!.setLanguage('fr-FR');
      await _flutterTts!.setSpeechRate(0.6); // Vitesse optimisée (équivalent 210 WPM)
      await _flutterTts!.setVolume(0.8);
      await _flutterTts!.setPitch(1.0);

      // Configuration spécifique par plateforme
      if (Platform.isWindows) {
        await _configureWindowsVoice();
      } else if (Platform.isAndroid) {
        await _configureAndroidVoice();
      } else if (Platform.isIOS) {
        await _configureiOSVoice();
      }

      // Callbacks pour le suivi d'état
      _flutterTts!.setStartHandler(() {
        _isSpeaking = true;
        print('🔊 TTS démarré');
      });

      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
        print('✅ TTS terminé');
      });

      _flutterTts!.setErrorHandler((msg) {
        _isSpeaking = false;
        print('❌ Erreur TTS: $msg');
      });

    } catch (e) {
      print('⚠️ Erreur configuration TTS: $e');
    }
  }

  /// Configuration optimisée pour Windows (inspiré du dépôt externe)
  static Future<void> _configureWindowsVoice() async {
    try {
      // Essayer d'utiliser la voix française Hortense (comme dans le dépôt externe)
      List<dynamic> voices = await _flutterTts!.getVoices;
      
      // Rechercher les voix françaises disponibles
      var frenchVoices = voices.where((voice) => 
        voice['locale'].toString().startsWith('fr') ||
        voice['name'].toString().toLowerCase().contains('french') ||
        voice['name'].toString().toLowerCase().contains('hortense')
      ).toList();

      if (frenchVoices.isNotEmpty) {
        // Priorité à Hortense si disponible
        var hortenseVoice = frenchVoices.firstWhere(
          (voice) => voice['name'].toString().toLowerCase().contains('hortense'),
          orElse: () => frenchVoices.first
        );
        
        await _flutterTts!.setVoice({
          'name': hortenseVoice['name'],
          'locale': hortenseVoice['locale']
        });
        
        print('🎤 Voix française configurée: ${hortenseVoice['name']}');
      }
    } catch (e) {
      print('⚠️ Configuration voix Windows: $e');
    }
  }

  /// Configuration pour Android
  static Future<void> _configureAndroidVoice() async {
    try {
      List<dynamic> voices = await _flutterTts!.getVoices;
      
      var frenchVoices = voices.where((voice) => 
        voice['locale'].toString().startsWith('fr')
      ).toList();

      if (frenchVoices.isNotEmpty) {
        await _flutterTts!.setVoice({
          'name': frenchVoices.first['name'],
          'locale': frenchVoices.first['locale']
        });
        print('🎤 Voix française Android configurée');
      }
    } catch (e) {
      print('⚠️ Configuration voix Android: $e');
    }
  }

  /// Configuration pour iOS
  static Future<void> _configureiOSVoice() async {
    try {
      List<dynamic> voices = await _flutterTts!.getVoices;
      
      var frenchVoices = voices.where((voice) => 
        voice['locale'].toString().startsWith('fr')
      ).toList();

      if (frenchVoices.isNotEmpty) {
        await _flutterTts!.setVoice({
          'name': frenchVoices.first['name'],
          'locale': frenchVoices.first['locale']
        });
        print('🎤 Voix française iOS configurée');
      }
    } catch (e) {
      print('⚠️ Configuration voix iOS: $e');
    }
  }

  /// Lit un texte avec optimisations avancées
  static Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null || text.trim().isEmpty) return;

    try {
      // Arrêter toute lecture en cours
      await stop();

      // Préprocessing du texte pour optimiser la lecture
      String optimizedText = _preprocessText(text);

      // Lecture avec gestion d'erreur
      await _flutterTts!.speak(optimizedText);
      
    } catch (e) {
      print('❌ Erreur lors de la lecture: $e');
      _isSpeaking = false;
    }
  }

  /// Préprocessing du texte pour optimiser la synthèse vocale
  static String _preprocessText(String text) {
    String processed = text;

    // Remplacements pour améliorer la prononciation
    Map<String, String> replacements = {
      'FCFA': 'francs CFA',
      'CFA': 'francs CFA',
      'IA': 'intelligence artificielle',
      'AI': 'intelligence artificielle',
      'SMS': 'S M S',
      'GPS': 'G P S',
      'WiFi': 'Wi-Fi',
      'WhatsApp': 'WhatsApp',
      'COVID': 'Covid',
      'COVID-19': 'Covid dix-neuf',
      '&': 'et',
      '@': 'arobase',
      '%': 'pourcent',
      '€': 'euros',
      '\$': 'dollars',
      // Expressions nouchi courantes
      'walaï': 'vraiment',
      'dêh': 'alors',
      'tchê': 'regarde',
    };

    for (var entry in replacements.entries) {
      processed = processed.replaceAll(entry.key, entry.value);
    }

    // Ajouter des pauses pour une meilleure compréhension
    processed = processed.replaceAll('.', '. ');
    processed = processed.replaceAll(',', ', ');
    processed = processed.replaceAll(';', '; ');
    processed = processed.replaceAll(':', ': ');

    // Nettoyer les espaces multiples
    processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();

    return processed;
  }

  /// Arrête la lecture en cours
  static Future<void> stop() async {
    if (_flutterTts != null && _isSpeaking) {
      try {
        await _flutterTts!.stop();
        _isSpeaking = false;
      } catch (e) {
        print('⚠️ Erreur arrêt TTS: $e');
      }
    }
  }

  /// Met en pause la lecture
  static Future<void> pause() async {
    if (_flutterTts != null && _isSpeaking) {
      try {
        await _flutterTts!.pause();
      } catch (e) {
        print('⚠️ Erreur pause TTS: $e');
      }
    }
  }

  /// Ajuste la vitesse de lecture
  static Future<void> setSpeechRate(double rate) async {
    if (_flutterTts != null) {
      try {
        // Limiter la vitesse entre 0.1 et 1.0
        double clampedRate = rate.clamp(0.1, 1.0);
        await _flutterTts!.setSpeechRate(clampedRate);
      } catch (e) {
        print('⚠️ Erreur vitesse TTS: $e');
      }
    }
  }

  /// Ajuste le volume
  static Future<void> setVolume(double volume) async {
    if (_flutterTts != null) {
      try {
        double clampedVolume = volume.clamp(0.0, 1.0);
        await _flutterTts!.setVolume(clampedVolume);
      } catch (e) {
        print('⚠️ Erreur volume TTS: $e');
      }
    }
  }

  /// Vérifie si une lecture est en cours
  static bool get isSpeaking => _isSpeaking;

  /// Obtient les voix disponibles
  static Future<List<Map<String, String>>> getAvailableVoices() async {
    if (!_isInitialized) await initialize();
    
    if (_flutterTts == null) return [];

    try {
      List<dynamic> voices = await _flutterTts!.getVoices;
      return voices.map((voice) => {
        'name': voice['name'].toString(),
        'locale': voice['locale'].toString(),
      }).toList();
    } catch (e) {
      print('⚠️ Erreur récupération voix: $e');
      return [];
    }
  }

  /// Obtient les voix françaises disponibles
  static Future<List<Map<String, String>>> getFrenchVoices() async {
    List<Map<String, String>> allVoices = await getAvailableVoices();
    return allVoices.where((voice) => 
      voice['locale']!.startsWith('fr') ||
      voice['name']!.toLowerCase().contains('french')
    ).toList();
  }

  /// Nettoie les ressources
  static Future<void> dispose() async {
    if (_flutterTts != null) {
      await stop();
      _flutterTts = null;
      _isInitialized = false;
      _isSpeaking = false;
    }
  }

  /// Teste la synthèse vocale avec un message d'accueil
  static Future<void> testVoice() async {
    await speak('Bonjour ! Je suis SoutraAI, votre assistant intelligent pour les services en Côte d\'Ivoire. Comment puis-je vous aider aujourd\'hui ?');
  }
}
