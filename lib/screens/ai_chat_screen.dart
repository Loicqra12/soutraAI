import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
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
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _initializeVoice();
    // Message d'accueil de l'assistant IA
    _messages.add({
      'text': '👋 Salut ! Je suis votre assistant IA Soutra. Comment puis-je vous aider aujourd\'hui ?\n\n💡 Je peux vous aider à :\n• Trouver le bon prestataire\n• Estimer les prix\n• Traduire du nouchi\n• Négocier les tarifs\n\n🎤 Appuyez sur le micro pour parler !',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  void _initializeGemini() {
    try {
      _geminiService.initialize();
      print('✅ Gemini AI initialisé avec succès');
    } catch (e) {
      print('❌ Erreur initialisation Gemini: $e');
    }
  }

  void _initializeVoice() {
    _voiceService.onSpeechResult = (String result) {
      if (result.isNotEmpty) {
        _messageController.text = result;
        _sendMessage(result);
      }
    };

    _voiceService.onListeningStateChanged = (bool isListening) {
      setState(() {
        _isListening = isListening;
      });
    };

    _voiceService.onSpeakingStateChanged = (bool isSpeaking) {
      setState(() {
        _isSpeaking = isSpeaking;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppHeader(
        title: 'Assistant IA',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              // Microphone pour la saisie vocale
            },
            icon: const Icon(Icons.mic, color: Colors.white),
            tooltip: 'Saisie vocale',
          ),
        ],
      ),
      body: Column(
        children: [
          // Questions suggérées en haut
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSuggestedQuestion('Trouver un prestataire'),
                const SizedBox(height: 8),
                _buildSuggestedQuestion('Combien coûte une prestation à Cocody ?'),
                const SizedBox(height: 8),
                _buildSuggestedQuestion('Quels services sont les plus demandés ?'),
              ],
            ),
          ),
          
          // Zone de chat
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingIndicator();
                  }
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),
          
          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
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
                      hintText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      prefixIcon: const Icon(Icons.message, color: Colors.grey),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage(text);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _toggleVoiceInput,
                  backgroundColor: _isListening ? Colors.red : (_isSpeaking ? Colors.orange : Colors.green),
                  mini: true,
                  child: Icon(
                    _isListening ? Icons.mic : (_isSpeaking ? Icons.volume_up : Icons.mic),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestion(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      child: OutlinedButton(
        onPressed: () {
          _messageController.text = text;
          _sendMessage(text);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as DateTime;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: const Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Ajouter le message utilisateur
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();

    try {
      // Ajouter le message à l'historique pour Gemini
      _chatHistory.add(Content.text(text));
      
      // Obtenir la réponse de Gemini AI
      String aiResponse = await _geminiService.chatWithGemini(
        text, 
        history: _chatHistory.isNotEmpty ? _chatHistory : null
      );
      
      // Ajouter la réponse IA à l'historique
      _chatHistory.add(Content.text(aiResponse));
      
      setState(() {
        _messages.add({
          'text': aiResponse,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
      
      // Lire la réponse à voix haute
      await _voiceService.speak(aiResponse);
      
    } catch (e) {
      print('❌ Erreur Gemini: $e');
      setState(() {
        _messages.add({
          'text': 'Désolé, je rencontre un problème technique. Pouvez-vous réessayer ?',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }
    
    // Scroll vers le bas
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Basculer l'entrée vocale
  void _toggleVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
    } else if (_isSpeaking) {
      await _voiceService.stopSpeaking();
    } else {
      bool success = await _voiceService.startListening();
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'activer le microphone. Vérifiez les permissions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green,
            child: const Icon(Icons.psychology, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'L\'assistant IA réfléchit...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
