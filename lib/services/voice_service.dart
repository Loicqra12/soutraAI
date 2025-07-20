import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static VoiceService? _instance;
  static VoiceService get instance => _instance ??= VoiceService._();
  VoiceService._();

  // Services vocaux
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  
  // États
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastWords = '';

  // Callbacks
  Function(String)? onSpeechResult;
  Function(bool)? onListeningStateChanged;
  Function(bool)? onSpeakingStateChanged;

  // Initialiser le service vocal
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Vérifier la compatibilité Web
    if (kIsWeb) {
      print('⚠️ Fonctionnalités vocales limitées sur Flutter Web');
      print('💡 Les fonctionnalités vocales complètes sont disponibles sur mobile/desktop');
      _isInitialized = true;
      return true; // Retourner true pour permettre à l'app de fonctionner
    }

    try {
      // Initialiser Speech-to-Text (mobile/desktop uniquement)
      _speechToText = stt.SpeechToText();
      bool available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      if (!available) {
        print('❌ Speech-to-Text non disponible');
        return false;
      }

      // Initialiser Text-to-Speech
      _flutterTts = FlutterTts();
      await _configureTTS();

      _isInitialized = true;
      print('✅ Service vocal initialisé avec succès');
      return true;

    } catch (e) {
      print('❌ Erreur initialisation service vocal: $e');
      return false;
    }
  }

  // Configurer Text-to-Speech
  Future<void> _configureTTS() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      onSpeakingStateChanged?.call(true);
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      onSpeakingStateChanged?.call(false);
    });

    _flutterTts.setErrorHandler((msg) {
      print('❌ Erreur TTS: $msg');
      _isSpeaking = false;
      onSpeakingStateChanged?.call(false);
    });
  }

  // Démarrer l'écoute vocale
  Future<bool> startListening() async {
    // Vérifier la compatibilité Web
    if (kIsWeb) {
      print('⚠️ Reconnaissance vocale non disponible sur Flutter Web');
      return false;
    }

    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    // Vérifier les permissions
    bool hasPermission = await _checkMicrophonePermission();
    if (!hasPermission) return false;

    try {
      // Arrêter la lecture si en cours
      if (_isSpeaking) {
        await stopSpeaking();
      }

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'fr_FR',
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      _isListening = true;
      onListeningStateChanged?.call(true);
      return true;

    } catch (e) {
      print('❌ Erreur démarrage écoute: $e');
      return false;
    }
  }

  // Arrêter l'écoute vocale
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  // Parler (Text-to-Speech)
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return;
    }

    try {
      // Arrêter l'écoute si en cours
      if (_isListening) {
        await stopListening();
      }

      await _flutterTts.speak(text);
    } catch (e) {
      print('❌ Erreur synthèse vocale: $e');
    }
  }

  // Arrêter la synthèse vocale
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      onSpeakingStateChanged?.call(false);
    }
  }

  // Vérifier les permissions microphone
  Future<bool> _checkMicrophonePermission() async {
    PermissionStatus permission = await Permission.microphone.status;
    
    if (permission != PermissionStatus.granted) {
      permission = await Permission.microphone.request();
    }
    
    return permission == PermissionStatus.granted;
  }

  // Callback résultat de reconnaissance vocale
  void _onSpeechResult(result) {
    _lastWords = result.recognizedWords;
    onSpeechResult?.call(_lastWords);
    
    if (result.finalResult) {
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  // Callback statut de reconnaissance vocale
  void _onSpeechStatus(String status) {
    print('🎤 Statut Speech: $status');
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  // Callback erreur de reconnaissance vocale
  void _onSpeechError(error) {
    print('❌ Erreur Speech: ${error.errorMsg}');
    _isListening = false;
    onListeningStateChanged?.call(false);
  }

  // Obtenir les langues disponibles pour STT
  Future<List<stt.LocaleName>> getAvailableLanguages() async {
    if (!_isInitialized) await initialize();
    return await _speechToText.locales();
  }

  // Obtenir les voix disponibles pour TTS
  Future<List<dynamic>> getAvailableVoices() async {
    if (!_isInitialized) await initialize();
    return await _flutterTts.getVoices;
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;

  // Nettoyer les ressources
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
  }
}
