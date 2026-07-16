# chat_ai_gemini

Application Flutter de chat multi-IA avec support de `Gemini` et `Groq`.

Le projet a été refactoré pour réduire le couplage entre l'interface, la logique métier et les intégrations externes. L'objectif est d'avoir une base plus propre, plus testable et plus facile à faire évoluer.

## Fonctionnalités

- conversation avec `Gemini` ou `Groq` depuis un seul écran
- changement de fournisseur à chaud via la barre d'action
- réinitialisation de la conversation en un clic
- chargement des clés API depuis un fichier `.env`
- architecture découpée en couches avec responsabilités séparées

## Stack technique

- `Flutter`
- `Dart`
- `google_generative_ai` pour Gemini
- `flutter_dotenv` pour les variables d'environnement
- `dart:io` pour l'appel HTTP vers Groq

## Prérequis

- `Flutter` installé et configuré
- un émulateur ou un appareil physique
- une clé API Gemini pour utiliser Gemini
- une clé API Groq pour utiliser Groq

Vérification rapide :

```bash
flutter --version
```

## Installation

```bash
git clone <url-du-repo>
cd chat_ai_gemini
flutter pub get
```

## Configuration

Crée ou complète le fichier `.env` à la racine du projet.

Exemple :

```env
GEMINI_API_KEY=your_gemini_api_key
GROQ_API_KEY=your_groq_api_key
```

Alias encore accepté pour Gemini :

```env
API_KEY=your_gemini_api_key
```

Un exemple est disponible ici :

- [.env.example](/home/lydevtech/Projects/mobile/chat_ai_gemini/.env.example:1)

Notes :

- le fichier `.env` est chargé au démarrage par l'application
- le fichier `.env` est déclaré dans les assets Flutter
- ne versionne pas tes vraies clés API

## Lancement

```bash
flutter run
```

Si `pubspec.yaml` change :

```bash
flutter pub get
```

## Utilisation

1. Lance l'application.
2. Choisis `Gemini` ou `Groq` dans la liste en haut.
3. Saisis un message.
4. Appuie sur l'icône d'envoi.
5. Utilise l'icône corbeille pour effacer la conversation courante.

Comportement actuel :

- le changement de fournisseur vide la conversation affichée
- Gemini conserve une session de chat interne tant que ce fournisseur reste actif
- Groq reconstruit le contexte à partir de l'historique affiché

## Architecture

L'architecture a ete simplifiee pour rester facile a comprendre tout en gardant un minimum de decouplage.

Flux principal :

`ChatScreen -> ChatController -> ChatService -> AiChatClient -> Gemini/Groq`

### Présentation

- [lib/presentation/screens/chat_screen.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/presentation/screens/chat_screen.dart:1) : écran Flutter et rendu UI
- [lib/presentation/controllers/chat_controller.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/presentation/controllers/chat_controller.dart:1) : état de la conversation et orchestration côté présentation

### Contrat

- [lib/domain/contracts/ai_chat_client.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/domain/contracts/ai_chat_client.dart:1) : contrat simple pour ajouter un nouveau fournisseur sans modifier le reste de l'application

### Data

- [lib/data/services/chat_service.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/services/chat_service.dart:1) : selectionne le bon fournisseur a partir du contrat `AiChatClient`
- [lib/data/clients/gemini_chat_client.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/clients/gemini_chat_client.dart:1) : implémentation Gemini
- [lib/data/clients/groq_chat_client.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/clients/groq_chat_client.dart:1) : implémentation Groq

### Noyau et modèles

- [lib/core/ai_provider.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/core/ai_provider.dart:1) : enum des fournisseurs et labels
- [lib/models/chat_message.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/models/chat_message.dart:1) : modèle de message
- [lib/main.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/main.dart:1) : bootstrap et injection des dépendances

## Principes appliqués

- `Single Responsibility` : chaque couche a un rôle clair
- `Open/Closed` : un nouveau fournisseur peut etre ajoute en implementant `AiChatClient`
- couplage réduit entre UI et code réseau
- testabilité améliorée grace au contrat du provider

## Tests et qualité

Commandes utiles :

```bash
dart format lib test
flutter analyze
flutter test
```

Le test principal actuel vérifie l'envoi et l'affichage d'une réponse simulée :

- [test/widget_test.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/test/widget_test.dart:1)

## Limitations actuelles

- l'historique n'est pas persisté localement
- aucun streaming de réponse n'est encore implémenté
- `flutter_tts` est présent dans les dépendances mais n'est pas utilisé
- la gestion des erreurs reste textuelle, sans typage métier dédié

## Pistes d'amélioration

- ajouter une vraie injection de dépendances centralisée
- introduire des objets d'erreur métier plutôt que des chaînes
- permettre la sélection dynamique des modèles
- persister l'historique localement
- ajouter des tests unitaires sur le contrôleur et les clients
- améliorer le thème et les composants UI

## Sécurité

- ne versionne jamais ton vrai fichier `.env`
- régénère toute clé exposée publiquement
- limite les permissions et quotas côté fournisseurs si possible

## Licence

Aucune licence n'est définie pour le moment.
