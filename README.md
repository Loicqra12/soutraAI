# 🚀 Soutra AI - Assistant IA pour Services en Afrique

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![AI](https://img.shields.io/badge/Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white)

**Soutra AI** est une application Flutter révolutionnaire qui connecte intelligemment les clients et les prestataires de services en Afrique grâce à l'intelligence artificielle.

## ✨ Fonctionnalités Principales

### 🤖 Assistant IA Intelligent
- **Chat conversationnel** avec Gemini AI
- **Support multilingue** (Français, Nouchi ivoirien)
- **Conseils personnalisés** pour choisir le bon prestataire
- **Estimation de prix** automatique
- **Assistant vocal** (mobile/desktop)

### 🎯 Système de Matching Avancé
- **Algorithme de scoring** multi-critères
- **150+ demandes** de matching intégrées
- **Analyse des tendances** et prédictions IA
- **Géolocalisation** par quartiers d'Abidjan
- **Matching en temps réel**

### 🌍 Spécialisé pour l'Afrique
- **Services locaux** : Coiffure, Plomberie, Électricité, Mécanique, etc.
- **Quartiers d'Abidjan** : Cocody, Plateau, Yopougon, Marcory, etc.
- **Monnaie locale** : Franc CFA (FCFA)
- **Culture locale** : Traduction Nouchi, négociation respectueuse

## 🛠️ Technologies Utilisées

- **Flutter 3.5+** - Framework UI multiplateforme
- **Dart** - Langage de programmation
- **Gemini AI** - Intelligence artificielle conversationnelle
- **Speech-to-Text** - Reconnaissance vocale
- **Flutter TTS** - Synthèse vocale
- **Google Maps** - Géolocalisation et cartes
- **JSON** - Stockage de données local

## 🚀 Installation et Configuration

### Prérequis
- Flutter SDK 3.5+
- Dart SDK 3.0+
- Clé API Gemini AI
- Clé API Google Maps (optionnel)

### Installation

1. **Cloner le projet**
```bash
git clone https://github.com/Loicqra12/soutraAI.git
cd soutraAI
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer les clés API**

Créer un fichier `.env` à la racine du projet :
```env
GEMINI_API_KEY=votre_cle_gemini_ici
GOOGLE_MAPS_API_KEY=votre_cle_google_maps_ici
```

Ou modifier directement dans `lib/services/gemini_service.dart` :
```dart
static const String _apiKey = 'VOTRE_CLE_GEMINI_ICI';
```

4. **Lancer l'application**
```bash
# Web
flutter run -d chrome

# Mobile
flutter run

# Desktop
flutter run -d windows
```

## 📱 Plateformes Supportées

| Plateforme | Chat IA | Assistant Vocal | Matching | Status |
|------------|---------|-----------------|----------|--------|
| 🌐 Web | ✅ | ❌ | ✅ | Stable |
| 📱 Android | ✅ | ✅ | ✅ | Stable |
| 🍎 iOS | ✅ | ✅ | ✅ | Stable |
| 🖥️ Desktop | ✅ | ✅ | ✅ | Stable |

*Note : L'assistant vocal n'est pas disponible sur Flutter Web (limitation technique)*

## 🎯 Utilisation

### Pour les Clients
1. **Sélectionner** "Je cherche un prestataire"
2. **Décrire** votre besoin (texte ou vocal)
3. **Recevoir** des suggestions IA personnalisées
4. **Contacter** le prestataire recommandé

### Pour les Prestataires
1. **Sélectionner** "Je suis un prestataire"
2. **Accéder** au dashboard prestataire
3. **Consulter** les statistiques IA
4. **Gérer** votre profil et services

## 📊 Dataset Intégré

- **150 demandes** de matching réelles
- **5 prestataires** d'exemple
- **15 quartiers** d'Abidjan
- **20+ services** disponibles
- **Données multilingues** (Français/Nouchi)

## 🤝 Contribution

Les contributions sont les bienvenues ! Voici comment contribuer :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Auteur

**Loic Kouakou** - [@Loicqra12](https://github.com/Loicqra12)

## 🙏 Remerciements

- **Google Gemini AI** pour l'intelligence artificielle
- **Flutter Team** pour le framework exceptionnel
- **Communauté ivoirienne** pour les retours et suggestions

---

⭐ **N'hésitez pas à donner une étoile si ce projet vous plaît !** ⭐
