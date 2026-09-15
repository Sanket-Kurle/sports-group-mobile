import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../data/demo_data.dart';
import '../domain/models.dart';
import '../state/app_state.dart';

class PagePadding extends StatelessWidget {
  const PagePadding({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), child: child);
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
    ],
  );
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: Padding(padding: padding, child: child),
  );
}

class GroupSwitcher extends ConsumerWidget {
  const GroupSwitcher({super.key, this.dark = false});
  final bool dark;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appControllerProvider).selectedGroup;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Switch group',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                for (final group in demoGroups)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.canvas,
                      child: Text(group.emoji),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${group.sport} · ${group.memberCount} members',
                    ),
                    trailing: group.id == selected.id
                        ? const Icon(Icons.check_circle, color: AppColors.green)
                        : null,
                    onTap: () {
                      ref
                          .read(appControllerProvider.notifier)
                          .selectGroup(group.id);
                      Navigator.pop(context);
                    },
                  ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Create or join a group'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                selected.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: dark ? Colors.white : AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: dark ? Colors.white70 : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(
    this.label, {
    super.key,
    this.color = AppColors.green,
    this.icon,
  });
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class AvatarInitials extends StatelessWidget {
  const AvatarInitials(
    this.initials, {
    super.key,
    this.size = 42,
    this.index = 0,
  });
  final String initials;
  final double size;
  final int index;
  static const colors = [
    Color(0xFFE2F0DC),
    Color(0xFFF5E4CD),
    Color(0xFFDCE8F6),
    Color(0xFFF1DDE8),
  ];
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    backgroundColor: colors[index % colors.length],
    child: Text(
      initials,
      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
    ),
  );
}

String sessionStatusLabel(SessionStatus status) => switch (status) {
  SessionStatus.draft => 'Draft',
  SessionStatus.open => 'RSVP open',
  SessionStatus.confirmed => 'Confirmed',
  SessionStatus.completed => 'Needs settlement',
  SessionStatus.settled => 'Settled',
  SessionStatus.cancelled => 'Cancelled',
};

Color sessionStatusColor(SessionStatus status) => switch (status) {
  SessionStatus.open => AppColors.green,
  SessionStatus.completed => AppColors.orange,
  SessionStatus.settled => AppColors.blue,
  SessionStatus.cancelled => AppColors.red,
  _ => AppColors.muted,
};

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
