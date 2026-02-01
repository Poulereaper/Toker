# Guide d'Intégration Frontend-Backend (Data Team)

Ce document décrit l'état actuel du frontend de l'application **Toker**, les modèles de données utilisés, et les spécifications pour l'intégration de la future Base de Données (BDD) et API.

## 🚀 État Actuel

Actuellement, l'application fonctionne avec :
1.  **Données Simulées (MockDataService)** : Les profils, matchs et messages sont générés localement ou stockés temporairement en RAM.
2.  **Authentification Simulée (AuthService)** : L'authentification TikTok est simulée. En mode démo, nous utilisons un stockage en mémoire vive pour garantir la fluidité.
3.  **Persistance Temporaire** : Les données de profil (créées lors de l'onboarding) sont stockées en mémoire tant que l'application est active.

---

## 🔐 Authentification & Onboarding

### Flux Actuel
1.  L'utilisateur clique sur "Se connecter avec TikTok".
2.  L'app reçoit un `auth_code`.
3.  L'app appelle `AuthService.simulateTikTokAuth(code)`.
4.  Si c'est un nouvel utilisateur -> **Onboarding** (Nom, Age, Photos, Prompts).
5.  Si c'est un utilisateur existant -> **Accueil**.

### Besoins Backend
L'équipe Data devra implémenter les endpoints suivants pour remplacer la simulation :

-   `POST /auth/tiktok` : Échange le code auth TikTok contre un token de session (JWT).
    -   *Input* : `{ "code": "..." }`
    -   *Output* : `{ "token": "...", "isNewUser": true/false, "userId": "..." }`

---

## 💾 Modèles de Données

Voici les structures de données (JSON) attendues par le frontend. La BDD doit pouvoir mapper ces structures.

### 1. User Profile (`Profile`)
C'est l'objet central. Il contient les infos de base, les photos et les réponses aux prompts.

```json
{
  "id": "uuid-v4",
  "name": "Zoé",
  "age": 24,
  "birthdate": "2000-01-01T00:00:00.000Z", // Optionnel
  "gender": "Female", // "Male", "Female", "Non-binary"
  "bio": "Passionnée de voyages...",
  "location": "Paris, France",
  "interestedIn": "Everyone", // "Men", "Women", "Everyone"
  
  // Listes simples
  "interests": ["Voyage", "Sushi", "Cinéma"],
  "photos": [
    "https://storage.toker.com/users/123/photo_1.jpg",
    "https://storage.toker.com/users/123/photo_2.jpg"
  ],

  // Prompts (Questions/Réponses)
  "prompts": [
    {
      "question": "Mon talent caché...",
      "answer": "Je sais jongler",
      "category": "aboutMe"
    }
  ],

  // Légendes photos (Index photo -> Légende)
  "photoCaptions": {
    "0": "Vacances à Bali",
    "2": "Mon chat"
  },

  // Vecteur d'intérêts pour l'algo de matching (Optionnel pour le MVP)
  "interestVector": {
    "travel": 0.8,
    "food": 0.5
  }
}
```

### 2. Match (`Match`)
Représente une connexion entre deux utilisateurs.

```json
{
  "id": "match-uuid",
  "profile": { ... }, // Objet Profile de l'autre personne (simplifié si besoin)
  "matchedAt": "2024-01-31T12:00:00.000Z",
  "compatibilityScore": 85.5, // Score calculé par l'algo
  "lastMessage": "Salut ça va ?",
  "lastMessageTime": "2024-01-31T14:30:00.000Z",
  "isUnread": true
}
```

### 3. Message (`Message`)
Un message dans un chat.

```json
{
  "id": "msg-uuid",
  "senderId": "user-1",
  "receiverId": "user-2",
  "content": "Hello !",
  "timestamp": "2024-01-31T14:30:00.000Z",
  "isRead": false
}
```

---

## 📚 Données de Référence (Static Data)

Pour que l'onboarding fonctionne, la BDD doit être peuplée avec ces listes de référence.

### 📌 Liste des Centres d'Intérêt (Interests)
Ces tags sont utilisés pour le matching. Il faudra stocker cette liste en BDD et exposer un endpoint `GET /interests` pour les récupérer.

**Sports & Fitness:**
`Gaming`, `Sport`, `Fitness`, `Yoga`, `Randonnée`, `Course à pied`, `Vélo`, `Natation`, `Basketball`, `Football`, `Tennis`, `Golf`, `Ski`, `Snowboard`, `Surf`, `Escalade`, `Boxe`, `Danse`, `Pilates`, `Crossfit`

**Arts & Culture:**
`Art`, `Photographie`, `Musique`, `Cinéma`, `Concerts`, `Théâtre`, `Musées`, `Lecture`, `Écriture`, `Poésie`, `Peinture`, `Dessin`, `Sculpture`, `Films`, `Anime`, `Manga`, `BD`, `Graffiti`, `Design`, `Architecture`

**Food & Drinks:**
`Cuisine`, `Pâtisserie`, `Café`, `Vin`, `Cocktails`, `Bière`, `Thé`, `Restaurants`, `Street Food`, `Vegan`, `Végétarien`, `Gâteaux`, `BBQ`, `Sushi`

**Tech & Innovation:**
`Tech`, `Programmation`, `IA`, `Crypto`, `Startups`, `Innovation`, `Gaming PC`, `VR`, `Robotique`, `Science`, `Espace`, `Astronomie`

**Travel & Adventure:**
`Voyage`, `Backpacking`, `Road Trips`, `Camping`, `Aventure`, `Exploration`, `Plage`, `Montagne`, `City Breaks`, 'Festivals`

**Lifestyle & Hobbies:**
`Mode`, `Shopping`, `Maquillage`, `Skincare`, `Tattoos`, `Piercings`, `Vintage`, `Friperie`, `DIY`, `Jardinage`, `Décoration`, `Animaux`, `Chiens`, `Chats`

**Entertainment:**
`Netflix`, `Séries`, `Télé-réalité`, `Podcasts`, `Stand-up`, `Karaoké`, `Jeux de société`, `Escape Game`, `Bowling`, `Billard`, `Karting`, `Laser Game`

**Music Genres:**
`Rock`, `Pop`, `Hip-Hop`, `Rap`, `Jazz`, `Blues`, `Électro`, `House`, `Techno`, `R&B`, `Soul`, `Reggae`, 'Metal`, `Indie`, `Folk`, `Classique`

**Misc:**
`Méditation`, `Spiritualité`, `Astrologie`, `Psychologie`, `Philosophie`, `Histoire`, `Politique`, `Activisme`, `Bénévolat`, `Développement durable`, `Écologie`

---

### 💬 Liste des Prompts (Accroches)
Ces questions servent à briser la glace. À stocker et exposer via `GET /prompts`.

**Catégorie: À propos de moi**
- `Dans mon groupe d'amis je suis...`
- `Le truc le plus random que j'adore...`
- `Mon talent caché c'est...`
- `Un truc sur moi que personne ne devine...`
- `Ce qui me rend unique...`

**Catégorie: Mon type**
- `On s'entendra si...`
- `Ce que je cherche chez quelqu'un...`
- `Le meilleur premier date serait...`
- `Je suis attiré(e) par...`

**Catégorie: Ton univers**
- `Ma passion secrète c'est...`
- `Mon endroit préféré au monde...`
- `Je ne peux pas vivre sans...`
- `Ma définition d'une bonne soirée...`

**Catégorie: Self-care**
- `Pour me détendre je...`
- `Mon rituel du matin c'est...`
- `Ce qui me fait du bien...`

**Catégorie: Plus personnel**
- `Ma plus grande fierté...`
- `Le meilleur conseil qu'on m'ait donné...`
- `Si je pouvais dîner avec quelqu'un...`
- `Ce qui me fait rire à coup sûr...`

**Catégorie: Légendes photo (Photo Captions)**
*(Ces textes sont suggérés comme légendes lors de l'upload de photo)*
- `Quand je me la joue sérieux`
- `Mode vacances activé`
- `Dimanche typique`
- `Ma passion en image`
- `Avec mes gens préférés`
- `Moment de fierté`
- `Juste moi étant moi`
- `Aventure du jour`
- `Mon endroit favori`
- `Vibes du moment`
- `En mode détente`
- `Souvenir inoubliable`

---

## 🛠️ Endpoints API Requis (Proposition)

L'application aura besoin de consommer ces APIs. Le format de réponse doit correspondre aux modèles JSON ci-dessus.

### Authentification
- `POST /auth/login` (ou `/auth/tiktok`)

### Profils
- `GET /me` : Récupère le profil de l'utilisateur connecté.
- `PUT /me` : Met à jour le profil (utilisé à la fin de l'onboarding).
- `GET /users/:id` : Récupère un profil spécifique.

### Feed (Algorithme)
- `GET /feed/discover` : Retourne une liste de profils compatibles pour le swipe.
- `GET /feed/standouts` : Retourne les profils "Coups de cœur" (haute compatibilité).

### Actions
- `POST /swipes` : Enregistre un Like/Dislike.
    - *Input* : `{ "targetUserId": "...", "action": "like" | "pass" }`
    - *Output* : `{ "isMatch": true/false }`

### Chat
- `GET /matches` : Liste tous les matchs.
- `GET /matches/:id/messages` : Historique de conversation.
- `POST /matches/:id/messages` : Envoyer un message (ou via WebSocket).

---

## 🔄 Comment Intégrer la BDD ?

Pour connecter la vraie BDD sans casser l'existant, l'équipe Data devra :

1.  **Créer une classe `ApiService`** : Celle-ci remplacera `MockDataService`.
2.  **Implémenter les interfaces** :
    *   Dans `profile_service.dart`, remplacer les appels à `_mockData` par des appels HTTP vers l'API.
    *   Faire de même pour `match_service.dart`.
3.  **Gérer le Token** : Stocker le JWT reçu au login (via `flutter_secure_storage` ou `SharedPreferences`) et l'ajouter dans les headers de chaque requête (`Authorization: Bearer ...`).

**Note Importante sur l'Onboarding :**
Actuellement, l'onboarding construit un objet `Profile` étape par étape en mémoire. À la toute fin (dernier écran), l'app appelle `profileService.updateProfile(profile)`. C'est à ce moment précis qu'il faudra faire le `PUT /me` vers la BDD pour sauvegarder toutes les infos d'un coup.

---

## 📸 Gestion des Médias (Upload)

L'application doit pouvoir uploader des images (photos de profil).

### Endpoint Requis
- `POST /media/upload`
    - **Type** : `multipart/form-data`
    - **Fichier** : champ `file` (image jpg/png)
    - **Réponse** :
      ```json
      {
        "url": "https://cdn.toker.app/uploads/user_123/image_abc.jpg",
        "fileId": "image_abc"
      }
      ```

### Stratégie Recommandée
1.  Le frontend envoie le fichier binaire.
2.  Le backend stocke le fichier sur Amazon S3 / Google Cloud Storage / Azure Blob.
3.  Le backend retourne l'URL publique (CDN) de l'image.
4.  Le frontend ajoute cette URL dans la liste `photos` du profil.

---

## ⚙️ Standards Techniques

### Pagination
Les endpoints qui retournent des listes (ex: `/feed/discover`) doivent supporter la pagination pour ne pas surcharger le mobile.
-   **Paramètres** : `?limit=20&offset=0` (ou curseur `?cursor=xyz`).
-   **Réponse** :
    ```json
    {
      "data": [...],
      "nextCursor": "xyz",
      "hasMore": true
    }
    ```

### Gestion des Erreurs
Le backend doit retourner les codes HTTP standards :
-   **200 OK** : Succès.
-   **400 Bad Request** : Données invalides (ex: JSON malformé).
-   **401 Unauthorized** : Token manquant ou invalide (l'app déconnectera l'utilisateur).
-   **403 Forbidden** : Accès interdit à cette ressource.
-   **404 Not Found** : Ressource introuvable.
-   **500 Internal Server Error** : Crash serveur (ne doit pas arriver !).

### Configuration
Le frontend aura besoin d'une variable d'environnement pour pointer vers l'API :
`API_BASE_URL=https://api.toker.app/v1`
