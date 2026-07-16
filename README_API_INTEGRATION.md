# Integration API Gemini et Groq

Ce document explique en detail comment ce projet integre `Gemini` et `Groq`, depuis le moment ou l'utilisateur appuie sur "envoyer" jusqu'au moment ou la reponse s'affiche dans l'ecran.

L'objectif est de comprendre :

- ou les cles API sont chargees
- quelle classe appelle quel service
- comment Gemini est contacte
- comment Groq est contacte
- comment ajouter plus tard un autre provider

## Vue d'ensemble

Le flux complet est celui-ci :

`ChatScreen -> ChatController -> ChatService -> AiChatClient -> GeminiChatClient ou GroqChatClient -> API distante`

En pratique :

1. l'utilisateur ecrit un message dans l'ecran
2. l'ecran appelle le controleur
3. le controleur ajoute le message utilisateur dans la liste
4. le controleur demande une reponse au service
5. le service choisit le bon client selon le provider actif
6. le client appelle l'API Gemini ou Groq
7. la reponse revient au controleur
8. le controleur ajoute la reponse dans la conversation
9. l'ecran se reconstruit avec les nouveaux messages

## Fichiers importants

- [lib/main.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/main.dart:1)
- [lib/presentation/controllers/chat_controller.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/presentation/controllers/chat_controller.dart:1)
- [lib/data/services/chat_service.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/services/chat_service.dart:1)
- [lib/domain/contracts/ai_chat_client.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/domain/contracts/ai_chat_client.dart:1)
- [lib/data/clients/gemini_chat_client.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/clients/gemini_chat_client.dart:1)
- [lib/data/clients/groq_chat_client.dart](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/clients/groq_chat_client.dart:1)

## Etape 1: chargement des cles API

Le projet charge les variables d'environnement au demarrage dans [`main.dart`](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/main.dart:1).

Le code fait ceci :

```dart
await dotenv.load(fileName: '.env');
```

Ensuite il lit les cles :

```dart
dotenv.env['GEMINI_API_KEY']
dotenv.env['API_KEY']
dotenv.env['GROQ_API_KEY']
```

### Pourquoi il y a `API_KEY` et `GEMINI_API_KEY`

Le projet accepte encore deux noms pour Gemini :

- `GEMINI_API_KEY`
- `API_KEY`

Donc si `GEMINI_API_KEY` n'existe pas, il essaye `API_KEY`.

### Exemple de `.env`

```env
GEMINI_API_KEY=ta_cle_gemini
GROQ_API_KEY=ta_cle_groq
```

## Etape 2: creation des clients

Toujours dans [`main.dart`](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/main.dart:1), l'application construit les objets techniques.

Elle cree :

- un `GeminiChatClient`
- un `GroqChatClient`
- un `ChatService`
- un `ChatController`

Exemple logique :

```dart
final controller = ChatController(
  chatService: ChatService(
    clients: [
      GeminiChatClient(apiKey: ...),
      GroqChatClient(apiKey: ...),
    ],
  ),
);
```

### Pourquoi c'est utile

`main.dart` fait l'assemblage une seule fois.

Donc :

- l'ecran ne connait pas les cles API
- l'ecran ne construit pas les clients reseau
- les appels API restent centralises

## Etape 3: le contrat commun des providers

Le fichier [`ai_chat_client.dart`](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/domain/contracts/ai_chat_client.dart:1) definit le contrat commun.

Le contrat dit simplement qu'un provider doit savoir :

- dire qui il est avec `provider`
- envoyer un message avec `sendMessage(...)`
- reinitialiser sa conversation avec `resetConversation()`

Forme simplifiee :

```dart
abstract class AiChatClient {
  AiProvider get provider;

  Future<String> sendMessage(...);
  Future<void> resetConversation();
}
```

### Pourquoi ce contrat est important

`ChatService` n'a pas besoin de connaitre les details internes de Gemini ou Groq.

Il sait juste :

- "je cherche le client du provider courant"
- "j'appelle sendMessage"

C'est le point cle du principe Open/Closed dans ce projet.

## Etape 4: selection du bon provider

[`ChatService`](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/services/chat_service.dart:1) recoit une liste de clients.

Il les stocke dans une `Map<AiProvider, AiChatClient>`.

Donc :

- `AiProvider.gemini` pointe vers `GeminiChatClient`
- `AiProvider.groq` pointe vers `GroqChatClient`

Quand le controleur demande une reponse, `ChatService` fait ceci :

1. il regarde quel provider est actif
2. il recupere le bon client
3. il appelle `sendMessage(...)`

Pseudo-code :

```dart
final client = _clients[provider];
return client.sendMessage(...);
```

## Etape 5: ce que fait le controleur

[`ChatController`](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/presentation/controllers/chat_controller.dart:1) est le chef d'orchestre de la conversation.

Quand l'utilisateur envoie un message :

1. il nettoie le texte avec `trim()`
2. il verifie que le texte n'est pas vide
3. il verifie qu'une requete n'est pas deja en cours avec `_isLoading`
4. il copie l'historique courant
5. il ajoute le message utilisateur a `_messages`
6. il appelle `chatService.getChatResponse(...)`
7. il ajoute la reponse recue a `_messages`
8. il notifie l'interface avec `notifyListeners()`

### Pourquoi il copie l'historique

Cette ligne est importante :

```dart
final history = List<ChatMessage>.from(_messages);
```

Le but est de figer l'etat des messages deja presents avant l'appel API.

Ensuite cet historique est passe au provider.

## Processus complet Gemini

### 1. Quel fichier s'en charge

[`lib/data/clients/gemini_chat_client.dart`](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/clients/gemini_chat_client.dart:1)

### 2. Quelle bibliotheque est utilisee

Le projet utilise :

```dart
package:google_generative_ai/google_generative_ai.dart
```

Donc pour Gemini, le projet passe par le SDK Dart officiel present dans les dependances du projet.

### 3. Creation du modele

`GeminiChatClient` garde en memoire :

- `apiKey`
- `modelName`
- `_model`
- `_chatSession`

Le modele par defaut dans ce projet est :

```text
gemini-1.5-flash-latest
```

Le modele est cree ici :

```dart
GenerativeModel(model: modelName, apiKey: apiKey);
```

### 4. Verification de la cle

Avant tout appel, le client verifie si la cle est vide.

Si la cle manque, il renvoie directement un message d'erreur texte a l'application.

### 5. Gestion de session

Gemini utilise une vraie session de chat locale via :

```dart
model.startChat()
```

Cette session est stockee dans :

```dart
ChatSession? _chatSession;
```

### 6. Reinitialisation

Quand on change de provider ou qu'on efface la conversation, le controleur appelle :

```dart
chatService.resetConversation(...)
```

Puis `ChatService` delegue a `GeminiChatClient.resetConversation()`.

Cette methode recree une nouvelle session :

```dart
_chatSession = _buildModel()?.startChat();
```

Donc pour Gemini, le contexte conversationnel est conserve par l'objet `ChatSession`.

### 7. Envoi du message

Quand `sendMessage(...)` est appelee :

1. le client verifie que le modele existe
2. il cree la session si elle n'existe pas encore
3. il envoie le message a Gemini
4. il lit `response.text`
5. il renvoie le texte a l'application

Le coeur de l'appel est :

```dart
final response = await _chatSession!.sendMessage(
  Content.text(userMessage),
);
```

### 8. Gestion des erreurs

Le client capture :

- `GenerativeAIException`
- toute autre exception generique

Puis il renvoie un texte exploitable par l'UI.

### Resume Gemini

Gemini dans ce projet fonctionne comme ca :

- SDK Dart
- modele instancie localement
- session de chat conservee dans `_chatSession`
- pas besoin de reconstruire tout l'historique a chaque appel dans ce code

## Processus complet Groq

### 1. Quel fichier s'en charge

[`lib/data/clients/groq_chat_client.dart`](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/data/clients/groq_chat_client.dart:1)

### 2. Quelle approche est utilisee

Ici le projet n'utilise pas de SDK Groq.

Il utilise directement :

- `HttpClient`
- `jsonEncode`
- `jsonDecode`

Donc le projet construit lui-meme la requete HTTP.

### 3. Endpoint utilise

Dans le code actuel, l'endpoint est :

```text
https://api.groq.com/openai/v1/chat/completions
```

Le modele configure dans ce projet est :

```text
llama-3.3-70b-versatile
```

### 4. Verification de la cle

Comme pour Gemini, le client commence par verifier si `apiKey` est vide.

Si oui, il retourne un message d'erreur.

### 5. Creation de la requete HTTP

Le client ouvre une requete POST :

```dart
final request = await client.postUrl(Uri.parse(_endpoint));
```

Puis il ajoute les headers :

```dart
request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
```

### 6. Construction du body JSON

Le corps de la requete contient :

- `model`
- `messages`
- `temperature`

Le code envoie quelque chose de cette forme :

```json
{
  "model": "llama-3.3-70b-versatile",
  "messages": [
    {
      "role": "system",
      "content": "Tu es un assistant conversationnel utile, clair et concis."
    },
    {
      "role": "user",
      "content": "Bonjour"
    }
  ],
  "temperature": 0.7
}
```

### 7. Comment l'historique est envoye

Groq ne garde pas ici une session locale comme Gemini.

A la place, le projet reconstruit la conversation a chaque requete.

La methode `_buildMessages(...)` :

1. ajoute un message `system`
2. ajoute tout l'historique precedent
3. ajoute le nouveau message utilisateur

Chaque `ChatMessage` est converti en :

- `user` si `isFromUser == true`
- `assistant` sinon

### 8. Envoi de la requete

Le body JSON est ecrit dans la requete puis envoye :

```dart
request.write(jsonEncode(...));
final response = await request.close();
```

Ensuite le projet lit la reponse brute :

```dart
final responseBody = await response.transform(utf8.decoder).join();
```

### 9. Lecture de la reponse

Le code decode le JSON :

```dart
final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
```

Puis il cherche le texte ici :

- `choices`
- premier element
- `message`
- `content`

C'est la logique equivalent a :

```dart
decoded['choices'][0]['message']['content']
```

si toutes les cles existent bien.

### 10. Gestion des erreurs

Si le code HTTP est `>= 400`, le projet cherche :

```dart
decoded['error']['message']
```

Sinon il renvoie un message generique avec le code HTTP.

Le client ecrit aussi des logs utiles avec :

```dart
debugPrint(...)
```

pour afficher :

- le status code
- la reponse brute
- les exceptions

### Resume Groq

Groq dans ce projet fonctionne comme ca :

- appel HTTP manuel
- endpoint compatible chat completions
- reconstruction complete de l'historique a chaque requete
- extraction manuelle de la reponse JSON

## Difference importante entre Gemini et Groq dans ce projet

### Gemini

- utilise un SDK Dart
- garde une `ChatSession`
- envoie surtout le nouveau message a la session
- la session porte deja le contexte

### Groq

- utilise un appel HTTP manuel
- ne garde pas de session technique locale ici
- reconstruit toute la liste `messages` a chaque appel
- parse le JSON a la main

## Ce qui se passe quand on change de provider

Quand l'utilisateur change de provider depuis l'interface :

1. `ChatController.changeProvider(...)` est appelee
2. `_selectedProvider` change
3. `_messages.clear()` vide l'historique affiche
4. `notifyListeners()` reconstruit l'UI
5. `chatService.resetConversation(provider)` est appelee

Effet concret :

- si on passe sur Gemini, une nouvelle `ChatSession` est preparee
- si on passe sur Groq, il n'y a pas d'etat technique a reset dans le client actuel

## Ce qui se passe quand on efface la conversation

Le flux est proche du changement de provider :

1. le controleur vide `_messages`
2. il notifie l'ecran
3. il demande au `ChatService` de reset la conversation du provider courant

## Exemple complet de processus

Supposons que l'utilisateur choisit `Groq` et envoie :

```text
Explique moi SOLID
```

Le processus est :

1. `ChatScreen` appelle `ChatController.sendMessage("Explique moi SOLID")`
2. `ChatController` ajoute ce message a la conversation
3. `ChatController` appelle `chatService.getChatResponse(...)`
4. `ChatService` voit que le provider courant est `AiProvider.groq`
5. `ChatService` choisit `GroqChatClient`
6. `GroqChatClient` construit le JSON avec l'historique
7. `GroqChatClient` envoie la requete HTTP a Groq
8. Groq renvoie un JSON
9. `GroqChatClient` extrait `content`
10. la chaine de texte remonte au controleur
11. le controleur ajoute la reponse dans `_messages`
12. l'UI s'actualise

Le meme principe existe avec Gemini, sauf que l'envoi passe par une `ChatSession`.

## Comment ajouter un nouveau provider

Le plus important est ici : [`AiChatClient`](/home/lydevtech/Projects/mobile/chat_ai_gemini/lib/domain/contracts/ai_chat_client.dart:1)

Pour ajouter par exemple `OpenAI` plus tard :

1. creer `OpenAiChatClient`
2. lui faire implementer `AiChatClient`
3. definir `provider`
4. coder `sendMessage(...)`
5. coder `resetConversation()`
6. l'ajouter dans `main.dart` dans la liste des clients

Exemple de structure :

```dart
class OpenAiChatClient implements AiChatClient {
  @override
  AiProvider get provider => AiProvider.openai;

  @override
  Future<void> resetConversation() async {}

  @override
  Future<String> sendMessage({
    required String userMessage,
    List<ChatMessage> history = const [],
  }) async {
    // appel API OpenAI
  }
}
```

Ensuite `ChatService` pourra l'utiliser sans gros changement de logique.

## Points de vigilance

- `.env` doit etre present et correctement charge
- `GEMINI_API_KEY` ou `API_KEY` doit exister pour Gemini
- `GROQ_API_KEY` doit exister pour Groq
- le modele configure doit etre accepte par le provider
- les erreurs reseau sont actuellement renvoyees comme du texte
- Groq depend de la structure JSON attendue dans `choices -> message -> content`

## Resume simple

Si tu veux retenir l'essentiel :

- `main.dart` charge les cles et branche les clients
- `ChatController` pilote la conversation
- `ChatService` choisit le bon provider
- `AiChatClient` est le contrat commun
- `GeminiChatClient` parle a Gemini via le SDK
- `GroqChatClient` parle a Groq via HTTP + JSON

## Ameliorations possibles plus tard

- typer les erreurs au lieu de renvoyer des `String`
- ajouter du streaming de reponse
- factoriser une partie de la gestion des erreurs reseau
- ajouter des tests unitaires specifiques a `GeminiChatClient` et `GroqChatClient`
- documenter aussi les formats de reponse attendus dans des tests
