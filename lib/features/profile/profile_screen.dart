import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        AppCard(
          child: Row(
            children: [
              const AvatarInitials('SK', size: 66),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sanket Kurle',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '+91 98765 43210',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 7),
                    const StatusPill(
                      'Phone verified',
                      icon: Icons.verified_rounded,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    showAppSnackBar(context, 'Profile editor opened'),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Label('YOUR GROUPS'),
        const SizedBox(height: 8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF4EE),
                  child: Text('🏏'),
                ),
                title: const Text(
                  'Weekend Warriors',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Owner · Admin · Treasurer'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
              const Divider(height: 1, indent: 72),
              const ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFE8EFF9),
                  child: Text('⚽'),
                ),
                title: Text(
                  'Tuesday Turf',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('Member'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Label('PREFERENCES'),
        const SizedBox(height: 8),
        const AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                value: 'On',
              ),
              Divider(height: 1, indent: 70),
              _SettingTile(
                icon: Icons.language_rounded,
                title: 'Language',
                value: 'English',
              ),
              Divider(height: 1, indent: 70),
              _SettingTile(
                icon: Icons.shield_outlined,
                title: 'Privacy & security',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Label('SUPPORT'),
        const SizedBox(height: 8),
        const AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & FAQs',
              ),
              Divider(height: 1, indent: 70),
              _SettingTile(
                icon: Icons.description_outlined,
                title: 'Terms & privacy',
              ),
              Divider(height: 1, indent: 70),
              _SettingTile(
                icon: Icons.info_outline_rounded,
                title: 'About Playly',
                value: 'v1.0.0',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: () => context.go('/welcome'),
          icon: const Icon(Icons.logout_rounded, color: AppColors.red),
          label: const Text('Log out', style: TextStyle(color: AppColors.red)),
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'Made for the games that bring us together.',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.1,
      color: AppColors.muted,
    ),
  );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, this.value});
  final IconData icon;
  final String title;
  final String? value;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    leading: Icon(icon, color: AppColors.green),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null)
          Text(
            value!,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      ],
    ),
  );
}
