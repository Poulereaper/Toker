# backend/core/Auth_Service.py
from typing import Dict, Tuple

class AuthService:
    """
    Service dédié à la gestion de l'authentification et de la connexion aux plateformes.
    Sépare la logique de connexion de la logique de création d'utilisateur.
    """

    @staticmethod
    def mock_login(platform: str, credentials: Dict[str, str]) -> Tuple[bool, str]:
        """
        Simule une tentative de connexion à une plateforme.
        
        Args:
            platform: Le nom de la plateforme (tiktok, instagram, x)
            credentials: Dictionnaire contenant 'username' et 'password'
            
        Returns:
            Tuple (succès: bool, message: str)
        """
        username = credentials.get("username")
        password = credentials.get("password")

        # Simulation de vérification basique
        if not username or not password:
            return False, "Username and password are required"

        # Ici, on pourrait ajouter des règles métier fictives
        # Ex: rejeter si le mot de passe est trop court pour simuler une erreur
        if len(password) < 4:
            return False, "Password too short (simulation)"

        # Dans le futur, c'est ici que se fera l'échange de code OAuth contre un Token
        print(f"✅ [MOCK AUTH] Connexion réussie à {platform} pour l'utilisateur {username}")
        
        return True, "Authentication successful"