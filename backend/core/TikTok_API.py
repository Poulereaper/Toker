# TikTok-API.py file will contain functions to interact with the TikTok API - for the moement, it will be a mock of this processe, so functions will return hardcoded data


# TikTok-API.py
import random
from typing import Dict, List

# Liste de catégories possibles pour les vidéos
CATEGORIES = [
    "Technology", "Education", "Music", "Dance", "Comedy", "Sports",
    "Fashion", "Food", "Travel", "Gaming", "Art", "Fitness",
    "Beauty", "DIY", "Pets", "Nature", "Science", "Business"
]

# Liste de hashtags populaires
HASHTAGS = [
    "#fyp", "#foryou", "#viral", "#trending", "#fun", "#entertainment",
    "#lifestyle", "#motivation", "#love", "#happy", "#inspo", "#aesthetic",
    "#tutorial", "#tips", "#howto", "#challenge", "#duet", "#comedy"
]

def generate_video_data(video_id: str, use_hashtags: bool = False) -> Dict:
    """Génère des données mockées pour une vidéo TikTok"""
    if use_hashtags:
        return {
            "video_id": video_id,
            "hashtags": random.sample(HASHTAGS, random.randint(2, 5)),
            "likes": random.randint(100, 10000),
            "comments": random.randint(10, 500),
            "shares": random.randint(5, 300)
        }
    else:
        return {
            "video_id": video_id,
            "categories": random.sample(CATEGORIES, random.randint(1, 3)),
            "likes": random.randint(100, 10000),
            "comments": random.randint(10, 500),
            "shares": random.randint(5, 300)
        }

def get_mock_tiktok_data(user_id: str = None) -> Dict:
    """
    Génère des données mockées d'un utilisateur TikTok
    
    Args:
        user_id: ID de l'utilisateur (optionnel, généré aléatoirement si non fourni)
    
    Returns:
        Dict contenant les données de l'utilisateur au format JSON
    """
    if user_id is None:
        user_id = str(random.randint(100000, 999999))
    
    # Génération des compteurs
    followers_count = random.randint(500, 50000)
    following_count = random.randint(100, 5000)
    videos_count = random.randint(50, 500)
    
    # Génération du nombre de likes (minimum 100 pour validation)
    number_of_likes = random.randint(100, 20000)
    
    # Génération des vidéos likées
    num_liked_videos = random.randint(100, 300)
    liked_videos = [
        generate_video_data(
            str(967235098000 + i),
            use_hashtags=random.choice([True, False])
        )
        for i in range(num_liked_videos)
    ]
    
    # Génération des vidéos partagées
    num_shared_videos = random.randint(10, 50)
    shared_videos = [
        generate_video_data(
            str(967235098000 + num_liked_videos + i),
            use_hashtags=False
        )
        for i in range(num_shared_videos)
    ]
    
    return {
        "user_id": user_id,
        "username": f"user_{user_id}",
        "user_pseudo": f"@tiktoker_{user_id}",
        "verified": random.choice([True, False]) if followers_count > 10000 else False,
        "followers_count": followers_count,
        "following_count": following_count,
        "likes_count": random.randint(1000, 50000),
        "videos_count": videos_count,
        "number_of_comments": random.randint(100, 5000),
        "number_of_likes_on_own_videos": random.randint(500, 30000),
        "number_of_likes": number_of_likes,
        "number_of_shares": random.randint(50, 5000),
        "liked_videos": liked_videos,
        "shared_videos": shared_videos
    }

def validate_tiktok_data(data: Dict) -> bool:
    """
    Valide que les données TikTok respectent les critères minimum
    
    Args:
        data: Dictionnaire contenant les données de l'utilisateur
    
    Returns:
        bool: True si les données sont valides (>= 100 likes), False sinon
    """
    return data.get("number_of_likes", 0) >= 100