import 'dart:math';
import '../models/profile.dart';
import '../models/match.dart';
import '../models/message.dart';
import '../models/prompt.dart';
import '../models/swipe.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Random _random = Random();
  
  // Swipe tracking (in-memory)
  final List<Swipe> _swipes = [];
  
  // In-memory matches
  final List<Match> _matches = [];

  // In-memory messages
  final Map<String, List<Message>> _messages = {};
  
  // Cache for profiles to ensure consistency
  final Map<String, Profile> _profileCache = {};

  // Current user (you)
  Profile? _currentUser;

  Profile get currentUser {
    _currentUser ??= Profile(
      id: 'user_0',
      name: 'Victor',
      age: 22,
      birthdate: DateTime(2002, 5, 15),
      gender: 'Male',
      bio: 'Passionné de tech et de karting 🏎️',
      interests: ['Gaming', 'Tech', 'Voyage', 'Musique', 'Sport'],
      photos: _generatePhotos(3),
      prompts: [
        Prompt(
          question: 'Dans mon groupe d\'amis je suis...',
          answer: 'Celui qui organise toujours les sorties',
        ),
        Prompt(
          question: 'Ma passion secrète c\'est...',
          answer: 'Le karting et la F1 🏎️',
        ),
      ],
      location: 'Paris, France',
      interestedIn: 'Women',
    );
    return _currentUser!;
  }
  
  // Update current user profile
  void updateCurrentUser(Profile profile) {
    _currentUser = profile;
  }

  // Available interests (~100 items)
  final List<String> _allInterests = [
    // Sports & Fitness
    'Gaming', 'Sport', 'Fitness', 'Yoga', 'Randonnée', 'Course à pied', 'Vélo', 'Natation',
    'Basketball', 'Football', 'Tennis', 'Golf', 'Ski', 'Snowboard', 'Surf', 'Escalade',
    'Boxe', 'Danse', 'Pilates', 'Crossfit',
    
    // Arts & Culture
    'Art', 'Photographie', 'Musique', 'Cinéma', 'Concerts', 'Théâtre', 'Musées', 'Lecture',
    'Écriture', 'Poésie', 'Peinture', 'Dessin', 'Sculpture', 'Films', 'Anime', 'Manga',
    'BD', 'Graffiti', 'Design', 'Architecture',
    
    // Food & Drinks
    'Cuisine', 'Pâtisserie', 'Café', 'Vin', 'Cocktails', 'Bière', 'Thé', 'Restaurants',
    'Street Food', 'Vegan', 'Végétarien', 'Gâteaux', 'BBQ', 'Sushi',
    
    // Tech & Innovation
    'Tech', 'Programmation', 'IA', 'Crypto', 'Startups', 'Innovation', 'Gaming PC', 'VR',
    'Robotique', 'Science', 'Espace', 'Astronomie',
    
    // Travel & Adventure
    'Voyage', 'Backpacking', 'Road Trips', 'Camping', 'Aventure', 'Exploration',
    'Plage', 'Montagne', 'City Breaks', 'Festivals',
    
    // Lifestyle & Hobbies
    'Mode', 'Shopping', 'Maquillage', 'Skincare', 'Tattoos', 'Piercings', 'Vintage',
    'Friperie', 'DIY', 'Jardinage', 'Décoration', 'Animaux', 'Chiens', 'Chats',
    
    // Entertainment
    'Netflix', 'Séries', 'Télé-réalité', 'Podcasts', 'Stand-up', 'Karaoké', 'Jeux de société',
    'Escape Game', 'Bowling', 'Billard', 'Karting', 'Laser Game',
    
    // Music Genres
    'Rock', 'Pop', 'Hip-Hop', 'Rap', 'Jazz', 'Blues', 'Électro', 'House', 'Techno',
    'R&B', 'Soul', 'Reggae', 'Metal', 'Indie', 'Folk', 'Classique',
    
    // Misc
    'Méditation', 'Spiritualité', 'Astrologie', 'Psychologie', 'Philosophie', 'Histoire',
    'Politique', 'Activisme', 'Bénévolat', 'Développement durable', 'Écologie',
  ];

  // Mock names - Female
  final List<String> _femaleFirstNames = [
    'Emma', 'Léa', 'Chloé', 'Manon', 'Sarah',
    'Julie', 'Camille', 'Marie', 'Laura', 'Clara',
    'Sophie', 'Alice', 'Lucie', 'Inès', 'Jade',
    'Lisa', 'Eva', 'Nina', 'Zoé', 'Anna',
  ];
  
  // Mock names - Male
  final List<String> _maleFirstNames = [
    'Lucas', 'Hugo', 'Louis', 'Jules', 'Gabriel',
    'Arthur', 'Raphaël', 'Paul', 'Alexandre', 'Tom',
    'Nathan', 'Maxime', 'Antoine', 'Pierre', 'Thomas',
    'Nicolas', 'Julien', 'Baptiste', 'Mathis', 'Léo',
  ];

  final List<String> _lastNames = [
    'Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert',
    'Richard', 'Petit', 'Durand', 'Leroy', 'Moreau',
    'Simon', 'Laurent', 'Lefebvre', 'Michel', 'Garcia',
    'David', 'Bertrand', 'Roux', 'Vincent', 'Fournier',
  ];

  // Bios - Female
  final List<String> _femaleBios = [
    'Amoureuse de voyages et de nouvelles aventures ✈️',
    'Passionnée de musique et de concerts 🎵',
    'Toujours partante pour une soirée gaming 🎮',
    'Addict au café et aux longues discussions ☕',
    'Fan de sport et de vie active 🏃‍♀️',
    'Créative dans l\'âme, photographe à mes heures perdues 📸',
    'Foodie qui adore découvrir de nouveaux restaurants 🍕',
    'Lectrice compulsive et amatrice de séries 📚',
    'Yoga le matin, vin le soir 🧘‍♀️🍷',
    'Toujours en quête de la prochaine randonnée 🏔️',
  ];
  
  // Bios - Male
  final List<String> _maleBios = [
    'Amoureux de voyages et de nouvelles aventures ✈️',
    'Passionné de musique et de concerts 🎵',
    'Toujours partant pour une soirée gaming 🎮',
    'Addict au café et aux longues discussions ☕',
    'Fan de sport et de vie active 🏃‍♂️',
    'Créatif dans l\'âme, photographe à mes heures perdues 📸',
    'Foodie qui adore découvrir de nouveaux restaurants 🍕',
    'Lecteur compulsif et amateur de séries 📚',
    'Sport le matin, bière le soir 🏋️‍♂️🍺',
    'Toujours en quête de la prochaine randonnée 🏔️',
    'Technophile et curieux de tout 🤓',
  ];

  final List<String> _cities = [
    'Paris',
    'Lyon',
    'Marseille',
    'Toulouse',
    'Nice',
    'Nantes',
    'Bordeaux',
    'Lille',
    'Strasbourg',
    'Rennes',
  ];

  // Generate fake profiles
  List<Profile> generateProfiles({int count = 20, String? genderFilter}) {
    // Use current user's preference if no filter specified
    final filter = genderFilter ?? currentUser.interestedIn;
    
    // Determine which genders to generate
    List<String> allowedGenders;
    if (filter == 'Women') {
      allowedGenders = ['Female'];
    } else if (filter == 'Men') {
      allowedGenders = ['Male'];
    } else {
      // 'Everyone' or any other value
      allowedGenders = ['Female', 'Male', 'Non-binary'];
    }
    
    print('🎯 Gender filter: "$filter" → Allowed genders: $allowedGenders');
    
    return List.generate(count, (index) {
      // Select gender from allowed list
      final gender = allowedGenders[_random.nextInt(allowedGenders.length)];
      
      // Select appropriate first name based on gender
      final firstName = gender == 'Male'
          ? _maleFirstNames[_random.nextInt(_maleFirstNames.length)]
          : _femaleFirstNames[_random.nextInt(_femaleFirstNames.length)];
      
      final lastName = _lastNames[_random.nextInt(_lastNames.length)];
      final age = 20 + _random.nextInt(15); // 20-34 years old
      final birthYear = DateTime.now().year - age;
      
      // Random 5-7 interests (auto-detected)
      final interestCount = 5 + _random.nextInt(3);
      final interests = <String>[];
      while (interests.length < interestCount) {
        final interest = _allInterests[_random.nextInt(_allInterests.length)];
        if (!interests.contains(interest)) {
          interests.add(interest);
        }
      }

      // Generate 3-6 photos
      final photoCount = 3 + _random.nextInt(4);
      
      // Determine interestedIn based on gender (for realism)
      String interestedIn;
      if (gender == 'Non-binary') {
        interestedIn = 'Everyone';
      } else {
        final options = ['Women', 'Men', 'Everyone'];
        interestedIn = options[_random.nextInt(options.length)];
      }
      
      // Select appropriate bio based on gender
      final bio = gender == 'Male'
          ? _maleBios[_random.nextInt(_maleBios.length)]
          : _femaleBios[_random.nextInt(_femaleBios.length)];

      final profile = Profile(
        id: 'profile_$index',
        name: '$firstName $lastName',
        age: age,
        birthdate: DateTime(birthYear, _random.nextInt(12) + 1, _random.nextInt(28) + 1),
        gender: gender,
        bio: bio,
        interests: interests,
        photos: _generatePhotos(photoCount),
        prompts: _generatePrompts(),
        location: '${_cities[_random.nextInt(_cities.length)]}, France',
        interestedIn: interestedIn,
      );
      
      _profileCache[profile.id] = profile;
      return profile;
    });
  }

  // Get display profiles for a user
  List<Profile> getDisplayProfiles(String userId) {
    // Return generated profiles for discovery
    return generateProfiles(count: 20);
  }

  // Get a single profile by ID
  Profile getProfile(String id) {
    if (id == currentUser.id) return currentUser;
    
    if (_profileCache.containsKey(id)) {
      return _profileCache[id]!;
    }
    
    // If not in cache, generate a random one with this ID
    // mirroring the logic in generateProfiles but for a single item
    // For simplicity in mock, just generate one and assign ID
    final profile = generateProfiles(count: 1)[0];
    // Create a copy with the requested ID
    final newProfile = Profile(
      id: id,
      name: profile.name,
      age: profile.age,
      birthdate: profile.birthdate,
      gender: profile.gender,
      bio: profile.bio,
      interests: profile.interests,
      photos: profile.photos,
      prompts: profile.prompts,
      location: profile.location,
      interestedIn: profile.interestedIn,
    );
    _profileCache[id] = newProfile;
    return newProfile;
  }
  
  // Getter for matches
  List<Match> get matches {
    if (_matches.isEmpty) {
      _matches.addAll(generateMatches(count: 5));
    }
    return _matches;
  }
  
  // Get messages for a match
  List<Message> getMessagesForMatch(String matchId) {
    if (!_messages.containsKey(matchId)) {
      // Find the match to get the other user ID
      final matchIndex = _matches.indexWhere((m) => m.id == matchId);
      String otherUserId = 'unknown_user';
      if (matchIndex != -1) {
        otherUserId = _matches[matchIndex].profile.id;
      }
      
      _messages[matchId] = generateConversation(matchId, otherUserId);
    }
    return _messages[matchId]!;
  }
  
  // Add a message
  void addMessage(String matchId, Message message) {
    if (!_messages.containsKey(matchId)) {
      _messages[matchId] = [];
    }
    _messages[matchId]!.add(message);
    
    // Update match last message
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      final oldMatch = _matches[index];
      _matches[index] = Match(
        id: oldMatch.id,
        profile: oldMatch.profile,
        matchedAt: oldMatch.matchedAt,
        compatibilityScore: oldMatch.compatibilityScore,
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
        isUnread: false,
      );
      // Re-sort matches
       _matches.sort((a, b) => (b.lastMessageTime ?? b.matchedAt)
          .compareTo(a.lastMessageTime ?? a.matchedAt));
    }
  }

  // Generate matches with compatibility scores
  List<Match> generateMatches({int count = 8}) {
    final profiles = generateProfiles(count: count);
    return profiles.map((profile) {
      final compatibilityScore = currentUser.calculateCompatibility(profile);
      final daysAgo = _random.nextInt(14); // 0-14 days ago
      
      return Match(
        id: 'match_${profile.id}',
        profile: profile,
        matchedAt: DateTime.now().subtract(Duration(days: daysAgo)),
        compatibilityScore: compatibilityScore,
        lastMessage: _random.nextBool() ? _getRandomMessage() : null,
        lastMessageTime: _random.nextBool() 
            ? DateTime.now().subtract(Duration(hours: _random.nextInt(48)))
            : null,
        isUnread: _random.nextBool(),
      );
    }).toList()
      ..sort((a, b) => (b.lastMessageTime ?? b.matchedAt)
          .compareTo(a.lastMessageTime ?? a.matchedAt));
  }

  // Generate conversation messages
  List<Message> generateConversation(String matchId, String otherUserId) {
    final messageCount = 10 + _random.nextInt(20);
    final messages = <Message>[];
    
    for (int i = 0; i < messageCount; i++) {
      final isSentByMe = _random.nextBool();
      messages.add(Message(
        id: 'msg_${matchId}_$i',
        senderId: isSentByMe ? currentUser.id : otherUserId,
        receiverId: isSentByMe ? otherUserId : currentUser.id,
        content: _getRandomMessage(),
        timestamp: DateTime.now().subtract(Duration(
          days: messageCount - i,
          hours: _random.nextInt(24),
        )),
        isRead: true,
      ));
    }
    
    return messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  String _getRandomMessage() {
    final messages = [
      'Salut ! Comment ça va ?',
      'Ça te dit d\'aller prendre un café ?',
      'J\'ai vu qu\'on avait des goûts en commun !',
      'Tu fais quoi ce week-end ?',
      'Trop cool ton profil !',
      'Tu connais ce resto ?',
      'On se fait un ciné bientôt ?',
      'J\'adore aussi cette série !',
      'Tu es sur Paris ?',
      'Partant(e) pour une sortie ?',
      'Haha trop drôle !',
      'Oui carrément !',
      'Avec plaisir 😊',
      'Super idée !',
      'Je suis dispo demain',
    ];
    return messages[_random.nextInt(messages.length)];
  }

  // Get all available interests
  List<String> get allInterests => List.from(_allInterests);

  // Generate photos (placeholder URLs)
  List<String> _generatePhotos(int count) {
    final photoCount = count.clamp(3, 6);
    return List.generate(
      photoCount,
      (index) => 'https://i.pravatar.cc/400?img=${_random.nextInt(70)}',
    );
  }

  // Generate prompts for a profile
  List<Prompt> _generatePrompts() {
    final promptCount = 2 + _random.nextInt(2); // 2-3 prompts
    final selectedQuestions = <String>[];
    final prompts = <Prompt>[];

    while (selectedQuestions.length < promptCount) {
      final question = Prompt.availableQuestions[_random.nextInt(Prompt.availableQuestions.length)];
      if (!selectedQuestions.contains(question)) {
        selectedQuestions.add(question);
        prompts.add(Prompt(
          question: question,
          answer: _generatePromptAnswer(question),
        ));
      }
    }

    return prompts;
  }

  // Generate realistic answer for a prompt
  String _generatePromptAnswer(String question) {
    final answers = {
      'Dans mon groupe d\'amis je suis...': [
        'Celui qui fait toujours rire tout le monde',
        'La maman du groupe qui s\'assure que tout le monde rentre bien',
        'L\'aventurier qui propose toujours des trucs fous',
        'Le calme qui écoute et donne des conseils',
      ],
      'Le truc le plus random que j\'adore...': [
        'Regarder des vidéos de gens qui font du pain',
        'Collectionner des cartes postales de villes que je n\'ai jamais visitées',
        'Écouter de la musique classique en faisant le ménage',
        'Les documentaires sur les animaux marins',
      ],
      'On s\'entendra si...': [
        'Tu aimes les débats passionnés sur des sujets inutiles',
        'Tu es partant(e) pour des road trips spontanés',
        'Tu apprécies les soirées jeux de société autant que les sorties',
        'Tu as de l\'humour et tu ne te prends pas au sérieux',
      ],
      'Mon talent caché c\'est...': [
        'Je peux reconnaître n\'importe quelle chanson en 3 secondes',
        'Je fais les meilleures pâtes carbo de Paris',
        'Je peux imiter presque tous les accents français',
        'Je gagne toujours au Monopoly (désolée)',
      ],
      'Je ne peux pas vivre sans...': [
        'Mon café du matin et ma playlist Spotify',
        'Les soirées entre amis et les bonnes séries',
        'Voyager et découvrir de nouveaux endroits',
        'La musique, le sport et les bons restos',
      ],
      'Ma passion secrète c\'est...': [
        'Les escape games et les énigmes',
        'La photographie urbaine',
        'La cuisine fusion asiatique',
        'Les randonnées en montagne',
      ],
      'Le meilleur conseil qu\'on m\'ait donné...': [
        'Fais ce qui te rend heureux, pas ce qu\'on attend de toi',
        'La vie est trop courte pour boire du mauvais vin',
        'Entoure-toi de gens qui te font grandir',
        'N\'aie pas peur de sortir de ta zone de confort',
      ],
      'Ce qui me fait rire à coup sûr...': [
        'Les vidéos de chats qui font n\'importe quoi',
        'Les blagues nulles et les jeux de mots pourris',
        'Les stand-up de Fary et Gad Elmaleh',
        'Les situations gênantes dans les films',
      ],
      'Mon endroit préféré au monde...': [
        'Un petit café caché dans le Marais',
        'La plage au coucher du soleil',
        'N\'importe où en montagne avec une belle vue',
        'Mon canapé avec une bonne série et une pizza',
      ],
      'Si je pouvais dîner avec quelqu\'un...': [
        'Barack Obama pour parler de tout et de rien',
        'Simone de Beauvoir pour débattre philosophie',
        'Anthony Bourdain pour découvrir les meilleurs restos',
        'Mon moi du futur pour savoir si je fais les bons choix',
      ],
      'Ma plus grande fierté...': [
        'Avoir fait le tour de l\'Europe en van',
        'Mon master obtenu avec mention',
        'Avoir couru un marathon',
        'Ma collection de vinyles',
      ],
      'Ce que je cherche chez quelqu\'un...': [
        'De l\'authenticité et de l\'humour',
        'Quelqu\'un de curieux et ouvert d\'esprit',
        'Une personne qui aime l\'aventure',
        'De la bienveillance et de l\'ambition',
      ],
      'Un truc sur moi que personne ne devine...': [
        'Je parle couramment 3 langues',
        'J\'ai vécu 2 ans à l\'étranger',
        'Je suis ceinture noire de judo',
        'J\'ai écrit un roman (jamais publié)',
      ],
      'Ma définition d\'une bonne soirée...': [
        'Un bon resto, une balade et des discussions sans fin',
        'Un apéro entre amis qui se termine à 4h du mat',
        'Netflix, une couverture et de la bonne bouffe',
        'Un concert ou une soirée dansante',
      ],
      'Ce qui me rend unique...': [
        'Mon mélange de folie et de sagesse',
        'Ma capacité à m\'adapter à toutes les situations',
        'Mon optimisme même dans les moments difficiles',
        'Mon amour pour les choses simples de la vie',
      ],
    };

    final possibleAnswers = answers[question] ?? ['Ça dépend des jours !'];
    return possibleAnswers[_random.nextInt(possibleAnswers.length)];
  }

  // Swipe tracking methods
  void recordSwipe(String fromUserId, String toUserId, SwipeAction action) {
    final swipe = Swipe(
      id: 'swipe_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: fromUserId,
      toUserId: toUserId,
      action: action,
      timestamp: DateTime.now(),
    );
    _swipes.add(swipe);
  }

  // Get profiles who liked current user
  List<Profile> getLikesReceived(String userId) {
    final likeSwipes = _swipes.where(
      (swipe) => swipe.toUserId == userId && swipe.isLike,
    ).toList();

    // Generate mock profiles for likes
    if (likeSwipes.isEmpty) {
      // Generate 5-10 fake likes for demo
      final count = 5 + _random.nextInt(6);
      return generateProfiles(count: count);
    }

    return [];
  }

  // Check if two users have matched
  bool hasMatched(String userA, String userB) {
    final aLikedB = _swipes.any(
      (swipe) => swipe.fromUserId == userA && swipe.toUserId == userB && swipe.isLike,
    );
    final bLikedA = _swipes.any(
      (swipe) => swipe.fromUserId == userB && swipe.toUserId == userA && swipe.isLike,
    );
    return aLikedB && bLikedA;
  }

  // Get all swipes by user
  List<Swipe> getSwipesByUser(String userId) {
    return _swipes.where((swipe) => swipe.fromUserId == userId).toList();
  }
}
