import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_error_view.dart';
import 'package:saasify/core/widgets/app_loading.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('invokes onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: AppButton(
              label: 'Continue',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      expect(tapped, isTrue);
    });

    testWidgets('shows loading and disables press', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: AppButton(
              label: 'Continue',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(tapped, isFalse);
    });
  });

  group('AppEmptyState', () {
    testWidgets('renders title and action', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: AppEmptyState(
              title: 'No items',
              message: 'Create your first item.',
              actionLabel: 'Create',
              onAction: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('No items'), findsOneWidget);
      await tester.tap(find.text('Create'));
      expect(pressed, isTrue);
    });
  });

  group('AppErrorView', () {
    testWidgets('renders message and retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: AppErrorView(
              message: 'Request failed',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Request failed'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });
  });

  group('AppLoading', () {
    testWidgets('shows optional message', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          const Scaffold(body: AppLoading(message: 'Loading workspace')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading workspace'), findsOneWidget);
    });
  });
}
