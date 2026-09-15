import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../data/demo_data.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key});
  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  var _query = '';
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final group = state.selectedGroup;
    final members = demoMembers
        .where(
          (member) => member.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const GroupSwitcher(),
        actions: [
          if (state.canManageSessions)
            IconButton(
              onPressed: () => _showSettings(context),
              icon: const Icon(Icons.settings_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text('Group', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          group.emoji,
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${group.sport} · Mumbai · ${group.memberCount} members',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, color: AppColors.lime),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invite code',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'PLAY-WW24',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: 'PLAY-WW24'),
                          );
                          showAppSnackBar(context, 'Invite code copied');
                        },
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => context.go('/group/chat'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.forum_rounded,
                        color: AppColors.forest,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Group chat',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Rohan: Two spots still open.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const StatusPill('3 new'),
                    const SizedBox(width: 5),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '${group.memberCount}',
                  label: 'Members',
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _MiniStat(value: '24', label: 'Sessions'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(value: money(11280), label: 'This season'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Members',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (state.canManageSessions)
                TextButton.icon(
                  onPressed: () => _showInvite(context),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Invite'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search members',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < members.length; i++)
                  Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        leading: AvatarInitials(members[i].initials, index: i),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                members[i].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (members[i].isYou)
                              const Text(
                                '  (you)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (final role in members[i].roles)
                                _RoleChip(role: role),
                            ],
                          ),
                        ),
                        trailing: state.canManageSessions && !members[i].isYou
                            ? const Icon(
                                Icons.more_vert_rounded,
                                color: AppColors.muted,
                              )
                            : Text(
                                money(members[i].balance, signed: true),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: members[i].balance >= 0
                                      ? AppColors.green
                                      : AppColors.red,
                                ),
                              ),
                      ),
                      if (i < members.length - 1)
                        const Divider(height: 1, indent: 72),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Group activity'),
          const SizedBox(height: 9),
          const AppCard(
            child: Column(
              children: [
                _AuditRow(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Treasurer role assigned',
                  detail: 'Sanket assigned Rohan · 8 Sep',
                ),
                Divider(height: 24),
                _AuditRow(
                  icon: Icons.lock_outline_rounded,
                  title: 'Attendance locked',
                  detail: 'Aarav · Monsoon Cup Practice · 6 Sep',
                ),
                Divider(height: 24),
                _AuditRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Settlement confirmed',
                  detail: 'Rohan · ₹3,360 · 30 Aug',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInvite(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.group_add_rounded,
              size: 54,
              color: AppColors.green,
            ),
            const SizedBox(height: 12),
            Text(
              'Grow the squad',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 7),
            const Text(
              'Share the private invite code PLAY-WW24 with people you trust.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'PLAY-WW24'));
                Navigator.pop(context);
                showAppSnackBar(context, 'Invite code copied');
              },
              child: const Center(child: Text('Copy invite code')),
            ),
          ],
        ),
      ),
    ),
  );

  void _showSettings(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit group details'),
            ),
            ListTile(
              leading: const Icon(Icons.currency_rupee_rounded),
              title: const Text('Currency'),
              trailing: const Text('INR · locked'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule_rounded),
              title: const Text('Default session duration'),
              trailing: const Text('2 hr'),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive group'),
              subtitle: const Text('Financial history will be retained'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 10),
        ),
      ],
    ),
  );
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final GroupRole role;
  @override
  Widget build(BuildContext context) {
    final label = role.name[0].toUpperCase() + role.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: role == GroupRole.member
            ? AppColors.canvas
            : AppColors.lime.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        backgroundColor: AppColors.canvas,
        child: Icon(icon, size: 19, color: AppColors.green),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              detail,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    ],
  );
}
