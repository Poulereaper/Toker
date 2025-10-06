# cli.py
import argparse
import json
from core.API_geter import APIGetter, SocialPlatform
from core.Database import DatabaseManager

def create_fake_user(platform: str, user_id: str = None):
    """Crée un utilisateur fake et l'enregistre dans la base de données"""
    try:
        platform_enum = SocialPlatform(platform.lower())
        
        print(f"Génération de données pour {platform}...")
        api_getter = APIGetter()
        user_data = api_getter.get_user_data(platform_enum, user_id)
        
        print(f"Validation des données...")
        if not api_getter.validate_user_data(platform_enum, user_data):
            print("❌ Les données ne respectent pas les critères minimum (100 likes requis)")
            print(f"Nombre de likes: {user_data.get('number_of_likes', 0)}")
            return
        
        print(f"Sauvegarde dans la base de données...")
        db_manager = DatabaseManager()
        saved_user = db_manager.create_user(platform, user_data)
        
        print(f"✅ Utilisateur créé avec succès!")
        print(f"ID: {saved_user['id']}")
        print(f"Username: {saved_user['username']}")
        print(f"Likes: {user_data['number_of_likes']}")
        print(f"Vidéos likées: {len(user_data['liked_videos'])}")
        
    except Exception as e:
        print(f"❌ Erreur: {str(e)}")

def list_users():
    """Liste tous les utilisateurs de la base de données"""
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
        print(f"ID: {user['id']} | Platform: {user['platform']} | Username: {user['username']}")
        print(f"  Likes: {data.get('number_of_likes', 0)} | Vidéos likées: {len(data.get('liked_videos', []))}")
        print(f"  Créé le: {user['created_at']}")
        print()

def list_users_full():
    """Liste tous les utilisateurs avec TOUTES leurs données détaillées"""
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
        
        # En-tête utilisateur
        print(f"┌{'─'*98}┐")
        print(f"│ ID Base de données: {user['id']:<83}│")
        print(f"│ Plateforme: {user['platform']:<88}│")
        print(f"│ Créé le: {user['created_at']:<91}│")
        print(f"└{'─'*98}┘")
        
        # Informations de profil
        print(f"\n📱 PROFIL")
        print(f"  • User ID (social): {data.get('user_id', 'N/A')}")
        print(f"  • Username: {data.get('username', 'N/A')}")
        print(f"  • Pseudo: {data.get('user_pseudo', 'N/A')}")
        print(f"  • Vérifié: {'✓ Oui' if data.get('verified', False) else '✗ Non'}")
        
        # Statistiques
        print(f"\n📊 STATISTIQUES")
        print(f"  • Followers: {data.get('followers_count', 0):,}")
        print(f"  • Following: {data.get('following_count', 0):,}")
        print(f"  • Nombre de vidéos: {data.get('videos_count', 0):,}")
        print(f"  • Total likes: {data.get('likes_count', 0):,}")
        print(f"  • Likes sur vidéos perso: {data.get('number_of_likes_on_own_videos', 0):,}")
        print(f"  • Nombre de likes donnés: {data.get('number_of_likes', 0):,}")
        print(f"  • Nombre de commentaires: {data.get('number_of_comments', 0):,}")
        print(f"  • Nombre de partages: {data.get('number_of_shares', 0):,}")
        
        # Vidéos likées
        liked_videos = data.get('liked_videos', [])
        print(f"\n❤️  VIDÉOS LIKÉES ({len(liked_videos)} vidéos)")
        if liked_videos:
            # Afficher les 5 premières en détail
            for i, video in enumerate(liked_videos[:5], 1):
                print(f"  {i}. Video ID: {video.get('video_id', 'N/A')}")
                if 'categories' in video:
                    print(f"     Catégories: {', '.join(video['categories'])}")
                if 'hashtags' in video:
                    print(f"     Hashtags: {', '.join(video['hashtags'])}")
                print(f"     Likes: {video.get('likes', 0):,} | Comments: {video.get('comments', 0):,} | Shares: {video.get('shares', 0):,}")
            
            if len(liked_videos) > 5:
                print(f"  ... et {len(liked_videos) - 5} autres vidéos")
            
            # Statistiques sur les catégories
            categories = {}
            hashtags = {}
            for video in liked_videos:
                for cat in video.get('categories', []):
                    categories[cat] = categories.get(cat, 0) + 1
                for tag in video.get('hashtags', []):
                    hashtags[tag] = hashtags.get(tag, 0) + 1
            
            if categories:
                top_categories = sorted(categories.items(), key=lambda x: x[1], reverse=True)[:5]
                print(f"\n  📈 Top 5 catégories:")
                for cat, count in top_categories:
                    print(f"     • {cat}: {count} vidéos")
            
            if hashtags:
                top_hashtags = sorted(hashtags.items(), key=lambda x: x[1], reverse=True)[:5]
                print(f"\n  🏷️  Top 5 hashtags:")
                for tag, count in top_hashtags:
                    print(f"     • {tag}: {count} vidéos")
        else:
            print("  Aucune vidéo likée")
        
        # Vidéos partagées
        shared_videos = data.get('shared_videos', [])
        print(f"\n🔄 VIDÉOS PARTAGÉES ({len(shared_videos)} vidéos)")
        if shared_videos:
            # Afficher les 3 premières en détail
            for i, video in enumerate(shared_videos[:3], 1):
                print(f"  {i}. Video ID: {video.get('video_id', 'N/A')}")
                if 'categories' in video:
                    print(f"     Catégories: {', '.join(video['categories'])}")
                print(f"     Likes: {video.get('likes', 0):,} | Comments: {video.get('comments', 0):,} | Shares: {video.get('shares', 0):,}")
            
            if len(shared_videos) > 3:
                print(f"  ... et {len(shared_videos) - 3} autres vidéos")
        else:
            print("  Aucune vidéo partagée")
        
        # Données brutes (JSON)
        print(f"\n📄 DONNÉES BRUTES (JSON)")
        print(f"  Voir le dump complet ci-dessous:")
        print(f"  {'-'*96}")
        print(json.dumps(data, indent=2, ensure_ascii=False))
        
        print(f"\n{'='*100}\n\n")

def main():
    parser = argparse.ArgumentParser(description="CLI Toker - Génération d'utilisateurs fake")
    subparsers = parser.add_subparsers(dest="command", help="Commandes disponibles")
    
    # Commande create
    create_parser = subparsers.add_parser("create", help="Créer un utilisateur fake")
    create_parser.add_argument("platform", choices=["tiktok", "instagram", "x"], 
                              help="Plateforme sociale")
    create_parser.add_argument("--user-id", help="ID utilisateur spécifique (optionnel)")
    
    # Commande list
    list_parser = subparsers.add_parser("list", help="Lister tous les utilisateurs (résumé)")
    
    # Commande listfull (NOUVELLE)
    listfull_parser = subparsers.add_parser("listfull", help="Lister tous les utilisateurs avec toutes leurs données")
    
    args = parser.parse_args()
    
    if args.command == "create":
        create_fake_user(args.platform, args.user_id)
    elif args.command == "list":
        list_users()
    elif args.command == "listfull":
        list_users_full()
    else:
        parser.print_help()

if __name__ == "__main__":
    main()