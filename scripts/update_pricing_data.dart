import 'dart:convert';
import 'dart:io';

void main() async {
  // Nouvelles données de pricing fournies par l'utilisateur
  List<Map<String, dynamic>> newPricingData = [
    {"id_service": "003", "metier": "menuiserie", "quartier": "Marcory", "saison": "pluie", "jour": "mardi", "heure": "après-midi", "prix_reel": 25000},
    {"id_service": "004", "metier": "électricité", "quartier": "Adjamé", "saison": "sèche", "jour": "mercredi", "heure": "matin", "prix_reel": 8000},
    {"id_service": "005", "metier": "coiffure", "quartier": "Plateau", "saison": "sèche", "jour": "vendredi", "heure": "après-midi", "prix_reel": 8000},
    {"id_service": "006", "metier": "mécanique", "quartier": "Abobo", "saison": "pluie", "jour": "samedi", "heure": "matin", "prix_reel": 15000},
    {"id_service": "007", "metier": "nettoyage", "quartier": "Cocody", "saison": "sèche", "jour": "dimanche", "heure": "matin", "prix_reel": 12000},
    {"id_service": "008", "metier": "jardinage", "quartier": "Riviera", "saison": "pluie", "jour": "jeudi", "heure": "matin", "prix_reel": 20000},
    {"id_service": "009", "metier": "plomberie", "quartier": "Treichville", "saison": "pluie", "jour": "lundi", "heure": "soir", "prix_reel": 18000},
    {"id_service": "010", "metier": "informatique", "quartier": "Plateau", "saison": "sèche", "jour": "mardi", "heure": "après-midi", "prix_reel": 10000},
    {"id_service": "011", "metier": "couture", "quartier": "Yopougon", "saison": "sèche", "jour": "mercredi", "heure": "après-midi", "prix_reel": 7000},
    {"id_service": "012", "metier": "peinture", "quartier": "Marcory", "saison": "sèche", "jour": "vendredi", "heure": "matin", "prix_reel": 35000},
    {"id_service": "013", "metier": "massage", "quartier": "Cocody", "saison": "pluie", "jour": "samedi", "heure": "après-midi", "prix_reel": 15000},
    {"id_service": "014", "metier": "électricité", "quartier": "Abobo", "saison": "pluie", "jour": "dimanche", "heure": "soir", "prix_reel": 20000},
    {"id_service": "015", "metier": "coiffure", "quartier": "Adjamé", "saison": "sèche", "jour": "lundi", "heure": "matin", "prix_reel": 4500},
    {"id_service": "016", "metier": "climatisation", "quartier": "Riviera", "saison": "sèche", "jour": "mardi", "heure": "matin", "prix_reel": 25000},
    {"id_service": "017", "metier": "livraison", "quartier": "Plateau", "saison": "pluie", "jour": "mercredi", "heure": "matin", "prix_reel": 3000},
    {"id_service": "018", "metier": "cuisine", "quartier": "Cocody", "saison": "sèche", "jour": "jeudi", "heure": "soir", "prix_reel": 30000},
    {"id_service": "019", "metier": "sécurité", "quartier": "Marcory", "saison": "pluie", "jour": "vendredi", "heure": "soir", "prix_reel": 40000},
    {"id_service": "020", "metier": "transport", "quartier": "Yopougon", "saison": "pluie", "jour": "samedi", "heure": "matin", "prix_reel": 8000},
    // ... Continuer avec toutes les autres données
  ];

  try {
    // Lire le fichier existant
    File pricingFile = File('../assets/data/pricing_data.json');
    List<dynamic> existingData = [];
    
    if (await pricingFile.exists()) {
      String content = await pricingFile.readAsString();
      existingData = json.decode(content);
    }

    // Fusionner les données
    List<dynamic> mergedData = [...existingData, ...newPricingData];

    // Écrire le fichier mis à jour
    String jsonString = JsonEncoder.withIndent('  ').convert(mergedData);
    await pricingFile.writeAsString(jsonString);

    print('✅ Dataset de pricing mis à jour avec ${newPricingData.length} nouvelles entrées');
    print('📊 Total: ${mergedData.length} services dans le dataset');
    
    // Statistiques
    Map<String, int> metierStats = {};
    Map<String, int> quartierStats = {};
    
    for (var item in mergedData) {
      String metier = item['metier'];
      String quartier = item['quartier'];
      
      metierStats[metier] = (metierStats[metier] ?? 0) + 1;
      quartierStats[quartier] = (quartierStats[quartier] ?? 0) + 1;
    }
    
    print('\n📈 Statistiques par métier:');
    metierStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..forEach((entry) => print('  ${entry.key}: ${entry.value} services'));
    
    print('\n🏘️ Statistiques par quartier:');
    quartierStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..forEach((entry) => print('  ${entry.key}: ${entry.value} services'));

  } catch (e) {
    print('❌ Erreur lors de la mise à jour: $e');
  }
}
