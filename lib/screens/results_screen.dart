import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';
import '../widgets/app_header.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});
  static const routeName = '/results';

  @override
  Widget build(BuildContext context) {
    // Mock data for providers
    final List<Map<String, dynamic>> _providers = [
      {
        'name': 'Marie K.',
        'service': 'Coiffeuse',
        'rating': 4.2,
        'location': 'Cocody',
        'availability': 'maintenant',
        'basePrice': 15000,
        'aiPrice': 12000,
        'aiMatch': 95,
        'experience': '5 ans',
      },
      {
        'name': 'Awa C.',
        'service': 'Coiffeuse',
        'rating': 4.5,
        'location': 'Plateau',
        'availability': 'dans 2h',
        'basePrice': 20000,
        'aiPrice': 18000,
        'aiMatch': 88,
        'experience': '8 ans',
      },
      {
        'name': 'Jean M.',
        'service': 'Coiffeur',
        'rating': 4.6,
        'location': 'Marcory',
        'availability': 'demain',
        'basePrice': 8000,
        'aiPrice': 7500,
        'aiMatch': 92,
        'experience': '3 ans',
      },
      {
        'name': 'Fatou B.',
        'service': 'Coiffeuse',
        'rating': 4.2,
        'location': 'Yopougon',
        'availability': 'ce soir',
        'basePrice': 12000,
        'aiPrice': 11000,
        'aiMatch': 85,
        'experience': '6 ans',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppHeader(
        title: 'Résultats',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Liste des prestataires
            Expanded(
              child: ListView.builder(
                itemCount: _providers.length,
                itemBuilder: (context, index) {
                  final provider = _providers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ...List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < provider['rating']!.floor()
                                          ? Icons.star
                                          : starIndex < provider['rating']!
                                              ? Icons.star_half
                                              : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    provider['rating']!.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider['service']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Contacter ${provider['name']!}'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Contacter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Boutons d'action en bas
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voir plus de prestataires')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Voir plus de prestataires',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AiChatScreen.routeName);
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
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
