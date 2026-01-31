import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../models/prompt.dart';
import '../services/mock_data_service.dart';
import 'home_screen.dart';

class OnboardingPromptsScreen extends StatefulWidget {
  final Profile profile;

  const OnboardingPromptsScreen({
    super.key,
    required this.profile,
  });

  @override
  State<OnboardingPromptsScreen> createState() => _OnboardingPromptsScreenState();
}

class _OnboardingPromptsScreenState extends State<OnboardingPromptsScreen> {
  final List<Prompt?> _prompts = List.filled(3, null);
  final int _minPrompts = 1;
  final int _maxPrompts = 3;

  void _selectPrompt(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _PromptSelector(
              scrollController: scrollController,
              usedQuestions: _prompts
                  .where((p) => p != null)
                  .map((p) => p!.question)
                  .toList(),
              onSelected: (prompt) {
                setState(() {
                  _prompts[index] = prompt;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _removePrompt(int index) {
    setState(() {
      _prompts[index] = null;
    });
  }

  int get _promptCount => _prompts.where((p) => p != null).length;

  void _finish() {
    final selectedPrompts = _prompts.where((p) => p != null).cast<Prompt>().toList();
    
    // Update profile with prompts
    final mockService = MockDataService();
    final finalProfile = widget.profile.copyWith(prompts: selectedPrompts);
    mockService.updateCurrentUser(finalProfile);
    
    // Navigate to home
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
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
                'Ajoute tes accroches',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Réponds à $_minPrompts question minimum, $_maxPrompts maximum',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Prompts list
              Expanded(
                child: ListView.builder(
                  itemCount: _maxPrompts,
                  itemBuilder: (context, index) {
                    final prompt = _prompts[index];
                    final hasPrompt = prompt != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _selectPrompt(index),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: hasPrompt 
                                ? AppColors.cardBackground
                                : AppColors.cardBackground.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: hasPrompt 
                                  ? AppColors.neonTeal 
                                  : AppColors.textSecondary.withOpacity(0.3),
                              width: hasPrompt ? 2 : 1,
                            ),
                          ),
                          child: hasPrompt
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            prompt.question,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.neonTeal,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: AppColors.neonRed, size: 20),
                                          onPressed: () => _removePrompt(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      prompt.answer,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.cream,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.textSecondary.withOpacity(0.5),
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            index < _minPrompts 
                                                ? 'Accroche ${index + 1} (requis)'
                                                : 'Accroche ${index + 1} (optionnel)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary.withOpacity(0.7),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap pour choisir une question',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                  '$_promptCount/$_maxPrompts accroches ajoutées',
                  style: TextStyle(
                    fontSize: 14,
                    color: _promptCount >= _minPrompts 
                        ? AppColors.neonTeal 
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Finish button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _promptCount >= _minPrompts ? _finish : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                    foregroundColor: AppColors.cream,
                    disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'C\'est parti !',
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
}

// Prompt Selector with Category Tabs
class _PromptSelector extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> usedQuestions;
  final Function(Prompt) onSelected;

  const _PromptSelector({
    required this.scrollController,
    required this.usedQuestions,
    required this.onSelected,
  });

  @override
  State<_PromptSelector> createState() => _PromptSelectorState();
}

class _PromptSelectorState extends State<_PromptSelector> with SingleTickerProviderStateMixin {
  String? _selectedQuestion;
  final _answerController = TextEditingController();
  late TabController _tabController;
  late List<PromptCategory> _categories;

  @override
  void initState() {
    super.initState();
    // Exclude photoCaption category
    _categories = PromptCategory.values.where((c) => c != PromptCategory.photoCaption).toList();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _answerController.dispose();
    _tabController.dispose();
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
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choisis une question',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 20),
          
          // Category Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.neonTeal,
            indicatorWeight: 3,
            labelColor: AppColors.neonTeal,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            tabs: _categories.map((category) => Tab(text: category.label)).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Questions by category
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final categoryQuestions = Prompt.categorizedQuestions[category] ?? [];
                final availableQuestions = categoryQuestions
                    .where((q) => !widget.usedQuestions.contains(q))
                    .toList();

                return ListView.builder(
                  itemCount: availableQuestions.length,
                  itemBuilder: (context, index) {
                    final question = availableQuestions[index];
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
                );
              }).toList(),
            ),
          ),
          
          // Answer input (shown when question selected)
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
              maxLines: 3,
              maxLength: 150,
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
