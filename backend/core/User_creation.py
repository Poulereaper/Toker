# backend/core/User_creation.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json

from .API_geter import APIGetter, SocialPlatform
from .Database import DatabaseManager
from .Data_processing import DataProcessor

@csrf_exempt
@require_http_methods(["POST"])
def connect_social_account(request) -> JsonResponse:
    """
    Endpoint simulant une connexion OAuth / Login social.
    
    Body JSON attendu:
    {
        "platform": "tiktok",
        "username": "mon_pseudo",
        "password": "fake_password_123" 
    }
    """
    try:
        body = json.loads(request.body)
        platform_str = body.get("platform", "").lower()
        username = body.get("username")
        password = body.get("password")
        
        # 1. Simulation de l'authentification
        if not username or not password:
            return JsonResponse({"success": False, "error": "Username and password required"}, status=400)
        
        # Ici on pourrait ajouter une logique fake : if password != "1234": return error
        
        # Validation de la plateforme
        try:
            platform = SocialPlatform(platform_str)
        except ValueError:
            return JsonResponse({"success": False, "error": f"Invalid platform. Use: tiktok, instagram, x"}, status=400)

        # 2. Récupération des données (Mock API)
        # On utilise le username comme seed ou user_id pour le mock
        api_getter = APIGetter()
        # Note: dans le mock actuel, on passait user_id, ici on simule que le username suffit
        user_data = api_getter.get_user_data(platform, user_id=username) 
        
        # Validation (min 100 likes)
        if not api_getter.validate_user_data(platform, user_data):
            return JsonResponse({
                "success": False, 
                "error": "Profile not eligible (Not enough likes/activity)",
                "details": {"likes": user_data.get("number_of_likes", 0)}
            }, status=403)
            
        # 3. Traitement des données (Vectorisation)
        print(f"Processing data for {username}...")
        processor = DataProcessor()
        processed_result = processor.process_user_data(user_data)
        
        # 4. Sauvegarde en Base de Données (Données brutes + Vecteur)
        db_manager = DatabaseManager()
        # On essaie de créer, si ça échoue (doublon), il faudrait gérer l'update (TODO pour plus tard)
        try:
            saved_user = db_manager.create_user(
                platform=platform_str, 
                user_data=user_data,
                vector_data=processed_result
            )
        except Exception as e:
             return JsonResponse({"success": False, "error": f"Database error: {str(e)}"}, status=500)

        return JsonResponse({
            "success": True,
            "message": "Connected and profile vectorized successfully",
            "user": {
                "id": saved_user["id"],
                "username": saved_user["username"],
                "top_interests": processed_result["top_interests"], # On renvoie direct les résultats intéressants
                "vector_preview": processed_result["interest_vector"][:5] # Juste pour debug
            }
        }, status=201)

    except json.JSONDecodeError:
        return JsonResponse({"success": False, "error": "Invalid JSON"}, status=400)
    except Exception as e:
        return JsonResponse({"success": False, "error": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["DELETE"])
def delete_user_endpoint(request, user_id: int) -> JsonResponse:
    """Endpoint pour supprimer un utilisateur spécifique"""
    try:
        db = DatabaseManager()
        success = db.delete_user(user_id)
        if success:
            return JsonResponse({"success": True, "message": f"User {user_id} deleted"})
        else:
            return JsonResponse({"success": False, "error": "User not found"}, status=404)
    except Exception as e:
        return JsonResponse({"success": False, "error": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["DELETE"])
def delete_all_users_endpoint(request) -> JsonResponse:
    """Endpoint ADMIN pour vider la base de données"""
    try:
        db = DatabaseManager()
        count = db.delete_all_users()
        return JsonResponse({"success": True, "message": f"All users deleted ({count} records)"})
    except Exception as e:
        return JsonResponse({"success": False, "error": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def refresh_user_endpoint(request, user_id: int) -> JsonResponse:
    """
    Regénère les données sociales et le vecteur d'un utilisateur
    tout en conservant son identité (ID, pseudo).
    """
    try:
        db = DatabaseManager()
        existing_user = db.get_user(user_id)
        
        if not existing_user:
            return JsonResponse({"success": False, "error": "User not found"}, status=404)

        # 1. Récupération des infos de base
        platform_str = existing_user["platform"]
        username = existing_user["username"]
        platform_enum = SocialPlatform(platform_str)

        # 2. Appel API Mock (Génère de nouvelles stats aléatoires)
        api = APIGetter()
        new_user_data = api.get_user_data(platform_enum, user_id=username)

        # 3. Recalcul du vecteur
        processor = DataProcessor()
        new_vector_data = processor.process_user_data(new_user_data)

        # 4. Mise à jour en base
        db.update_user(user_id, new_user_data, new_vector_data)

        return JsonResponse({
            "success": True, 
            "message": "User refreshed",
            "new_interests": new_vector_data["top_interests"]
        })

    except Exception as e:
        return JsonResponse({"success": False, "error": str(e)}, status=500)