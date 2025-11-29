# backend/core/API_geter.py
from typing import Dict, Optional
from enum import Enum

# Import des modules API mockés (DÉCOMMENTÉS)
from .TikTok_API import get_mock_tiktok_data, validate_tiktok_data
from .Insta_API import get_mock_instagram_data, validate_instagram_data
from .X_API import get_mock_x_data, validate_x_data

class SocialPlatform(Enum):
    TIKTOK = "tiktok"
    INSTAGRAM = "instagram"
    X = "x"

class APIGetter:
    """Classe pour gérer la récupération de données depuis différentes API"""
    
    @staticmethod
    def get_user_data(platform: SocialPlatform, user_id: Optional[str] = None) -> Dict:
        if platform == SocialPlatform.TIKTOK:
            return get_mock_tiktok_data(user_id)
        elif platform == SocialPlatform.INSTAGRAM:
            return get_mock_instagram_data(user_id) # Maintenant fonctionnel
        elif platform == SocialPlatform.X:
            return get_mock_x_data(user_id)         # Maintenant fonctionnel
        else:
            raise ValueError(f"Unsupported platform: {platform}")
    
    @staticmethod
    def validate_user_data(platform: SocialPlatform, data: Dict) -> bool:
        if platform == SocialPlatform.TIKTOK:
            return validate_tiktok_data(data)
        elif platform == SocialPlatform.INSTAGRAM:
            return validate_instagram_data(data)    # Maintenant fonctionnel
        elif platform == SocialPlatform.X:
            return validate_x_data(data)            # Maintenant fonctionnel
        else:
            raise ValueError(f"Unsupported platform: {platform}")