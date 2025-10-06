# Toker — Repenser la rencontre à travers vos centres d’intérêt

> **Projet de fin d’étude - PFE — Majeures CReATE / Data / Cyber**
>
> Une nouvelle génération d’application de rencontre, qui mise sur vos centres d’intérêt plutôt que sur le simple « swipe ».

---

## Contexte

Les applications de rencontre actuelles séduisent des millions d’utilisateurs, mais beaucoup se disent insatisfaits.  
Les profils proposés reflètent rarement la personnalité ou les centres d’intérêt réels, et les algorithmes privilégient trop souvent l’apparence ou la popularité (classement Elo).

**Connectly** part d’un constat simple : les réseaux sociaux, eux, regorgent d’informations sur nos goûts, nos passions et nos valeurs — autant d’éléments essentiels dans la création de liens authentiques.  
L’idée est donc de **repenser la rencontre** en utilisant les **likes, abonnements et contenus appréciés** sur des plateformes comme **TikTok** ou **Instagram** pour suggérer des personnes réellement compatibles.

---

## Objectifs SMART

| Objectif | Spécifique | Mesurable | Approprié | Réaliste | Temporel |
|-----------|-------------|------------|-------------|-----------|------------|
| **Prototype fonctionnel** | Développer une application de rencontre basée sur les centres d’intérêt extraits d’un réseau social | Permettre à un utilisateur de créer un profil et d’obtenir 5 suggestions pertinentes | Aligné avec les compétences Data & Cyber | MVP réalisable sans accès complet à l’API TikTok | Mai 2025 |
| **Validation utilisateur** | Tester la pertinence des suggestions auprès d’un panel d’utilisateurs | 20 retours, 60 % de satisfaction minimum | Confirme la pertinence du concept | Tests réalisables en interne | Mars–Avril 2025 |
| **Cadre légal & API** | Identifier les contraintes RGPD et techniques liées aux données sociales | Rapport de 5 pages documenté | Essentiel pour la conformité du projet | Recherche faisable avec encadrement académique | Février 2025 |
| **Livrables académiques** | Rédiger le dossier final et présenter le projet | Rapport complet (≥30 pages) + soutenance | Cohérent avec les attentes du PFE | Réalisable en équipe | Juin 2025 |

---

## Fonctionnement du concept

1. **Collecte des données d’intérêt**  
   - Récupération (ou simulation) des données de likes / catégories / hashtags depuis TikTok ou Instagram.
   - Anonymisation et respect du RGPD.

2. **Algorithme de matching hybride**  
   - Combinaison d’un score de similarité basé sur les centres d’intérêt et d’un score Elo de popularité.
   - Pondération ajustable selon les préférences de l’utilisateur.

3. **Interface utilisateur (prototype)**  
   - Interface simple, mobile-first.  
   - Suggestions de profils + indicateur d’affinité.  
   - Fonctionnalité de “match” et de messagerie basique (en version démo).

---

## Stack technique (prévisionnelle)

| Domaine | Technologies envisagées |
|----------|--------------------------|
| **Backend** | Python (FastAPI ou Flask), API REST, SQLite/PostgreSQL |
| **Frontend** | React / Next.js, TailwindCSS |
| **Data / IA** | Python (scikit-learn, pandas, spaCy), modèles de similarité |
| **Sécurité** | Hashage (bcrypt), anonymisation, conformité RGPD |
| **Tests / Déploiement** | Docker, GitHub Actions |

---

## Cadre éthique et légal

- Aucune donnée réelle d’utilisateur ne sera collectée sans consentement explicite.  
- Les données TikTok ou Instagram seront **simulées** si l’accès à l’API officielle (Research API) n’est pas validé.  
- Le projet s’inscrit dans une **démarche académique**, sans but lucratif.  
- Le respect du **RGPD** et des recommandations de la **CNIL** est garanti.

---

## Planning prévisionnel

| Phase | Description | Échéance |
|-------|--------------|-----------|
| **Janvier–Février 2025** | Recherche documentaire + cadrage API / RGPD | 28 février |
| **Mars 2025** | Développement du prototype | 31 mars |
| **Avril 2025** | Tests utilisateurs + itérations | 30 avril |
| **Mai 2025** | Finalisation et corrections | 31 mai |
| **Juin 2025** | Soutenance et rendu du rapport final | Juin |

---

## Équipe projet

- Victor LAMBERT : Internet des Objets (CReAT) victor.lambert@edu.ece.fr
- Karl LAVOCAT : Internet des Objets (CReAT) karl.lavocat@edu.ece.fr
- Alexis RAYNAL : Cybersécurité alexis.raynal@edu.ece.fr
- Quentin RICHARD : Data & IA quentin.richard@edu.ece.fr
- SABBAGH Anthony : Data & IA anthony.sabbagh@edu.ece.fr
- Mathis GRAS : Cybersécurité mathis.gras@edu.ece.fr

---

## Lancer le projet (MVP)

```bash
# 1. Cloner le dépôt
git clone https://github.com/[votre-utilisateur]/connectly.git

# 2. Installer les dépendances
cd connectly
pip install -r requirements.txt

# 3. Lancer le backend
uvicorn app.main:app --reload

# 4. Lancer le frontend (si applicable)
npm install
npm run dev
```


