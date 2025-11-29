# Data-processing.py file will contain functions to process data obtained from APIs# backend/core/Data_processing.py
import numpy as np
from typing import Dict, List, Any
from .TikTok_API import CATEGORIES  # On réutilise les catégories définies dans ton mock

class DataProcessor:
    """
    Classe responsable de la transformation des données brutes des réseaux sociaux
    en vecteurs mathématiques exploitables pour le matching.
    """

    def __init__(self):
        # On s'assure que l'ordre des catégories est toujours le même pour le vecteur
        self.reference_categories = sorted(CATEGORIES)
        self.category_map = {cat: i for i, cat in enumerate(self.reference_categories)}

    def process_user_data(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Traite les données brutes d'un utilisateur pour générer son vecteur de profil.
        
        Args:
            user_data: Le JSON brut récupéré via l'API (APIGetter)
            
        Returns:
            Un dictionnaire contenant le vecteur et les métadonnées enrichies
        """
        liked_videos = user_data.get('liked_videos', [])
        
        # 1. Vectorisation des Centres d'intérêt (Catégories)
        interest_vector = self._compute_interest_vector(liked_videos)
        
        # 2. Analyse comportementale (Stats normalisées)
        behavior_stats = self._compute_behavior_stats(user_data)
        
        # 3. Création du vecteur global (concaténation)
        # On peut choisir de stocker les vecteurs séparément ou ensemble.
        # Pour l'instant, stockons le vecteur d'intérêt principal.
        
        processed_data = {
            "interest_vector": interest_vector.tolist(),  # Convertir en liste pour stockage JSON/DB
            "top_interests": self._get_top_interests(interest_vector),
            "behavior_stats": behavior_stats,
            "raw_data_summary": {
                "total_liked": len(liked_videos),
                "account_age_proxy": user_data.get("videos_count", 0) # Exemple
            }
        }
        
        return processed_data

    def _compute_interest_vector(self, videos: List[Dict]) -> np.ndarray:
        """Crée un vecteur normalisé basé sur les catégories des vidéos likées."""
        vector = np.zeros(len(self.reference_categories))
        
        if not videos:
            return vector

        # Comptage des occurrences
        total_categories_found = 0
        for video in videos:
            cats = video.get('categories', [])
            for cat in cats:
                if cat in self.category_map:
                    index = self.category_map[cat]
                    vector[index] += 1
                    total_categories_found += 1
        
        # Normalisation (L1) : La somme du vecteur doit faire 1 (représente 100% des intérêts)
        if total_categories_found > 0:
            vector = vector / total_categories_found
            
        return vector

    def _compute_behavior_stats(self, user_data: Dict) -> Dict[str, float]:
        """Calcule des ratios comportementaux."""
        followers = user_data.get('followers_count', 0)
        following = user_data.get('following_count', 1) # Eviter division par 0
        
        return {
            "social_ratio": round(followers / following if following > 0 else 0, 2),
            "engagement_rate": 0.0 # À implémenter avec des vraies données de vues
        }

    def _get_top_interests(self, vector: np.ndarray, top_n: int = 3) -> List[str]:
        """Récupère les noms des N catégories les plus fortes."""
        # argsort trie par ordre croissant, on prend les derniers indices et on inverse
        top_indices = vector.argsort()[-top_n:][::-1]
        
        top_interests = []
        for idx in top_indices:
            if vector[idx] > 0: # On ne garde que si l'intérêt existe
                top_interests.append(self.reference_categories[idx])
                
        return top_interests