import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/help/domain/help_topics.dart';
import 'package:saasify/features/help/presentation/pages/help_page.dart';
import 'package:saasify/features/help/presentation/pages/help_topic_page.dart';

void main() {
  testWidgets('help page shows three tiles and opens topic screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/help',
      routes: [
        GoRoute(
          path: '/help',
          builder: (context, state) => const Scaffold(body: HelpPage()),
          routes: [
            GoRoute(
              path: ':topic',
              builder: (context, state) => Scaffold(
                body: HelpTopicPage(
                  topic: HelpTopicX.tryParse(
                        state.pathParameters['topic'] ?? '',
                      ) ??
                      HelpTopic.bug,
                ),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Raise a bug'), findsOneWidget);
    expect(find.text('Contact us'), findsOneWidget);
    expect(find.text('New feature request'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
    expect(find.byKey(const ValueKey('help-tile-bug')), findsOneWidget);
    expect(find.byKey(const ValueKey('help-arrow-bug')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('help-tile-bug')));
    await tester.pumpAndSettle();

    expect(find.text('Back to Help'), findsOneWidget);
    expect(find.byKey(const ValueKey('help-topic-submit')), findsOneWidget);
    expect(find.text('Submit bug'), findsOneWidget);
  });
}
