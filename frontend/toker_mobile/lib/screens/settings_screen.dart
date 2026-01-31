import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/localization_helper.dart';
import '../services/language_service.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPaused = false;
  bool _notificationsEnabled = true;
  bool _matchNotifications = true;
  bool _messageNotifications = true;

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('settings'),
          style: const TextStyle(
            color: AppColors.cream,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionTitle(context.tr('account')),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.pause_circle_outline,
              title: context.tr('pause_profile'),
              subtitle: context.tr('hide_profile_temp'),
              value: _isPaused,
              onChanged: (value) {
                setState(() => _isPaused = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? context.tr('profile_paused') : context.tr('profile_reactivated')),
                    backgroundColor: AppColors.neonTeal,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Notifications Section
            _buildSectionTitle(context.tr('notifications')),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: context.tr('enable_notifications'),
              subtitle: context.tr('receive_all'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                  if (!value) {
                    _matchNotifications = false;
                    _messageNotifications = false;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.favorite_outline,
              title: context.tr('new_matches_notif'),
              subtitle: context.tr('notified_matches'),
              value: _matchNotifications,
              enabled: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _matchNotifications = value);
              },
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.message_outlined,
              title: context.tr('messages_notif'),
              subtitle: context.tr('notified_messages'),
              value: _messageNotifications,
              enabled: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _messageNotifications = value);
              },
            ),
            const SizedBox(height: 24),
            
            // Language Section
            _buildSectionTitle(context.tr('language')),
            const SizedBox(height: 12),
            _buildLanguageTile(languageService),
            const SizedBox(height: 24),
            
            // Privacy Section
            _buildSectionTitle(context.tr('privacy')),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: context.tr('privacy'),
              subtitle: context.tr('manage_data'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('coming_soon')),
                    backgroundColor: AppColors.neonTeal,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.block_outlined,
              title: context.tr('blocked_users'),
              subtitle: context.tr('manage_blocked'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('coming_soon')),
                    backgroundColor: AppColors.neonTeal,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // About Section
            _buildSectionTitle(context.tr('about_app')),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: context.tr('terms_of_use'),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: context.tr('privacy_policy'),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: context.tr('help_center'),
              onTap: () {},
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.cream,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled ? AppColors.neonTeal : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppColors.cream : AppColors.textSecondary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.neonTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(LanguageService languageService) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.cardBackground,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (modalContext) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  context.tr('app_language'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(languageService, 'fr', 'Français'),
                _buildLanguageOption(languageService, 'en', 'English'),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.language, color: AppColors.neonTeal, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('app_language'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    languageService.currentLanguageName,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(LanguageService languageService, String code, String name) {
    final isSelected = languageService.currentLocale.languageCode == code;
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          color: isSelected ? AppColors.neonTeal : AppColors.cream,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.neonTeal)
          : null,
      onTap: () async {
        await languageService.changeLanguage(code);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.tr('language_changed')} $name'),
              backgroundColor: AppColors.neonTeal,
            ),
          );
        }
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neonTeal, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
