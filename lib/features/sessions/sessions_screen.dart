import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});
  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  var _past = false;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final all = ref.watch(selectedGroupSessionsProvider);
    final sessions = all
        .where(
          (item) => _past
              ? item.startsAt.isBefore(DateTime.now())
              : item.startsAt.isAfter(DateTime.now()),
        )
        .toList();
    if (!_past) sessions.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return Scaffold(
      appBar: AppBar(
        title: const GroupSwitcher(),
        actions: [
          if (state.canManageSessions)
            IconButton(
              onPressed: () => context.go('/sessions/new'),
              icon: const Icon(Icons.add_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: PagePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sessions', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 5),
            const Text(
              'Plan the game. Know who’s showing up.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Upcoming')),
                ButtonSegment(value: true, label: Text('Previous')),
              ],
              selected: {_past},
              onSelectionChanged: (value) =>
                  setState(() => _past = value.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.forest,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: sessions.isEmpty
                  ? const _EmptySessions()
                  : ListView.separated(
                      itemCount: sessions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) =>
                          _SessionCard(session: sessions[index]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: state.canManageSessions
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/sessions/new'),
              backgroundColor: AppColors.lime,
              foregroundColor: AppColors.forest,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'New session',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : null,
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final SportSession session;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.go('/sessions/${session.id}'),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('MMM').format(session.startsAt).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                  Text(
                    '${session.startsAt.day}',
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      StatusPill(
                        sessionStatusLabel(session.status),
                        color: sessionStatusColor(session.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${timeOnly.format(session.startsAt)} · ${session.venue}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      const Icon(
                        Icons.groups_2_outlined,
                        size: 17,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${session.inCount} in · ${session.maybeCount} maybe',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      if (session.rsvp != RsvpStatus.none)
                        StatusPill(
                          session.rsvp == RsvpStatus.inGame
                              ? 'You’re in'
                              : session.rsvp == RsvpStatus.waitlisted
                              ? 'Waitlisted'
                              : session.rsvp.name,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptySessions extends StatelessWidget {
  const _EmptySessions();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.event_busy_outlined, size: 56, color: AppColors.muted),
        const SizedBox(height: 12),
        Text(
          'No sessions here yet',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    ),
  );
}
