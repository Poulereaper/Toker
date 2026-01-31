import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.cream),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neonTeal.withOpacity(0.3),
                          AppColors.neonRed.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 80,
                      color: AppColors.neonTeal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Toker Premium',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Débloquez toutes les fonctionnalités',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildFeature(
                    icon: Icons.favorite,
                    title: 'Likes illimités',
                    description: 'Swipez sans limite',
                  ),
                  _buildFeature(
                    icon: Icons.star,
                    title: 'Superlikes illimités',
                    description: 'Démarquez-vous auprès de vos coups de cœur',
                  ),
                  _buildFeature(
                    icon: Icons.visibility_off,
                    title: 'Mode invisible',
                    description: 'Naviguez en toute discrétion',
                  ),
                  _buildFeature(
                    icon: Icons.undo,
                    title: 'Retour en arrière',
                    description: 'Annulez vos derniers swipes',
                  ),
                  _buildFeature(
                    icon: Icons.location_on,
                    title: 'Localisation avancée',
                    description: 'Changez votre position',
                  ),
                  _buildFeature(
                    icon: Icons.filter_list,
                    title: 'Filtres avancés',
                    description: 'Affinez vos recherches',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Subscription Plans
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choisissez votre formule',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPlanCard(
                    duration: '1 semaine',
                    price: '9,99 €',
                    pricePerWeek: '9,99 €/semaine',
                    isPopular: false,
                  ),
                  const SizedBox(height: 12),
                  _buildPlanCard(
                    duration: '1 mois',
                    price: '29,99 €',
                    pricePerWeek: '7,50 €/semaine',
                    savings: 'Économisez 25%',
                    isPopular: true,
                  ),
                  const SizedBox(height: 12),
                  _buildPlanCard(
                    duration: '3 mois',
                    price: '69,99 €',
                    pricePerWeek: '5,83 €/semaine',
                    savings: 'Économisez 42%',
                    isPopular: false,
                  ),
                  const SizedBox(height: 12),
                  _buildPlanCard(
                    duration: '6 mois',
                    price: '119,99 €',
                    pricePerWeek: '5,00 €/semaine',
                    savings: 'Économisez 50%',
                    isPopular: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Terms
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Abonnement renouvelé automatiquement. Annulez à tout moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.neonTeal, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String duration,
    required String price,
    required String pricePerWeek,
    String? savings,
    required bool isPopular,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPopular
            ? LinearGradient(
                colors: [
                  AppColors.neonTeal.withOpacity(0.3),
                  AppColors.neonRed.withOpacity(0.3),
                ],
              )
            : null,
        color: isPopular ? null : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppColors.neonTeal : AppColors.textSecondary.withOpacity(0.2),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.neonTeal,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: const Text(
                  'POPULAIRE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pricePerWeek,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                      if (savings != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          savings,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neonTeal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cream,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
