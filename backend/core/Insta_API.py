# Insta-API.py file will contain functions to interact with the Instagram API - for the moement, it will be a mock of this processe, so functions will return hardcoded data# backend/core/Insta_API.py
import random
from typing import Dict, List
from .TikTok_API import CATEGORIES  # On réutilise les mêmes catégories pour la cohérence du matching

# Hashtags spécifiques à Instagram
INSTA_HASHTAGS = [
    "#instagood", "#photooftheday", "#fashion", "#beautiful", "#happy",
    "#cute", "#tbt", "#like4like", "#followme", "#picoftheday",
    "#selfie", "#summer", "#art", "#instadaily", "#friends", "#repost"
]

def generate_insta_post(post_id: str) -> Dict:
    """Génère un post/reel Instagram mocké"""
    return {
        "video_id": post_id, # On garde "video_id" pour compatibilité avec le DataProcessor
        "type": random.choice(["image", "reel", "carousel"]),
        "categories": random.sample(CATEGORIES, random.randint(1, 3)),
        "hashtags": random.sample(INSTA_HASHTAGS, random.randint(2, 6)),
        "likes": random.randint(50, 50000),
        "comments": random.randint(5, 1000),
        "shares": random.randint(0, 500) # Share en story ou DM
    }

def get_mock_instagram_data(user_id: str = None) -> Dict:
    """Génère des données mockées pour un profil Instagram"""
    if user_id is None:
        user_id = str(random.randint(100000, 999999))
    
    # Instagram a souvent des ratios followers/following différents de TikTok
    followers = random.randint(200, 100000)
    following = random.randint(100, 2000)
    
    # Génération des posts likés (Source principale d'intérêt)
    liked_content = [
        generate_insta_post(f"insta_{i}") 
        for i in range(random.randint(80, 250))
    ]
    
    return {
        "user_id": user_id,
        "platform": "instagram",
        "username": f"insta_user_{user_id}",
        "user_pseudo": f"@insta_{user_id}",
        "verified": followers > 20000,
        "biography": "Just living my best life 📸 | Traveler ✈️",
        "followers_count": followers,
        "following_count": following,
        "posts_count": random.randint(20, 1000),
        "number_of_likes": random.randint(500, 50000), # Total likes reçus
        "liked_videos": liked_content # On garde la clé "liked_videos" pour que le DataProcessor fonctionne direct
    }

def validate_instagram_data(data: Dict) -> bool:
    # Sur Insta, on peut considérer qu'un profil est valide s'il a au moins 50 abonnés
    return data.get("followers_count", 0) >= 50