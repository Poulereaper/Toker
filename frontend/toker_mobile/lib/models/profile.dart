import 'prompt.dart';

class Profile {
  final String id;
  final String name;
  final int age;
  final DateTime? birthdate;
  final String gender;
  final String bio;
  final List<String> interests;
  final List<String> photos; // URLs or asset paths (3-6 photos)
  final List<Prompt> prompts; // 1-3 prompts (min 1)
  final Map<int, String> photoCaptions; // Optional captions for photos (index -> caption)
  final String location;
  final String interestedIn; // "Men", "Women", "Everyone"
  final Map<String, double> interestVector; // For NLP matching (future)

  Profile({
    required this.id,
    required this.name,
    required this.age,
    this.birthdate,
    required this.gender,
    required this.bio,
    required this.interests,
    required this.photos,
    this.prompts = const [],
    this.photoCaptions = const {},
    required this.location,
    required this.interestedIn,
    this.interestVector = const {},
  });

  // Get initials for avatar placeholder
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  // Calculate compatibility score (mock for now)
  double calculateCompatibility(Profile other) {
    final commonInterests = interests
        .where((interest) => other.interests.contains(interest))
        .length;
    final totalInterests = (interests.length + other.interests.length) / 2;
    return (commonInterests / totalInterests * 100).clamp(0, 100);
  }

  Profile copyWith({
    String? id,
    String? name,
    int? age,
    DateTime? birthdate,
    String? gender,
    String? bio,
    List<String>? interests,
    List<String>? photos,
    List<Prompt>? prompts,
    Map<int, String>? photoCaptions,
    String? location,
    String? interestedIn,
    Map<String, double>? interestVector,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      prompts: prompts ?? this.prompts,
      photoCaptions: photoCaptions ?? this.photoCaptions,
      location: location ?? this.location,
      interestedIn: interestedIn ?? this.interestedIn,
      interestVector: interestVector ?? this.interestVector,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'birthdate': birthdate?.toIso8601String(),
      'gender': gender,
      'bio': bio,
      'interests': interests,
      'photos': photos,
      'prompts': prompts.map((p) => p.toJson()).toList(),
      'photoCaptions': photoCaptions,
      'location': location,
      'interestedIn': interestedIn,
      'interestVector': interestVector,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      birthdate: json['birthdate'] != null ? DateTime.parse(json['birthdate'] as String) : null,
      gender: json['gender'] as String,
      bio: json['bio'] as String,
      interests: List<String>.from(json['interests'] as List),
      photos: List<String>.from(json['photos'] as List),
      prompts: (json['prompts'] as List? ?? []).map((p) => Prompt.fromJson(p as Map<String, dynamic>)).toList(),
      photoCaptions: Map<int, String>.from(json['photoCaptions'] as Map? ?? {}),
      location: json['location'] as String,
      interestedIn: json['interestedIn'] as String,
      interestVector: Map<String, double>.from(json['interestVector'] as Map? ?? {}),
    );
  }
}
