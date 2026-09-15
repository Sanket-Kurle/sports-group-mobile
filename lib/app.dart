import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/app_theme.dart';
import 'features/auth/welcome_screen.dart';
import 'features/finance/finance_screen.dart';
import 'features/group/group_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/sessions/create_session_screen.dart';
import 'features/sessions/session_detail_screen.dart';
import 'features/sessions/sessions_screen.dart';
import 'features/shell/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sessions',
              builder: (_, _) => const SessionsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, _) => const CreateSessionScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => SessionDetailScreen(
                    sessionId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/finance', builder: (_, _) => const FinanceScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/group',
              builder: (_, _) => const GroupScreen(),
              routes: [
                GoRoute(path: 'chat', builder: (_, _) => const ChatScreen()),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ],
        ),
      ],
    ),
  ],
);

class SportsGroupApp extends StatelessWidget {
  const SportsGroupApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Playly',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    routerConfig: appRouter,
  );
}
