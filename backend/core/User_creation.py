# USer-creation.py file will contain functions to create and manage user accounts (after he logged in with OAuth)
# For the moement, we don't have the rights to use OAuth etc, so it will be a simple auth with or user creation with fake data
# This part is and end point for user creation and it will use Django

# User-creation.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
from typing import Dict

from .API_geter import APIGetter, SocialPlatform
from .Database import DatabaseManager

@csrf_exempt
@require_http_methods(["POST"])
def create_user_from_social(request) -> JsonResponse:
    """
    Endpoint pour créer un utilisateur à partir de données sociales
    
    Body JSON attendu:
    {
        "platform": "tiktok",  // ou "instagram", "x"
        "user_id": "123456"    // optionnel
    }
    
    Returns:
        JsonResponse avec le statut de création et les données de l'utilisateur
    """
    try:
        # Parsing du body
        body = json.loads(request.body)
        platform_str = body.get("platform", "").lower()
        user_id = body.get("user_id")
        
        # Validation de la plateforme
        try:
            platform = SocialPlatform(platform_str)
        except ValueError:
            return JsonResponse({
                "success": False,
                "error": f"Invalid platform: {platform_str}. Must be one of: tiktok, instagram, x"
            }, status=400)
        
        # Récupération des données
        api_getter = APIGetter()
        user_data = api_getter.get_user_data(platform, user_id)
        
        # Validation des données
        if not api_getter.validate_user_data(platform, user_data):
            return JsonResponse({
                "success": False,
                "error": "User data does not meet minimum requirements (needs at least 100 likes)",
                "data": user_data
            }, status=400)
        
        # Sauvegarde dans la base de données
        db_manager = DatabaseManager()
        saved_user = db_manager.create_user(platform_str, user_data)
        
        return JsonResponse({
            "success": True,
            "message": "User created successfully",
            "user": saved_user
        }, status=201)
        
    except json.JSONDecodeError:
        return JsonResponse({
            "success": False,
            "error": "Invalid JSON body"
        }, status=400)
    except Exception as e:
        return JsonResponse({
            "success": False,
            "error": str(e)
        }, status=500)

@require_http_methods(["GET"])
def get_user(request, user_id: str) -> JsonResponse:
    """
    Endpoint pour récupérer un utilisateur par son ID
    
    Args:
        user_id: ID de l'utilisateur dans la base de données
    
    Returns:
        JsonResponse avec les données de l'utilisateur
    """
    try:
        db_manager = DatabaseManager()
        user = db_manager.get_user(user_id)
        
        if user is None:
            return JsonResponse({
                "success": False,
                "error": f"User {user_id} not found"
            }, status=404)
        
        return JsonResponse({
            "success": True,
            "user": user
        }, status=200)
        
    except Exception as e:
        return JsonResponse({
            "success": False,
            "error": str(e)
        }, status=500)