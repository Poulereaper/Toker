import 'package:flutter/material.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      // Login Screen
      'welcome_to_toker': 'Bienvenue sur Toker',
      'find_love_tiktok': 'Trouve l\'amour grâce à TikTok',
      'sign_up_tiktok': 'S\'inscrire avec TikTok',
      'login_tiktok': 'Se connecter avec TikTok',
      'terms_agreement': 'En continuant, vous acceptez nos',
      'terms_of_service': 'Conditions d\'utilisation',
      'and': 'et',
      'privacy_policy': 'Politique de confidentialité',
      
      // Onboarding
      'step': 'Étape',
      'of': 'sur',
      'continue': 'Continuer',
      'skip': 'Passer',
      'next': 'Suivant',
      'finish': 'Terminer',
      
      // Onboarding Step 1
      'basic_info': 'Informations de base',
      'first_name': 'Prénom',
      'enter_first_name': 'Entre ton prénom',
      'birth_date': 'Date de naissance',
      'select_date': 'Sélectionne ta date',
      'gender': 'Genre',
      'man': 'Homme',
      'woman': 'Femme',
      'other': 'Autre',
      
      // Onboarding Step 2
      'looking_for': 'Je cherche',
      'men': 'Hommes',
      'women': 'Femmes',
      'everyone': 'Tous',
      
      // Interests
      'your_interests': 'Tes centres d\'intérêt',
      'auto_detected': 'Voici tes centres d\'intérêt détectés automatiquement',
      'detected_from_tiktok': 'Détectés automatiquement depuis TikTok 🎵',
      'select_interests': 'Sélectionnez entre 4 et 8 centres d\'intérêt',
      'min_interests': 'Vous devez avoir au moins 4 centres d\'intérêt',
      'max_interests': 'Maximum 8 centres d\'intérêt',
      'add_interest': 'Ajouter un centre d\'intérêt',
      
      // Photos
      'your_photos': 'Tes photos',
      'add_photos_desc': 'Ajoute au moins 2 photos pour continuer',
      'add_photo': 'Ajouter une photo',
      'add_caption': 'Ajouter légende',
      'edit_caption': 'Modifier',
      'in_my': 'Dans mon...',
      
      // Prompts
      'your_prompts': 'Tes accroches',
      'add_prompts_desc': 'Ajoute au moins 2 accroches pour te démarquer',
      'add_prompt': 'Ajouter une accroche',
      'select_prompt': 'Sélectionne une accroche',
      'your_answer': 'Ta réponse...',
      
      // Home Screen
      'discover': 'Découvrir',
      'no_more_profiles': 'Plus de profils pour le moment',
      'check_back_later': 'Reviens plus tard !',
      'compatible': 'compatible',
      
      // Matches Screen
      'matches': 'Matchs',
      'new_matches': 'Nouveaux matchs',
      'messages': 'Messages',
      'no_matches': 'Aucun match pour le moment',
      'start_swiping': 'Commence à swiper !',
      'you_matched': 'Vous avez matché !',
      'send_message': 'Envoyer un message',
      'keep_swiping': 'Continuer à swiper',
      
      // Likes Screen  
      'likes': 'Likes',
      'people_who_liked': 'Personnes qui t\'ont liké',
      'no_likes': 'Personne ne t\'a encore liké',
      'be_patient': 'Sois patient !',
      'liked_you': 't\'a liké',
      
      // Profile Screen
      'my_profile': 'Mon Profil',
      'about': 'À propos',
      'interests': 'Centres d\'intérêt',
      'preferences': 'Préférences',
      'i_am': 'Je suis',
      'i_look_for': 'Je cherche',
      'edit_profile': 'Modifier le profil',
      'logout': 'Se déconnecter',
      'upgrade_premium': 'Passer à Premium',
      'unlock_features': 'Débloquez toutes les fonctionnalités',
      'buy_superlikes': 'Acheter des Superlikes',
      'free_per_week': '1 gratuit par semaine',
      'stand_out': 'Démarquez-vous auprès de vos coups de cœur',
      
      // Edit Profile
      'edit_my_profile': 'Modifier le profil',
      'save': 'Enregistrer',
      'photos': 'Photos',
      'edit_photos': 'Modifier mes photos',
      'prompts': 'Accroches',
      'edit_prompts': 'Modifier mes accroches',
      'tell_about_you': 'Parlez-nous de vous...',
      'profile_updated': 'Profil mis à jour !',
      
      // Settings
      'settings': 'Paramètres',
      'account': 'Compte',
      'pause_profile': 'Mettre en pause',
      'hide_profile_temp': 'Masquer mon profil temporairement',
      'profile_paused': 'Profil mis en pause',
      'profile_reactivated': 'Profil réactivé',
      'notifications': 'Notifications',
      'enable_notifications': 'Activer les notifications',
      'receive_all': 'Recevoir toutes les notifications',
      'new_matches_notif': 'Nouveaux matchs',
      'notified_matches': 'Être notifié des nouveaux matchs',
      'messages_notif': 'Messages',
      'notified_messages': 'Être notifié des nouveaux messages',
      'language': 'Langue',
      'app_language': 'Langue de l\'application',
      'language_changed': 'Langue changée en',
      'privacy': 'Confidentialité',
      'manage_data': 'Gérer mes données',
      'blocked_users': 'Utilisateurs bloqués',
      'manage_blocked': 'Gérer les utilisateurs bloqués',
      'about_app': 'À propos',
      'terms_of_use': 'Conditions d\'utilisation',
      'help_center': 'Centre d\'aide',
      'coming_soon': 'Fonctionnalité à venir',
      
      // Premium
      'toker_premium': 'Toker Premium',
      'unlimited_likes': 'Likes illimités',
      'swipe_unlimited': 'Swipez sans limite',
      'unlimited_superlikes': 'Superlikes illimités',
      'invisible_mode': 'Mode invisible',
      'browse_discreet': 'Naviguez en toute discrétion',
      'rewind': 'Retour en arrière',
      'undo_swipes': 'Annulez vos derniers swipes',
      'advanced_location': 'Localisation avancée',
      'change_location': 'Changez votre position',
      'advanced_filters': 'Filtres avancés',
      'refine_search': 'Affinez vos recherches',
      'choose_plan': 'Choisissez votre formule',
      'week': 'semaine',
      'month': 'mois',
      'months': 'mois',
      'save': 'Économisez',
      'popular': 'POPULAIRE',
      'auto_renew': 'Abonnement renouvelé automatiquement. Annulez à tout moment.',
      
      // Superlikes
      'buy_superlikes_title': 'Acheter des Superlikes',
      'superlikes_5': '5 Superlikes',
      'superlikes_10': '10 Superlikes',
      'superlikes_25': '25 Superlikes',
      'purchase_for': 'Achat de',
      'for': 'pour',
      
      // Chat
      'write_message': 'Écris un message...',
      'no_messages': 'Aucun message',
      'today': 'Aujourd\'hui',
      'yesterday': 'Hier',
      
      // Common
      'close': 'Fermer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'confirm': 'Confirmer',
      'yes': 'Oui',
      'no': 'Non',
      'ok': 'OK',
      'error': 'Erreur',
      'success': 'Succès',
    },
    'en': {
      // Login Screen
      'welcome_to_toker': 'Welcome to Toker',
      'find_love_tiktok': 'Find love through TikTok',
      'sign_up_tiktok': 'Sign up with TikTok',
      'login_tiktok': 'Log in with TikTok',
      'terms_agreement': 'By continuing, you agree to our',
      'terms_of_service': 'Terms of Service',
      'and': 'and',
      'privacy_policy': 'Privacy Policy',
      
      // Onboarding
      'step': 'Step',
      'of': 'of',
      'continue': 'Continue',
      'skip': 'Skip',
      'next': 'Next',
      'finish': 'Finish',
      
      // Onboarding Step 1
      'basic_info': 'Basic Information',
      'first_name': 'First Name',
      'enter_first_name': 'Enter your first name',
      'birth_date': 'Birth Date',
      'select_date': 'Select your date',
      'gender': 'Gender',
      'man': 'Man',
      'woman': 'Woman',
      'other': 'Other',
      
      // Onboarding Step 2
      'looking_for': 'Looking for',
      'men': 'Men',
      'women': 'Women',
      'everyone': 'Everyone',
      
      // Interests
      'your_interests': 'Your Interests',
      'auto_detected': 'Here are your automatically detected interests',
      'detected_from_tiktok': 'Automatically detected from TikTok 🎵',
      'select_interests': 'Select between 4 and 8 interests',
      'min_interests': 'You must have at least 4 interests',
      'max_interests': 'Maximum 8 interests',
      'add_interest': 'Add an interest',
      
      // Photos
      'your_photos': 'Your Photos',
      'add_photos_desc': 'Add at least 2 photos to continue',
      'add_photo': 'Add a photo',
      'add_caption': 'Add caption',
      'edit_caption': 'Edit',
      'in_my': 'In my...',
      
      // Prompts
      'your_prompts': 'Your Prompts',
      'add_prompts_desc': 'Add at least 2 prompts to stand out',
      'add_prompt': 'Add a prompt',
      'select_prompt': 'Select a prompt',
      'your_answer': 'Your answer...',
      
      // Home Screen
      'discover': 'Discover',
      'no_more_profiles': 'No more profiles for now',
      'check_back_later': 'Check back later!',
      'compatible': 'compatible',
      
      // Matches Screen
      'matches': 'Matches',
      'new_matches': 'New Matches',
      'messages': 'Messages',
      'no_matches': 'No matches yet',
      'start_swiping': 'Start swiping!',
      'you_matched': 'You matched!',
      'send_message': 'Send a message',
      'keep_swiping': 'Keep swiping',
      
      // Likes Screen
      'likes': 'Likes',
      'people_who_liked': 'People who liked you',
      'no_likes': 'Nobody liked you yet',
      'be_patient': 'Be patient!',
      'liked_you': 'liked you',
      
      // Profile Screen
      'my_profile': 'My Profile',
      'about': 'About',
      'interests': 'Interests',
      'preferences': 'Preferences',
      'i_am': 'I am',
      'i_look_for': 'Looking for',
      'edit_profile': 'Edit Profile',
      'logout': 'Log out',
      'upgrade_premium': 'Upgrade to Premium',
      'unlock_features': 'Unlock all features',
      'buy_superlikes': 'Buy Superlikes',
      'free_per_week': '1 free per week',
      'stand_out': 'Stand out to your crushes',
      
      // Edit Profile
      'edit_my_profile': 'Edit Profile',
      'save': 'Save',
      'photos': 'Photos',
      'edit_photos': 'Edit my photos',
      'prompts': 'Prompts',
      'edit_prompts': 'Edit my prompts',
      'tell_about_you': 'Tell us about yourself...',
      'profile_updated': 'Profile updated!',
      
      // Settings
      'settings': 'Settings',
      'account': 'Account',
      'pause_profile': 'Pause',
      'hide_profile_temp': 'Hide my profile temporarily',
      'profile_paused': 'Profile paused',
      'profile_reactivated': 'Profile reactivated',
      'notifications': 'Notifications',
      'enable_notifications': 'Enable notifications',
      'receive_all': 'Receive all notifications',
      'new_matches_notif': 'New matches',
      'notified_matches': 'Be notified of new matches',
      'messages_notif': 'Messages',
      'notified_messages': 'Be notified of new messages',
      'language': 'Language',
      'app_language': 'App Language',
      'language_changed': 'Language changed to',
      'privacy': 'Privacy',
      'manage_data': 'Manage my data',
      'blocked_users': 'Blocked users',
      'manage_blocked': 'Manage blocked users',
      'about_app': 'About',
      'terms_of_use': 'Terms of Use',
      'help_center': 'Help Center',
      'coming_soon': 'Coming soon',
      
      // Premium
      'toker_premium': 'Toker Premium',
      'unlimited_likes': 'Unlimited Likes',
      'swipe_unlimited': 'Swipe without limits',
      'unlimited_superlikes': 'Unlimited Superlikes',
      'invisible_mode': 'Invisible Mode',
      'browse_discreet': 'Browse discreetly',
      'rewind': 'Rewind',
      'undo_swipes': 'Undo your last swipes',
      'advanced_location': 'Advanced Location',
      'change_location': 'Change your location',
      'advanced_filters': 'Advanced Filters',
      'refine_search': 'Refine your searches',
      'choose_plan': 'Choose your plan',
      'week': 'week',
      'month': 'month',
      'months': 'months',
      'save': 'Save',
      'popular': 'POPULAR',
      'auto_renew': 'Auto-renewing subscription. Cancel anytime.',
      
      // Superlikes
      'buy_superlikes_title': 'Buy Superlikes',
      'superlikes_5': '5 Superlikes',
      'superlikes_10': '10 Superlikes',
      'superlikes_25': '25 Superlikes',
      'purchase_for': 'Purchase of',
      'for': 'for',
      
      // Chat
      'write_message': 'Write a message...',
      'no_messages': 'No messages',
      'today': 'Today',
      'yesterday': 'Yesterday',
      
      // Common
      'close': 'Close',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'error': 'Error',
      'success': 'Success',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
  
  String get welcomeToToker => translate('welcome_to_toker');
  String get findLoveTiktok => translate('find_love_tiktok');
  // ... (on peut ajouter des getters pour chaque clé si besoin)
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
