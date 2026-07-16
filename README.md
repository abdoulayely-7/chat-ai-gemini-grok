# chat_ai_gemini

Application Flutter de conversation avec plusieurs fournisseurs d'IA.  
Le projet permet actuellement de discuter avec `Gemini` et `Groq` depuis une seule interface mobile.

## Aperçu

Cette application propose :

- une interface de chat simple en Flutter
- un changement rapide de fournisseur IA depuis la barre du haut
- la conservation de l'historique de la conversation pendant la session
- la suppression de l'historique avec un bouton dédié
- le chargement sécurisé des clés API via un fichier `.env`
- des logs de diagnostic pour faciliter le débogage de l'intégration Groq

## Technologies utilisées

- `Flutter`
- `Dart`
- `google_generative_ai` pour Gemini
- `flutter_dotenv` pour charger les variables d'environnement
- `dart:io` pour les appels HTTP vers l'API Groq

## Fournisseurs pris en charge

### Gemini

L'application utilise le SDK `google_generative_ai` avec le modèle :

- `gemini-1.5-flash-latest`

### Groq

L'application utilise l'endpoint compatible OpenAI de Groq :

- `https://api.groq.com/openai/v1/chat/completions`

avec le modèle :

- `llama-3.3-70b-versatile`

## Prérequis

Avant de lancer le projet, assure-toi d'avoir :

- `Flutter` installé et configuré
- un appareil Android, iOS, ou un émulateur
- une clé API Gemini si tu veux utiliser Gemini
- une clé API Groq si tu veux utiliser Groq

Vérification rapide :

```bash
flutter --version
```

## Installation

1. Clone le projet.
2. Place-toi dans le dossier du projet.
3. Installe les dépendances Flutter.

```bash
git clone <url-du-repo>
cd chat_ai_gemini
flutter pub get
```

## Configuration

Crée un fichier `.env` à la racine du projet.

Exemple :

```env
GEMINI_API_KEY=your_gemini_api_key
GROQ_API_KEY=your_groq_api_key
```

Un fichier d'exemple est déjà fourni :

- [.env.example](/home/lydevtech/Projects/mobile/chat_ai_gemini/.env.example:1)

### Compatibilité existante

Le projet accepte encore :

```env
API_KEY=your_gemini_api_key
```

comme alias de `GEMINI_API_KEY`.

### Important

- Le fichier `.env` est embarqué comme asset Flutter pour être lisible dans l'application.
- Le fichier `.env` est ignoré par Git, donc tes secrets locaux ne sont pas versionnés.
- Évite d'écrire ou de partager tes clés API dans le code source.

## Lancement

### En mode développement

```bash
flutter run
```

### Si tu modifies `pubspec.yaml`

Relance :

```bash
flutter pub get
```

avant `flutter run`.

## Utilisation

1. Lance l'application.
2. Choisis `Gemini` ou `Groq` dans la liste déroulante en haut.
3. Saisis ton message.
4. Appuie sur l'icône d'envoi.
5. Utilise l'icône corbeille pour réinitialiser la conversation.

### Comportement actuel

- Changer de fournisseur vide l'historique affiché.
- Gemini garde une session de chat interne tant que tu restes sur ce fournisseur.
- Groq reconstruit le contexte à partir des messages déjà présents dans l'écran.

## Débogage

L'application affiche des logs utiles au démarrage et pendant les appels Groq.

### Vérifier que la clé Groq est chargée

Au lancement, la console peut afficher :

- `GROQ_API_KEY chargee: ...`
- `GROQ_API_KEY non chargee.`

Si la clé n'est pas chargée :

- vérifie que le fichier `.env` existe à la racine
- vérifie que `GROQ_API_KEY` est bien renseignée
- vérifie qu'il n'y a pas d'espace avant ou après la clé

### Vérifier la réponse Groq

Pendant une requête Groq, la console affiche :

- le code HTTP
- la réponse brute de l'API
- l'exception éventuelle

Exemples fréquents :

- `401` : clé API invalide
- `400` : requête invalide ou payload incorrect
- `404` : modèle ou endpoint incorrect

## Structure du projet

Les fichiers principaux sont :

- [lib/main.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/main.dart:1) : point d'entrée et chargement du `.env`
- [lib/Screens/chat_screen.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/Screens/chat_screen.dart:1) : interface de chat
- [lib/Services/api_service.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/Services/api_service.dart:1) : intégration Gemini et Groq
- [lib/Models/Message.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/Models/Message.dart:1) : modèle de message

## Dépendances principales

Extrait de [pubspec.yaml](/home/lydevtech/Projects/mobile/chat_ai_gemini/pubspec.yaml:1) :

- `google_generative_ai`
- `flutter_dotenv`
- `flutter_tts`

## Limitations actuelles

- le nom du projet mentionne encore `gemini` alors que l'application gère aussi `Groq`
- `flutter_tts` est présent dans les dépendances mais n'est pas activement utilisé dans l'écran de chat
- le fichier `lib/Models/Message.dart` ne suit pas encore la convention `lower_case_with_underscores`
- le modèle Groq configuré est un modèle payant côté API

## Améliorations possibles

- renommer le projet pour refléter le support multi-IA
- ajouter un écran de paramètres
- permettre de choisir le modèle Groq et le modèle Gemini dynamiquement
- ajouter le streaming des réponses
- activer la synthèse vocale
- sauvegarder l'historique localement
- améliorer l'UI du chat

## Commandes utiles

```bash
flutter pub get
flutter run
dart analyze
dart format lib
```

## Sécurité

- Ne versionne jamais ton vrai fichier `.env`.
- Si une clé a déjà été partagée publiquement, régénère-la depuis ton fournisseur.
- Préfère des variables d'environnement locales pour tous les secrets.

## Licence

Aucune licence n'est définie pour le moment.
