# Toker Backend Documentation

---


This document provides an overview of the backend architecture and components of the Toker application. The backend is responsible for handling social media Data, Data vectorisation and storage, as well as providing APIs for the frontend to interact with.

---

Faites pas gaffe après ça j'ai lacché l'anglais j'ai eu que 800 au TOEIC..Bref 

Comme on a convenus pour le moemtn on ne fait que mock les données des API, les fichiers python existent bie mais ils ne sont pas fonctionnels, ils renvoient seulement des fausses données mais correctement formatées.

API_geter.py : récupère les données des API (mockées pour le moment)
Insta_API.py, TikTok_API.py, X_API.py : contiennent les fonctions de récupération des données (mockées)

Formats des données récupérées (exemples qui sont en théories des JSONs) :
```json
{
  "user_id": "123456",
  "username": "example_user",
  "user_pseudo": "example_pseudo",
  "verified": false,
  "followers_count": 1500,
  "following_count": 300,
  "likes_count": 5000,
  "videos_count": 100,
  "number_of_comments": 200,
  "number_of_likes_on_own_videos": 4500,
  "number_of_likes": 6000,
  "number_of_shares": 800,
    "liked_videos": [
    {
      "video_id": "967235098701",
      "categories": ["Technology", "Education"],
      "likes": 300,
      "comments": 20,
      "shares": 15
    },
    {
      "video_id": "967235098702",
      "hashtags": ["#fun", "#entertainment"],
      "likes": 500,
      "comments": 50,
      "shares": 30
    }
    ],
    "shared_videos": [
    {
      "video_id": "967235098703",
      "categories": ["Music", "Dance"],
      "likes": 400,
      "comments": 25,
      "shares": 20
    }
    {
      "video_id": "9672350798703",
      "categories": ["Music", "Dance"],
      "likes": 400,
      "comments": 25,
      "shares": 20
    }
    ]
}

On devra avoir 100 likes minimum pour que le profil soit validé et intégré dans la base de données.

User_creation.py : crée un utilisateur, c'est kes ends poionts qu'on utilisera plus tard c'est ici que l'appel API sera fait en utilisant API_geter.py:
User se connecte avec son compte TikTok/Instagram -> on récupère les données via l'API (mockée) - > on crée le profil dans la base de données
Data_processing.py : traite les données récupérées (nettoyage, vectorisation, etc.)
Database.py : gère la connexion à la base de données et les opérations CRUD, une fois le sdonnées process on les intègre dans la base de données
API_server.py : Django qui expose les endpoints pour le frontend

---

Pour la partie backend on va utulsier un environnement virtuel python, cet environnement v est poetry, rtfm
Voici comment lancer le back pour le moment (en local) :
```bash
cd backend
poetry install
poetry shell
```

---

.
├── README-en.md
├── README-fr.md
├── backend
│   ├── README-backend.md
│   ├── cli.py
│   ├── core
│   │   ├── API_geter.py
│   │   ├── Data_processing.py
│   │   ├── Database.py
│   │   ├── Insta_API.py
│   │   ├── TikTok_API.py
│   │   ├── User_creation.py
│   │   ├── X_API.py
│   │   └── __pycache__
│   │       ├── API_geter.cpython-312.pyc
│   │       ├── Database.cpython-312.pyc
│   │       └── TikTok_API.cpython-312.pyc
│   ├── db
│   ├── poetry.lock
│   ├── pyproject.toml
│   └── toker.db
├── documentation
└── frontend
    └── README-frontend


---

Commentaires en francais seront à chyanger en en