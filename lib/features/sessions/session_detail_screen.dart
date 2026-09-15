import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../data/demo_data.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final matches = state.sessions.where((item) => item.id == sessionId);
    if (matches.isEmpty) {
      return const Scaffold(body: Center(child: Text('Session not found')));
    }
    final session = matches.first;
    final isPast = session.startsAt.isBefore(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/sessions'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Session details'),
        actions: [
          if (state.canManageSessions)
            PopupMenuButton(
              itemBuilder: (_) => const [
                PopupMenuItem(child: Text('Edit session')),
                PopupMenuItem(child: Text('Cancel session')),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _Hero(session: session),
          const SizedBox(height: 18),
          if (!isPast && session.status == SessionStatus.open)
            _RsvpPanel(session: session),
          if (!isPast && session.status == SessionStatus.open)
            const SizedBox(height: 18),
          _PeopleCard(session: session),
          const SizedBox(height: 18),
          if (isPast ||
              session.status == SessionStatus.completed ||
              session.status == SessionStatus.settled)
            _AttendanceCard(
              session: session,
              canManage: state.canManageSessions,
            ),
          if (session.status == SessionStatus.completed ||
              session.status == SessionStatus.settled) ...[
            const SizedBox(height: 18),
            _SettlementCard(
              session: session,
              canManage: state.canManageFinance,
            ),
          ],
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 19,
                      color: AppColors.muted,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Session info',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Created by', value: 'Aarav Shah'),
                _InfoRow(
                  label: 'Estimated cost',
                  value: money(session.estimatedCost),
                ),
                const _InfoRow(
                  label: 'RSVP deadline',
                  value: '24 hours before',
                ),
                const _InfoRow(label: 'Session ID', value: '#WW-0920'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.session});
  final SportSession session;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.forest,
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusPill(
          sessionStatusLabel(session.status),
          color: session.status == SessionStatus.open
              ? AppColors.lime
              : Colors.white70,
        ),
        const SizedBox(height: 22),
        Text(
          session.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 15),
        _HeroRow(
          icon: Icons.calendar_today_rounded,
          value:
              '${fullDate.format(session.startsAt)} · ${timeOnly.format(session.startsAt)}',
        ),
        const SizedBox(height: 9),
        _HeroRow(icon: Icons.location_on_outlined, value: session.venue),
      ],
    ),
  );
}

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: Colors.white70),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _RsvpPanel extends ConsumerWidget {
  const _RsvpPanel({required this.session});
  final SportSession session;
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Your RSVP', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            if (session.rsvp != RsvpStatus.none)
              const StatusPill('Saved', icon: Icons.cloud_done_outlined),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Plans change. You can update this until the deadline.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _RsvpButton(
                label: 'In',
                icon: Icons.check_rounded,
                selected: session.rsvp == RsvpStatus.inGame,
                onTap: () => ref
                    .read(appControllerProvider.notifier)
                    .setRsvp(session.id, RsvpStatus.inGame),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RsvpButton(
                label: 'Maybe',
                icon: Icons.help_outline_rounded,
                selected: session.rsvp == RsvpStatus.maybe,
                onTap: () => ref
                    .read(appControllerProvider.notifier)
                    .setRsvp(session.id, RsvpStatus.maybe),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RsvpButton(
                label: 'Out',
                icon: Icons.close_rounded,
                selected: session.rsvp == RsvpStatus.out,
                onTap: () => ref
                    .read(appControllerProvider.notifier)
                    .setRsvp(session.id, RsvpStatus.out),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _RsvpButton extends StatelessWidget {
  const _RsvpButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: selected ? AppColors.green : AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: selected ? Colors.white : AppColors.muted,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PeopleCard extends StatelessWidget {
  const _PeopleCard({required this.session});
  final SportSession session;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Players', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Text(
              '${session.inCount}/${session.capacity}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: session.inCount / session.capacity,
            minHeight: 7,
            color: AppColors.green,
            backgroundColor: AppColors.line,
          ),
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            for (var i = 0; i < 5; i++)
              Align(
                widthFactor: .78,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: AvatarInitials(demoMembers[i].initials, index: i),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              '+${(session.inCount - 5).clamp(0, 99)} more',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        if (session.maybeCount > 0) ...[
          const Divider(height: 28),
          Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 18,
                color: AppColors.orange,
              ),
              const SizedBox(width: 7),
              Text(
                '${session.maybeCount} members said maybe',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.session, required this.canManage});
  final SportSession session;
  final bool canManage;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Actual attendance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            StatusPill(
              session.attendanceLocked ? 'Locked' : 'Open',
              icon: session.attendanceLocked
                  ? Icons.lock_outline_rounded
                  : Icons.lock_open_rounded,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'RSVP and attendance are kept separate. Only chargeable present players enter the default split.',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(
              child: _Count(
                label: 'Present',
                value: '14',
                color: AppColors.green,
              ),
            ),
            const Expanded(
              child: _Count(label: 'Absent', value: '2', color: AppColors.red),
            ),
            const Expanded(
              child: _Count(
                label: 'Not marked',
                value: '0',
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        if (canManage) ...[
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showAppSnackBar(
                context,
                session.attendanceLocked
                    ? 'Reopening requires API authorization and an audit reason'
                    : 'Attendance editor opened',
              ),
              icon: Icon(
                session.attendanceLocked
                    ? Icons.lock_open_rounded
                    : Icons.fact_check_outlined,
              ),
              label: Text(
                session.attendanceLocked ? 'Request reopen' : 'Mark attendance',
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ],
  );
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({required this.session, required this.canManage});
  final SportSession session;
  final bool canManage;
  @override
  Widget build(BuildContext context) {
    final settled = session.status == SessionStatus.settled;
    return AppCard(
      color: settled ? const Color(0xFFEAF4EE) : const Color(0xFFFFF8EB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                settled ? Icons.verified_rounded : Icons.receipt_long_rounded,
                color: settled ? AppColors.green : AppColors.orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  settled ? 'Settlement complete' : 'Ready to settle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Final expenses',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              Text(
                money(session.expenseTotal),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Chargeable players',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              Text('14', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 7),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Share per player',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              Text('₹270', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          if (!settled && canManage) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _showPreview(context),
                child: const Text('Review settlement'),
              ),
            ),
          ],
          if (settled) ...[
            const Divider(height: 25),
            const Row(
              children: [
                Icon(Icons.shield_outlined, size: 17, color: AppColors.green),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Ledger entries created atomically by the API',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showPreview(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settlement preview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 7),
            const Text(
              'The API is the authority for participants, rounding, idempotency, and ledger writes.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            for (var i = 0; i < 4; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AvatarInitials(demoMembers[i].initials, index: i),
                title: Text(demoMembers[i].name),
                trailing: const Text(
                  '₹270',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            const Divider(),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '14 chargeable players',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: Text(
                '₹3,780',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                showAppSnackBar(
                  context,
                  'Demo only — settlement awaits backend connection',
                );
              },
              child: const Center(child: Text('Confirm atomic settlement')),
            ),
          ],
        ),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
