import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../models/prompt.dart';
import 'onboarding_prompts_screen.dart';

class OnboardingPhotosScreen extends StatefulWidget {
  final Profile profile;
  final bool isEditing;

  const OnboardingPhotosScreen({
    super.key,
    required this.profile,
    this.isEditing = false,
  });

  @override
  State<OnboardingPhotosScreen> createState() => _OnboardingPhotosScreenState();
}

class _OnboardingPhotosScreenState extends State<OnboardingPhotosScreen> {
  final List<String?> _photos = List.filled(6, null); // Initialize with nulls
  final Map<int, String> _photoCaptions = {}; // Changed to simple String
  final int _minPhotos = 2; // Min photos required
  final int _maxPhotos = 6;

  @override
  void initState() {
    super.initState();
    // Initialize photos from profile if editing or if they exist
    for (int i = 0; i < widget.profile.photos.length && i < _maxPhotos; i++) {
        _photos[i] = widget.profile.photos[i];
    }
    // Note: handling captions restoration would require parsing them back, skipping for MVP/Stability
  }

  void _addPhoto(int index) {
    setState(() {
      // For MVP, use placeholder images with valid IDs (1-70)
      final photoId = (DateTime.now().millisecondsSinceEpoch + index) % 70 + 1;
      _photos[index] = 'https://i.pravatar.cc/400?img=$photoId';
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos[index] = null;
      _photoCaptions.remove(index); // Remove caption if photo is removed
    });
  }

  void _addCaption(int photoIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: Supabase.instance.client
                        .from('prompts')
                        .select('question')
                        .eq('category', 'photoCaption')
                        .order('question', ascending: true),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.neonTeal));
                      }
                      
                      final captions = snapshot.data!;
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: captions.length,
                        itemBuilder: (context, index) {
                          final text = captions[index]['question'] as String;
                          return _buildCaptionOption(photoIndex, text);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptionOption(int index, String text) {
    return ListTile(
      title: Text(
        text,
        style: const TextStyle(color: AppColors.cream, fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
      onTap: () {
        setState(() {
          _photoCaptions[index] = text;
        });
        Navigator.pop(context);
      },
    );
  } 

  int get _photoCount => _photos.where((p) => p != null).length;

  void _continue() {
    final selectedPhotos = _photos.where((p) => p != null).cast<String>().toList();
    
    // Convert photo captions to the format expected by Profile
    final Map<int, String> captionsMap = {};
    _photoCaptions.forEach((index, caption) {
      if (caption.isNotEmpty) {
        // Find the actual index in the selectedPhotos list
        int actualIndex = 0;
        for (int i = 0; i <= index; i++) {
          if (_photos[i] != null) {
            if (i == index) break;
            actualIndex++;
          }
        }
        captionsMap[actualIndex] = caption;
      }
    });
    
    final updatedProfile = widget.profile.copyWith(
      photos: selectedPhotos,
      photoCaptions: captionsMap,
    );

    if (widget.isEditing) {
      Navigator.pop(context, updatedProfile);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingPromptsScreen(profile: updatedProfile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajoute tes photos',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum $_minPhotos photos, maximum $_maxPhotos',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.neonTeal.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.neonTeal, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap sur une photo pour ajouter une légende (optionnel)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cream.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Photo grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _maxPhotos,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    final hasPhoto = photo != null;
                    final hasCaption = _photoCaptions.containsKey(index);

                    return GestureDetector(
                      onTap: () {
                        if (hasPhoto) {
                          // Show options: add caption or remove photo
                          _showPhotoOptions(index);
                        } else {
                          _addPhoto(index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: hasPhoto ? null : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasPhoto 
                                ? AppColors.neonTeal 
                                : AppColors.textSecondary.withOpacity(0.3),
                            width: hasPhoto ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            if (hasPhoto)
                              Positioned.fill(
                                child: Image.network(
                                  photo!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.cardBackground,
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: AppColors.textSecondary),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (!hasPhoto)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      color: AppColors.textSecondary.withOpacity(0.5),
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      index < _minPhotos ? 'Photo ${index + 1}*' : 'Photo ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Subtle hint overlay for photos with captions
                            if (hasPhoto && hasCaption)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            // Caption indicator badge (like Hinge)
                            if (hasPhoto && hasCaption)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.neonTeal,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble,
                                        color: AppColors.neonTeal,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _photoCaptions[index]!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // "Tap to edit/add caption" hint for ALL photos
                            if (hasPhoto)
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        hasCaption ? Icons.edit : Icons.add_comment,
                                        color: AppColors.neonTeal,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasCaption ? 'Modifier' : 'Ajouter légende',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (index < _minPhotos && !hasPhoto)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Requis',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Count
              Center(
                child: Text(
                  '$_photoCount/$_maxPhotos photos ajoutées',
                  style: TextStyle(
                    fontSize: 14,
                    color: _photoCount >= _minPhotos 
                        ? AppColors.neonTeal 
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _photoCount >= _minPhotos ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                    foregroundColor: AppColors.cream,
                    disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final hasCaption = _photoCaptions.containsKey(index);
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  hasCaption ? Icons.edit : Icons.add_comment,
                  color: AppColors.neonTeal,
                ),
                title: Text(
                  hasCaption ? 'Modifier la légende' : 'Ajouter une légende',
                  style: const TextStyle(color: AppColors.cream),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addCaption(index);
                },
              ),
              if (hasCaption)
                ListTile(
                  leading: const Icon(Icons.remove_circle, color: AppColors.neonRed),
                  title: const Text(
                    'Retirer la légende',
                    style: TextStyle(color: AppColors.cream),
                  ),
                  onTap: () {
                    setState(() {
                      _photoCaptions.remove(index);
                    });
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.neonRed),
                title: const Text(
                  'Supprimer la photo',
                  style: TextStyle(color: AppColors.cream),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Photo Caption Selector
class _PhotoCaptionSelector extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> usedQuestions;
  final Function(Prompt) onSelected;
  final VoidCallback onRemove;
  final bool hasCaption;

  const _PhotoCaptionSelector({
    required this.scrollController,
    required this.usedQuestions,
    required this.onSelected,
    required this.onRemove,
    required this.hasCaption,
  });

  @override
  State<_PhotoCaptionSelector> createState() => _PhotoCaptionSelectorState();
}

class _PhotoCaptionSelectorState extends State<_PhotoCaptionSelector> {
  String? _selectedQuestion;
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedQuestion != null && _answerController.text.trim().isNotEmpty) {
      widget.onSelected(Prompt(
        question: _selectedQuestion!,
        answer: _answerController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoCaptionQuestions = Prompt.photoCaptionPrompts
        .where((q) => !widget.usedQuestions.contains(q))
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ajoute une légende',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cream,
                  ),
                ),
              ),
              if (widget.hasCaption)
                TextButton.icon(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete, color: AppColors.neonRed, size: 18),
                  label: const Text(
                    'Retirer',
                    style: TextStyle(color: AppColors.neonRed),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisis une question pour ta photo (optionnel)',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Questions list
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: photoCaptionQuestions.length,
              itemBuilder: (context, index) {
                final question = photoCaptionQuestions[index];
                final isSelected = _selectedQuestion == question;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedQuestion = question;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.neonTeal.withOpacity(0.2)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.neonTeal 
                            : AppColors.textSecondary.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.neonTeal : AppColors.cream,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Answer input
          if (_selectedQuestion != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Ta réponse',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _answerController,
              maxLines: 2,
              maxLength: 100,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: 'Écris ta réponse...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neonTeal, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neonTeal, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neonTeal, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _answerController.text.trim().isNotEmpty ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Valider',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
