import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import '../services/advanced_ai_service.dart';
import '../services/advanced_tts_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  static const routeName = '/ai-chat';

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService.instance;
  final VoiceService _voiceService = VoiceService.instance;
  List<Content> _chatHistory = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isAdvancedModeEnabled = true; // Mode RAG activé par défaut
  bool _isTTSEnabled = true; // Synthèse vocale premium activée

  @override
  void initState() {
    super.initState();
    _geminiService.initialize();
    _voiceService.initialize();
    _initializeAdvancedServices();
    _addWelcomeMessage();
  }

  /// Initialise les services avancés (RAG et TTS premium)
  Future<void> _initializeAdvancedServices() async {
    try {
      await AdvancedAIService.initialize();
      await AdvancedTTSService.initialize();
      print('✅ Services avancés initialisés (RAG + TTS premium)');
    } catch (e) {
      print('⚠️ Erreur initialisation services avancés: $e');
    }
  }

  void _addWelcomeMessage() {
    _messages.add({
      'text': '🚀 Salut ! Je suis votre Assistant IA Soutra ultra-intelligent !\n\n💡 **Nouvelles fonctionnalités avancées :**\n• 🧠 **Mode RAG** : Recherche intelligente dans nos données locales\n• 🎤 **Synthèse vocale premium** : Voix française optimisée\n• 📊 **Analyse contextuelle** : Réponses basées sur vos données réelles\n\n**Comment puis-je vous aider ?**\n• Trouver le meilleur prestataire\n• Estimer les prix avec précision\n• Traduire du nouchi\n• Analyser vos demandes\n\n🎯 **Essayez :** "Trouve-moi un électricien à Cocody" ou "Combien coûte une coiffure ?"',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  /// Envoie un message avec RAG ou Gemini classique
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      String response;
      
      if (_isAdvancedModeEnabled) {
        // Mode RAG avancé avec nos datasets locaux
        response = await AdvancedAIService.generateRAGResponse(message);
      } else {
        // Mode Gemini classique
        _chatHistory.add(Content.text(message));
        response = await _geminiService.chatWithGemini(
          message,
          history: _chatHistory,
        );
        _chatHistory.add(Content.text(response));
      }

      setState(() {
        _messages.add({
          'text': response,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });

      _scrollToBottom();

      // Synthèse vocale premium si activée
      if (_isTTSEnabled) {
        await AdvancedTTSService.speak(response);
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'Désolé, une erreur s\'est produite. Veuillez réessayer.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }
  }

  /// Démarre l'écoute vocale
  Future<void> _startListening() async {
    if (_isListening) return;
    
    setState(() => _isListening = true);
    
    try {
      // Configurer le callback pour recevoir le texte reconnu
      _voiceService.onSpeechResult = (recognizedText) {
        if (recognizedText.isNotEmpty) {
          setState(() {
            _messageController.text = recognizedText;
          });
        }
      };
      
      // Démarrer l'écoute
      bool success = await _voiceService.startListening();
      if (!success) {
        throw Exception('Impossible de démarrer la reconnaissance vocale');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur reconnaissance vocale: $e')),
      );
    } finally {
      setState(() => _isListening = false);
    }
  }

  /// Arrête l'écoute vocale
  Future<void> _stopListening() async {
    if (!_isListening) return;
    
    await _voiceService.stopListening();
    setState(() => _isListening = false);
  }

  /// Fait défiler vers le bas
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppHeader(title: 'Assistant IA Soutra'),
      body: Column(
        children: [
          // Barre de contrôles avancés
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Toggle Mode RAG
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isAdvancedModeEnabled ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAdvancedModeEnabled ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color: _isAdvancedModeEnabled ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mode RAG',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isAdvancedModeEnabled ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: _isAdvancedModeEnabled,
                        onChanged: (value) {
                          setState(() => _isAdvancedModeEnabled = value);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Toggle TTS Premium
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isTTSEnabled ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isTTSEnabled ? Colors.blue : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: 16,
                        color: _isTTSEnabled ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'TTS Premium',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isTTSEnabled ? Colors.blue : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: _isTTSEnabled,
                        onChanged: (value) {
                          setState(() => _isTTSEnabled = value);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Zone de chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingMessage();
                }
                
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton micro
                GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton envoyer
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'] as String,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.smart_toy,
                  size: 16,
                  color: isUser ? Colors.white70 : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  isUser ? 'Vous' : (_isAdvancedModeEnabled ? 'Soutra AI (RAG)' : 'Soutra AI'),
                  style: TextStyle(
                    color: isUser ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isAdvancedModeEnabled 
                ? 'Analyse RAG en cours...' 
                : 'Réflexion en cours...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
