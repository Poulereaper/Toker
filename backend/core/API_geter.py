#API-geter.py file will contain functions to get data from the API

# API-geter.py
from typing import Dict, Optional
from enum import Enum

# Import des modules API mockés
from .TikTok_API import get_mock_tiktok_data, validate_tiktok_data
# from .Insta_API import get_mock_instagram_data, validate_instagram_data
# from .X_API import get_mock_x_data, validate_x_data

class SocialPlatform(Enum):
    """Énumération des plateformes sociales supportées"""
    TIKTOK = "tiktok"
    INSTAGRAM = "instagram"
    X = "x"

class APIGetter:
    """Classe pour gérer la récupération de données depuis différentes API"""
    
    @staticmethod
    def get_user_data(platform: SocialPlatform, user_id: Optional[str] = None) -> Dict:
        """
        Récupère les données d'un utilisateur depuis une plateforme
        
        Args:
            platform: Plateforme sociale (TikTok, Instagram, X)
            user_id: ID de l'utilisateur (optionnel)
        
        Returns:
            Dict contenant les données de l'utilisateur
        
        Raises:
            ValueError: Si la plateforme n'est pas supportée
        """
        if platform == SocialPlatform.TIKTOK:
            return get_mock_tiktok_data(user_id)
        elif platform == SocialPlatform.INSTAGRAM:
            # return get_mock_instagram_data(user_id)
            raise NotImplementedError("Instagram API not implemented yet")
        elif platform == SocialPlatform.X:
            # return get_mock_x_data(user_id)
            raise NotImplementedError("X API not implemented yet")
        else:
            raise ValueError(f"Unsupported platform: {platform}")
    
    @staticmethod
    def validate_user_data(platform: SocialPlatform, data: Dict) -> bool:
        """
        Valide les données d'un utilisateur
        
        Args:
            platform: Plateforme sociale
            data: Données de l'utilisateur à valider
        
        Returns:
            bool: True si les données sont valides, False sinon
        """
        if platform == SocialPlatform.TIKTOK:
            return validate_tiktok_data(data)
        elif platform == SocialPlatform.INSTAGRAM:
            # return validate_instagram_data(data)
            raise NotImplementedError("Instagram validation not implemented yet")
        elif platform == SocialPlatform.X:
            # return validate_x_data(data)
            raise NotImplementedError("X validation not implemented yet")
        else:
            raise ValueError(f"Unsupported platform: {platform}")