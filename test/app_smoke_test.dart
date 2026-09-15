import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sports_group_mobile/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    appRouter.go('/welcome');
  });

  testWidgets('onboarding enters the authenticated app shell', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: SportsGroupApp()));
    await tester.pumpAndSettle();

    expect(find.text('Your game.\nYour group.\nAll sorted.'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Playly'), findsOneWidget);

    await tester.tap(find.text('Continue securely'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for the next game?'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
  });

  testWidgets('primary navigation opens the sessions experience', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    appRouter.go('/home');

    await tester.pumpWidget(const ProviderScope(child: SportsGroupApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();

    expect(find.text('Plan the game. Know who’s showing up.'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('New session'), findsOneWidget);
  });

  testWidgets('group chat sends a message', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    appRouter.go('/group/chat');

    await tester.pumpWidget(const ProviderScope(child: SportsGroupApp()));
    await tester.pumpAndSettle();

    expect(find.text('Message the group'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).last,
      'See everyone at the turf!',
    );
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('See everyone at the turf!'), findsOneWidget);
  });
}
