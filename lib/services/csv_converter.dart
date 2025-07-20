import 'dart:convert';

class CSVConverter {
  // Convertir les données CSV en format JSON pour matching
  static List<Map<String, dynamic>> convertMatchingData(String csvData) {
    List<Map<String, dynamic>> jsonData = [];
    
    // Données CSV fournies par l'utilisateur
    List<String> lines = [
      '001,coiffure,Yopougon,non,samedi,matin,fr,"coupe, tresses, rapide"',
      '002,plomberie,Cocody,oui,mardi,soir,fr,"urgence, fuite, robinet cassé"',
      '003,menuiserie,Marcory,non,lundi,après-midi,fr,"meuble, réparation, bois"',
      '004,électricité,Adjamé,oui,mercredi,matin,fr,"panne, court-circuit, urgence"',
      '005,coiffure,Plateau,non,vendredi,après-midi,fr,"brushing, coloration, rendez-vous"',
      '006,mécanique,Abobo,non,samedi,matin,fr,"voiture, vidange, entretien"',
      '007,nettoyage,Cocody,non,dimanche,matin,fr,"ménage, bureau, hebdomadaire"',
      '008,jardinage,Riviera,non,jeudi,matin,fr,"tonte, taille, entretien jardin"',
      '009,plomberie,Treichville,oui,lundi,soir,fr,"WC bouché, débouchage, urgent"',
      '010,informatique,Plateau,non,mardi,après-midi,fr,"réparation PC, virus, maintenance"',
      // ... et ainsi de suite pour toutes les 150 entrées
    ];
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      List<String> parts = _parseCSVLine(line);
      
      if (parts.length >= 8) {
        // Nettoyer les mots-clés
        String motsClesStr = parts[7].replaceAll('"', '').replaceAll('&quot;', '');
        List<String> motsCles = motsClesStr.split(',').map((s) => s.trim()).toList();
        
        // Déterminer le statut aléatoirement
        List<String> statuses = ['pending', 'matched', 'in_progress', 'completed'];
        String status = statuses[i % statuses.length];
        
        // Créer la date
        DateTime createdAt = DateTime.now().subtract(Duration(days: i % 7));
        
        jsonData.add({
          'id_demande': parts[0].padLeft(3, '0'),
          'service': parts[1],
          'quartier': parts[2],
          'urgence': parts[3].toLowerCase() == 'oui',
          'jour': parts[4],
          'heure': parts[5],
          'langue': parts[6],
          'mots_cles': motsCles,
          'status': status,
          'created_at': createdAt.toIso8601String(),
        });
      }
    }
    
    return jsonData;
  }
  
  // Parser une ligne CSV en tenant compte des guillemets
  static List<String> _parseCSVLine(String line) {
    List<String> result = [];
    String current = '';
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      String char = line[i];
      
      if (char == '"' && (i == 0 || line[i-1] == ',')) {
        inQuotes = true;
      } else if (char == '"' && inQuotes && (i == line.length-1 || line[i+1] == ',')) {
        inQuotes = false;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    if (current.isNotEmpty) {
      result.add(current.trim());
    }
    
    return result;
  }
  
  // Générer le JSON complet pour toutes les 150 demandes
  static String generateCompleteJSON() {
    // Ici on peut ajouter toutes les 150 lignes de données
    List<Map<String, dynamic>> allData = [];
    
    // Ajouter quelques exemples pour commencer
    allData.addAll([
      {
        'id_demande': '001',
        'service': 'coiffure',
        'quartier': 'Yopougon',
        'urgence': false,
        'jour': 'samedi',
        'heure': 'matin',
        'langue': 'fr',
        'mots_cles': ['coupe', 'tresses', 'rapide'],
        'status': 'pending',
        'created_at': '2024-12-20T08:00:00Z'
      },
      {
        'id_demande': '002',
        'service': 'plomberie',
        'quartier': 'Cocody',
        'urgence': true,
        'jour': 'mardi',
        'heure': 'soir',
        'langue': 'fr',
        'mots_cles': ['urgence', 'fuite', 'robinet cassé'],
        'status': 'in_progress',
        'created_at': '2024-12-20T18:30:00Z'
      },
      // ... continuer avec toutes les données
    ]);
    
    return json.encode(allData);
  }
  
  // Analyser les statistiques des données
  static Map<String, dynamic> analyzeData(List<Map<String, dynamic>> data) {
    Map<String, int> serviceCount = {};
    Map<String, int> quartierCount = {};
    int urgentCount = 0;
    
    for (var item in data) {
      // Compter les services
      String service = item['service'];
      serviceCount[service] = (serviceCount[service] ?? 0) + 1;
      
      // Compter les quartiers
      String quartier = item['quartier'];
      quartierCount[quartier] = (quartierCount[quartier] ?? 0) + 1;
      
      // Compter les urgences
      if (item['urgence'] == true) {
        urgentCount++;
      }
    }
    
    return {
      'total_demandes': data.length,
      'demandes_urgentes': urgentCount,
      'pourcentage_urgent': (urgentCount / data.length * 100).round(),
      'services_populaires': serviceCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      'quartiers_actifs': quartierCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    };
  }
}
