# backend/cli.py
import argparse
import sys
from core.API_geter import APIGetter, SocialPlatform
from core.Database import DatabaseManager
from core.Data_processing import DataProcessor
from core.Auth_Service import AuthService

def create_fake_user(platform: str, user_id: str = None):
    """
    Force la création d'un utilisateur (Admin/Test) sans passer par l'authentification.
    Génère les données, calcule le vecteur et sauvegarde.
    """
    try:
        platform_enum = SocialPlatform(platform.lower())
        
        print(f"🔄 [FORCE CREATE] Génération de données pour {platform}...")
        api_getter = APIGetter()
        # Si aucun user_id n'est fourni, l'API en générera un aléatoire
        user_data = api_getter.get_user_data(platform_enum, user_id)
        
        print(f"🔍 Validation des données...")
        if not api_getter.validate_user_data(platform_enum, user_data):
            print("❌ Les données ne respectent pas les critères minimum (ex: 100 likes requis)")
            print(f"   Nombre de likes trouvés: {user_data.get('number_of_likes', 0)}")
            return
        
        print(f"🧠 Traitement & Vectorisation des données...")
        processor = DataProcessor()
        vector_data = processor.process_user_data(user_data)
        
        print(f"💾 Sauvegarde dans la base de données...")
        db_manager = DatabaseManager()
        saved_user = db_manager.create_user(platform, user_data, vector_data)
        
        print(f"✅ Utilisateur créé avec succès!")
        print(f"   ID DB: {saved_user['id']}")
        print(f"   Username: {saved_user['username']}")
        print(f"   Top Intérêts: {', '.join(vector_data['top_interests'])}")
        
    except Exception as e:
        print(f"❌ Erreur: {str(e)}")

def simulate_login_flow(platform: str, username: str, password: str):
    """
    Simule le flux complet : Login -> Récupération -> Vectorisation -> Sauvegarde
    """
    print(f"\n🔐 Tentative de connexion à {platform.capitalize()} pour '{username}'...")
    
    # 1. Authentification
    success, message = AuthService.mock_login(platform, {"username": username, "password": password})
    
    if not success:
        print(f"❌ ÉCHEC AUTHENTIFICATION : {message}")
        return

    print(f"✅ Authentification réussie. Récupération du profil...")

    try:
        platform_enum = SocialPlatform(platform.lower())
        
        # 2. Récupération des données (Mock)
        # On utilise le username comme seed/user_id pour que les données soient "liées" au pseudo
        api_getter = APIGetter()
        user_data = api_getter.get_user_data(platform_enum, user_id=username)
        
        # 3. Validation
        if not api_getter.validate_user_data(platform_enum, user_data):
            print(f"⚠️  Compte non éligible (Pas assez d'activité/likes).")
            return

        # 4. Vectorisation
        print(f"🧠 Analyse du profil (Vectorisation)...")
        processor = DataProcessor()
        vector_data = processor.process_user_data(user_data)
        
        # 5. Sauvegarde
        print(f"💾 Enregistrement du nouvel utilisateur...")
        db_manager = DatabaseManager()
        saved_user = db_manager.create_user(platform, user_data, vector_data)
        
        print(f"\n🎉 SUCCÈS ! Profil connecté et analysé.")
        print(f"   ID DB: {saved_user['id']}")
        print(f"   Intérêts détectés: {vector_data['top_interests']}")
        print(f"   Score social: {vector_data['behavior_stats']['social_ratio']}")

    except Exception as e:
        print(f"❌ Erreur système lors du flux de connexion: {str(e)}")


def list_users():
    """Liste tous les utilisateurs (Résumé)"""
    db_manager = DatabaseManager()
    users = db_manager.get_all_users()
    
    if not users:
        print("Aucun utilisateur dans la base de données")
        return
    
    print(f"\n{'='*80}")
    print(f"Total: {len(users)} utilisateur(s)")
    print(f"{'='*80}\n")
    
    for user in users:
        data = user['data']
        # On essaie de récupérer les top intérêts s'ils existent (compatibilité avec vieux records)
        vector = user.get('vector_data')
        interests = ", ".join(vector['top_interests'][:3]) if vector else "N/A"
        
        print(f"ID: {user['id']} | {user['platform']:<10} | User: {user['username']:<20}")
        print(f"   Likes: {data.get('number_of_likes', 0):<6} | Intérêts: {interests}")
        print()

def list_users_full():
    """Liste détaillée avec affichage des vecteurs"""
    db_manager = DatabaseManager()
    users = db_manager.get_all_users()
    
    if not users:
        print("Aucun utilisateur dans la base de données")
        return
    
    print(f"\n{'='*100}")
    print(f"LISTE COMPLÈTE DES UTILISATEURS - Total: {len(users)}")
    print(f"{'='*100}\n")
    
    for user in users:
        data = user['data']
        vector = user.get('vector_data') # Peut être None si vieilles données
        
        # En-tête
        print(f"┌{'─'*98}┐")
        print(f"│ ID: {str(user['id']):<4} | Plateforme: {user['platform']:<15} | Pseudo: {user['username']:<52}│")
        print(f"└{'─'*98}┘")
        
        # 1. Vector Data (La partie importante pour le matching)
        if vector:
            print(f"\n🧠 PROFIL VECTORIEL (Analyse IA)")
            print(f"  • Top Intérêts: {', '.join(vector.get('top_interests', []))}")
            stats = vector.get('behavior_stats', {})
            print(f"  • Ratio Social: {stats.get('social_ratio', 'N/A')} (Followers/Following)")
            
            # Affichage graphique simple du vecteur
            print(f"  • Aperçu du vecteur (valeurs non-nulles):")
            interest_vec = vector.get('interest_vector', [])
            # On récupère les catégories depuis le processeur pour l'affichage (astuce)
            # Dans un cas réel, on stockerait les labels ou on les importerait
            # Ici on affiche juste les indices non nuls pour vérifier que ça marche
            non_zeros = [(i, v) for i, v in enumerate(interest_vec) if v > 0]
            non_zeros.sort(key=lambda x: x[1], reverse=True)
            for idx, val in non_zeros[:5]:
                print(f"    - Catégorie index {idx}: {val:.2%}")
        else:
            print(f"\n⚠️  PAS DE DONNÉES VECTORIELLES (Ancien format)")

        # 2. Stats brutes
        print(f"\n📊 STATISTIQUES BRUTES")
        print(f"  • Followers: {data.get('followers_count', 0):,} | Following: {data.get('following_count', 0):,}")
        print(f"  • Likes reçus: {data.get('number_of_likes', 0):,} | Vidéos likées: {len(data.get('liked_videos', []))}")
        
        # 3. Contenu (Vidéos likées) - Résumé
        liked = data.get('liked_videos', [])
        print(f"\n❤️  CONTENU APPRÉCIÉ ({len(liked)} items)")
        if liked:
            # On affiche juste les catégories des 3 premières vidéos pour vérifier le parsing
            for i, vid in enumerate(liked[:3]):
                cats = vid.get('categories', [])
                print(f"  {i+1}. {vid.get('video_id')} -> Tags: {cats}")
            if len(liked) > 3: print(f"  ... (+ {len(liked)-3} autres)")
            
        print(f"\n{'='*100}\n")
def delete_user_cmd(user_id: int):
    """Supprime un utilisateur spécifique"""
    print(f"🗑️  Suppression de l'utilisateur ID {user_id}...")
    db = DatabaseManager()
    if db.delete_user(user_id):
        print(f"✅ Utilisateur {user_id} supprimé avec succès.")
    else:
        print(f"❌ Utilisateur {user_id} introuvable.")

def delete_all_cmd():
    """Supprime tous les utilisateurs"""
    confirm = input("⚠️  ATTENTION: Vous allez supprimer TOUS les utilisateurs. Confirmer ? (y/N): ")
    if confirm.lower() != 'y':
        print("Annulé.")
        return

    db = DatabaseManager()
    count = db.delete_all_users()
    print(f"💥 Base de données nettoyée. {count} utilisateurs supprimés.")

def refresh_user_cmd(user_id: int):
    """Met à jour les données d'un utilisateur existant"""
    print(f"🔄 Mise à jour du profil utilisateur ID {user_id}...")
    
    db = DatabaseManager()
    user = db.get_user(user_id)
    
    if not user:
        print(f"❌ Utilisateur {user_id} introuvable.")
        return

    try:
        # Récupération des infos existantes
        platform = user['platform']
        username = user['username']
        print(f"   Cible: {username} sur {platform}")

        # Regénération des données
        print("   📡 Récupération des nouvelles données mockées...")
        api = APIGetter()
        new_data = api.get_user_data(SocialPlatform(platform), user_id=username)
        
        print("   🧠 Recalcul du vecteur d'intérêts...")
        processor = DataProcessor()
        new_vector = processor.process_user_data(new_data)

        # Sauvegarde
        db.update_user(user_id, new_data, new_vector)
        print(f"✅ Profil mis à jour !")
        print(f"   Nouveaux intérêts majeurs: {', '.join(new_vector['top_interests'])}")

    except Exception as e:
        print(f"❌ Erreur lors du refresh: {e}")

def main():
    parser = argparse.ArgumentParser(description="CLI Toker - Admin Interface")
    subparsers = parser.add_subparsers(dest="command", help="Commandes disponibles")
    
    # Commandes existantes
    create_parser = subparsers.add_parser("create", help="Créer un user manuellement")
    create_parser.add_argument("platform", choices=["tiktok", "instagram", "x"])
    create_parser.add_argument("--user-id", help="ID Custom")
    
    login_parser = subparsers.add_parser("login", help="Simuler connexion")
    login_parser.add_argument("platform", choices=["tiktok", "instagram", "x"])
    login_parser.add_argument("username")
    login_parser.add_argument("password")

    subparsers.add_parser("list", help="Lister simple")
    subparsers.add_parser("listfull", help="Lister complet")
    
    # NOUVELLES COMMANDES ADMIN
    del_parser = subparsers.add_parser("delete", help="Supprimer un utilisateur")
    del_parser.add_argument("id", type=int, help="ID de l'utilisateur (DB ID)")

    subparsers.add_parser("delete-all", help="Supprimer TOUS les utilisateurs")

    refresh_parser = subparsers.add_parser("refresh", help="Regénérer les données d'un utilisateur")
    refresh_parser.add_argument("id", type=int, help="ID de l'utilisateur (DB ID)")

    args = parser.parse_args()
    
    if args.command == "create":
        create_fake_user(args.platform, args.user_id)
    elif args.command == "login":
        simulate_login_flow(args.platform, args.username, args.password)
    elif args.command == "list":
        list_users()
    elif args.command == "listfull":
        list_users_full()
    elif args.command == "delete":
        delete_user_cmd(args.id)
    elif args.command == "delete-all":
        delete_all_cmd()
    elif args.command == "refresh":
        refresh_user_cmd(args.id)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()