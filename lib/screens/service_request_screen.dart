import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import 'package:soutra_ai/services/matching_service.dart';
import 'package:soutra_ai/services/pricing_service.dart';
import '../services/data_service.dart';
import '../models/provider.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});
  static const routeName = '/service-request';

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _serviceController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isUrgent = false;
  String _timeSlot = 'Après-midi';
  bool _isLoading = false;
  List<Provider> _providers = [];
  Map<String, dynamic>? _matchingStats;
  Map<String, dynamic>? _priceEstimation;
  bool _isPriceLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppHeader(
        title: 'Demande de Service',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service recherché
            const Text(
              'Service recherché :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _serviceController,
              decoration: InputDecoration(
                hintText: 'ex. "plombier", "coiffeuse", "développeur"',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Quartier
            const Text(
              'Quartier :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Saisie libre ou géolocalisation',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: const Icon(Icons.location_on, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Urgence et Heure
            Row(
              children: [
                // Urgence
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Urgence :',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _isUrgent,
                            onChanged: (value) {
                              setState(() {
                                _isUrgent = value!;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                          const Text('Oui'),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: _isUrgent,
                            onChanged: (value) {
                              setState(() {
                                _isUrgent = value!;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                          const Text('Non'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Heure souhaitée
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Heure souhaitée :',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _timeSlot,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'Après-midi', child: Text('Après-midi')),
                              DropdownMenuItem(value: 'Matin', child: Text('Matin')),
                              DropdownMenuItem(value: 'Soir', child: Text('Soir')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _timeSlot = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Estimation IA Dynamique
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  _isPriceLoading 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.assessment, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _priceEstimation != null
                            ? 'Estimation IA: ${PricingService.formatPrice(_priceEstimation!['prix_estime'])}'
                            : 'Estimation de prix (via IA)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (_priceEstimation != null) ...[
                          Text(
                            'Fourchette: ${PricingService.formatPriceRange(_priceEstimation!['fourchette_min'], _priceEstimation!['fourchette_max'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          if (_priceEstimation!['contexte'] != null && _priceEstimation!['contexte'].isNotEmpty)
                            Text(
                              _priceEstimation!['contexte'].join(' • '),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ] else
                          Text(
                            'Saisissez un service et un quartier',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Suggestions IA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Suggestion IA de prestataires :',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _matchingStats != null 
                      ? '${_matchingStats!['totalRequests']} demandes traitées • ${_providers.length} prestataires disponibles'
                      : 'Chargement des statistiques...',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Prestataire 1
                  _buildProviderSuggestion(
                    'Yao Mathieu',
                    'Plombier',
                    'assets/images/provider1.jpg',
                  ),
                  const SizedBox(height: 8),
                  // Prestataire 2
                  _buildProviderSuggestion(
                    'Ange koffi',
                    'Plombier',
                    'assets/images/provider2.jpg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Boutons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _performRealMatching,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Rechercher',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Bouton Assistant IA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/ai-chat');
                },
                icon: const Icon(Icons.psychology, color: Colors.black87),
                label: const Text(
                  'Assistant IA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSuggestion(String name, String profession, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  profession,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Voir le profil du prestataire
            },
            child: const Text(
              'Voir',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showAiTranslationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.translate, color: Colors.blue),
            SizedBox(width: 8),
            Text('Traduction Nouchi → Français'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exemples de traductions :', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('"Mo bɛ coiffeur dɛ" → "Je cherche un coiffeur"'),
            SizedBox(height: 8),
            Text('"A ka gbɛlɛ wari ye?" → "Combien ça coûte?"'),
            SizedBox(height: 8),
            Text('"Mo bɛ sɛbɛn na" → "Je veux écrire"'),
            SizedBox(height: 12),
            Text('L\'IA comprend le nouchi et traduit automatiquement vos demandes !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showAiSuggestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.blue),
            SizedBox(width: 8),
            Text('Suggestions IA'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('L\'IA analyse votre demande :', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAiSuggestion('💡', 'Service recommandé : Coiffure (tresses)'),
            _buildAiSuggestion('📍', 'Meilleure zone : Pikine (3 coiffeurs disponibles)'),
            _buildAiSuggestion('💰', 'Prix estimé : 12,000 - 18,000 FCFA'),
            _buildAiSuggestion('⏰', 'Meilleur créneau : 14h-16h (moins d\'attente)'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                '🎯 Match IA : 95% - Fatou Bintou est parfaite pour vous !',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/results');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Voir les résultats', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestion(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // Initialiser les données au démarrage
  @override
  void initState() {
    super.initState();
    _loadProvidersData();
    
    // Écouter les changements dans le champ service pour estimation prix
    _serviceController.addListener(_onServiceChanged);
    _locationController.addListener(_onLocationChanged);
  }



  // Déclencher l'estimation de prix quand le service change
  void _onServiceChanged() {
    if (_serviceController.text.isNotEmpty && _locationController.text.isNotEmpty) {
      _estimatePrice();
    }
  }

  // Déclencher l'estimation de prix quand la localisation change
  void _onLocationChanged() {
    if (_serviceController.text.isNotEmpty && _locationController.text.isNotEmpty) {
      _estimatePrice();
    }
  }

  // Estimer le prix automatiquement
  Future<void> _estimatePrice() async {
    if (_serviceController.text.isEmpty || _locationController.text.isEmpty) {
      setState(() {
        _priceEstimation = null;
      });
      return;
    }

    setState(() => _isPriceLoading = true);

    try {
      String currentSeason = _getCurrentSeason();
      String currentDay = _getDayFromTimeSlot(_timeSlot);
      
      Map<String, dynamic> estimation = await PricingService.estimatePrice(
        metier: _serviceController.text.toLowerCase(),
        quartier: _locationController.text,
        jour: currentDay,
        heure: _timeSlot.toLowerCase(),
        saison: currentSeason,
      );

      setState(() {
        _priceEstimation = estimation;
        _isPriceLoading = false;
      });
    } catch (e) {
      print('Erreur estimation prix: $e');
      setState(() => _isPriceLoading = false);
    }
  }

  // Déterminer la saison actuelle
  String _getCurrentSeason() {
    int month = DateTime.now().month;
    // Saison des pluies en Côte d'Ivoire: Mai à Octobre
    return (month >= 5 && month <= 10) ? 'pluie' : 'sèche';
  }

  // Charger les prestataires depuis DataService
  Future<void> _loadProvidersData() async {
    try {
      setState(() => _isLoading = true);
      final dataService = DataService.instance;
      _providers = await dataService.loadProviders();
      _matchingStats = await MatchingService.analyzeMatchingTrends();
      setState(() => _isLoading = false);
    } catch (e) {
      print('Erreur lors du chargement des prestataires: $e');
      setState(() => _isLoading = false);
    }
  }

  // Effectuer le matching réel
  Future<void> _performRealMatching() async {
    if (_serviceController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Créer une demande de matching
      Map<String, dynamic> request = {
        'id_demande': DateTime.now().millisecondsSinceEpoch.toString(),
        'service': _serviceController.text.toLowerCase(),
        'quartier': _locationController.text,
        'urgence': _isUrgent,
        'jour': _getDayFromTimeSlot(_timeSlot),
        'heure': _timeSlot.toLowerCase(),
        'langue': 'fr',
        'mots_cles': _extractKeywords(_serviceController.text),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Obtenir les meilleurs matches
      List<Map<String, dynamic>> matches = await MatchingService.getBestMatches(request, _providers);
      
      setState(() => _isLoading = false);

      if (matches.isNotEmpty) {
        // Afficher les résultats de matching
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${matches.length} prestataires trouvés ! Score max: ${matches.first['score'].toInt()}%'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Naviguer vers l'écran de résultats
        Navigator.of(context).pushNamed('/results');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun prestataire trouvé pour cette demande'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la recherche: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Extraire les mots-clés du service demandé
  List<String> _extractKeywords(String service) {
    return service.toLowerCase().split(' ').where((word) => word.length > 2).toList();
  }

  // Convertir le créneau horaire en jour
  String _getDayFromTimeSlot(String timeSlot) {
    DateTime now = DateTime.now();
    switch (timeSlot.toLowerCase()) {
      case 'matin':
        return _getDayName(now);
      case 'après-midi':
        return _getDayName(now);
      case 'soir':
        return _getDayName(now);
      default:
        return _getDayName(now.add(const Duration(days: 1)));
    }
  }

  // Obtenir le nom du jour en français
  String _getDayName(DateTime date) {
    const days = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
    return days[date.weekday - 1];
  }

  @override
  void dispose() {
    _serviceController.removeListener(_onServiceChanged);
    _locationController.removeListener(_onLocationChanged);
    _serviceController.dispose();
    _locationController.dispose();
    super.dispose();
  }
} 