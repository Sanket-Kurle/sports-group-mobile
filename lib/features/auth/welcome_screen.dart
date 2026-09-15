import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.forest,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.sports_cricket_rounded,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(width: 11),
                const Text(
                  'playly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                height: 245,
                width: 285,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .06),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .1),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -.12,
                      child: Container(
                        width: 170,
                        height: 210,
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          size: 96,
                          color: AppColors.forest,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 35,
                      child: _Bubble(
                        icon: Icons.check_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 34,
                      child: _Bubble(
                        icon: Icons.currency_rupee_rounded,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your game.\nYour group.\nAll sorted.',
              style: TextStyle(
                fontSize: 40,
                height: 1.02,
                letterSpacing: -1.8,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Plan sessions, track attendance and keep every rupee transparent.',
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: Colors.white.withValues(alpha: .7),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: AppColors.forest,
                minimumSize: const Size.fromHeight(58),
              ),
              onPressed: () => _showLogin(context),
              child: const Text('Get started'),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: .48),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _showLogin(BuildContext context) {
    final phone = TextEditingController(text: '98765 43210');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          4,
          24,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Playly',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your phone number to continue. We’ll send a one-time code.',
            ),
            const SizedBox(height: 22),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixText: '+91  ',
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                context.go('/home');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue securely'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Demo mode · OTP is bypassed',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
      ],
    ),
    child: Icon(icon, color: AppColors.forest, size: 29),
  );
}
