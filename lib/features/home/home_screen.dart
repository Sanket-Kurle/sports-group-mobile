import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../data/demo_data.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final sessions = ref.watch(selectedGroupSessionsProvider);
    final upcoming = sessions
        .where(
          (item) =>
              item.startsAt.isAfter(DateTime.now()) &&
              item.status != SessionStatus.cancelled,
        )
        .toList()
        .reversed
        .toList();
    final next = upcoming.isEmpty ? null : upcoming.first;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(state: state)),
          SliverToBoxAdapter(
            child: PagePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (next != null) _UpcomingCard(session: next),
                  const SizedBox(height: 24),
                  const SectionTitle('At a glance'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: state.selectedGroup.balance >= 0
                              ? 'Available'
                              : 'You owe',
                          value: money(state.selectedGroup.balance.abs()),
                          tone: state.selectedGroup.balance >= 0
                              ? AppColors.green
                              : AppColors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.event_available_rounded,
                          label: 'Sessions played',
                          value: state.selectedGroupId == 'weekend'
                              ? '18'
                              : '6',
                          tone: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                  if (state.canManageFinance &&
                      state.payments
                          .where(
                            (item) =>
                                item.groupId == state.selectedGroupId &&
                                item.status == PaymentStatus.pending,
                          )
                          .isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SectionTitle(
                      'Needs your attention',
                      action: 'Review',
                      onTap: () => context.go('/finance'),
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      color: const Color(0xFFFFF8EB),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Color(0xFF9A5B17),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '2 payment approvals',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '₹1,500 waiting to be reviewed',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const SectionTitle('Recent activity'),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < demoActivities.length; i++)
                          _ActivityRow(
                            activity: demoActivities[i],
                            showDivider: i != demoActivities.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: EdgeInsets.fromLTRB(
      20,
      MediaQuery.paddingOf(context).top + 14,
      20,
      26,
    ),
    decoration: const BoxDecoration(
      color: AppColors.forest,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: GroupSwitcher(dark: true)),
            Badge(
              isLabelVisible: state.notificationCount > 0,
              label: Text('${state.notificationCount}'),
              child: IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .1),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ref.read(appControllerProvider.notifier).clearNotifications();
                  showAppSnackBar(context, 'You’re all caught up');
                },
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          'Good morning, Sanket',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .67),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Ready for the next game?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
          ),
        ),
      ],
    ),
  );
}

class _UpcomingCard extends ConsumerWidget {
  const _UpcomingCard({required this.session});
  final SportSession session;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.go('/sessions/${session.id}'),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF176B4D), Color(0xFF24543F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const StatusPill('NEXT UP', color: AppColors.lime),
                    const Spacer(),
                    Text(
                      '${session.inCount}/${session.capacity} in',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  session.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${fullDate.format(session.startsAt)} · ${timeOnly.format(session.startsAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        session.venue,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: session.rsvp == RsvpStatus.none
                ? Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Are you playing?',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      for (final item in [
                        (RsvpStatus.inGame, 'In'),
                        (RsvpStatus.maybe, 'Maybe'),
                        (RsvpStatus.out, 'Out'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ActionChip(
                            label: Text(item.$2),
                            onPressed: () => ref
                                .read(appControllerProvider.notifier)
                                .setRsvp(session.id, item.$1),
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        session.rsvp == RsvpStatus.inGame
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          session.rsvp == RsvpStatus.inGame
                              ? 'You’re in!'
                              : session.rsvp == RsvpStatus.waitlisted
                              ? 'You’re waitlisted'
                              : 'Response saved',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/sessions/${session.id}'),
                        child: const Text('View session'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color tone;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tone.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: tone),
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity, required this.showDivider});
  final ActivityItem activity;
  final bool showDivider;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.canvas,
              child: Text(
                activity.icon,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.detail,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              activity.time,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
      if (showDivider) const Divider(height: 1, indent: 70),
    ],
  );
}
