# X-API.py file will contain functions to interact with multiple social media APIs - for the moment, it will be a mock of this process, so functions will return hardcoded data# backend/core/X_API.py
import random
from typing import Dict, List
from .TikTok_API import CATEGORIES

# Hashtags plus "news/tech/opinion" typiques de X
X_HASHTAGS = [
    "#crypto", "#news", "#tech", "#python", "#coding", "#politics",
    "#gaming", "#giveaway", "#nft", "#sport", "#football", "#debate"
]

def generate_tweet_data(tweet_id: str) -> Dict:
    """Génère un tweet mocké"""
    return {
        "video_id": tweet_id, # ID technique pour le processeur
        "is_retweet": random.choice([True, False]),
        "text_length": random.randint(20, 280),
        "categories": random.sample(CATEGORIES, random.randint(1, 2)), # Catégorie déduite du texte
        "hashtags": random.sample(X_HASHTAGS, random.randint(0, 3)),
        "likes": random.randint(0, 5000),
        "retweets": random.randint(0, 2000), # Equivalent shares
        "replies": random.randint(0, 500)    # Equivalent comments
    }

def get_mock_x_data(user_id: str = None) -> Dict:
    """Génère des données mockées pour un profil X"""
    if user_id is None:
        user_id = str(random.randint(100000, 999999))
        
    liked_tweets = [
        generate_tweet_data(f"tweet_{i}") 
        for i in range(random.randint(50, 400))
    ]
    
    return {
        "user_id": user_id,
        "platform": "x",
        "username": f"x_user_{user_id}",
        "user_pseudo": f"@x_{user_id}",
        "verified": random.choice([True, False]), # Blue checkmark
        "followers_count": random.randint(10, 20000),
        "following_count": random.randint(50, 5000),
        "tweet_count": random.randint(100, 10000),
        "number_of_likes": random.randint(100, 10000),
        "liked_videos": liked_tweets # Le DataProcessor traitera ces tweets comme des items d'intérêt
    }

def validate_x_data(data: Dict) -> bool:
    # Pour X, on valide si l'utilisateur a liké au moins 50 tweets (assez de data pour le profilage)
    return len(data.get("liked_videos", [])) >= 50