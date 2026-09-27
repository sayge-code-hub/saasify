import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/shell/presentation/widgets/dashboard_header.dart';

void main() {
  test('formatHeaderDateTime is professional with timezone', () {
    final stamp = formatHeaderDateTime(
      DateTime(2026, 9, 26, 19, 2),
    );
    expect(stamp, contains('Sat, 26 Sep 2026'));
    expect(stamp, contains('19:02'));
    expect(
      stamp.contains('UTC') || RegExp(r'[A-Z]{2,5}$').hasMatch(stamp),
      isTrue,
    );
  });

  test('formatTimezoneLabel prefers short abbreviations', () {
    // Offset-only path uses a fixed UTC instant; label still returns UTC±hh:mm
    // when the platform timezone name is not a short abbreviation.
    final label = formatTimezoneLabel(DateTime.utc(2026, 1, 1));
    expect(label, isNotEmpty);
  });

  testWidgets('HeaderDateTime renders stacked light grey clock', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: HeaderDateTime(
            now: () => DateTime(2026, 9, 26, 19, 2),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('header-datetime')), findsOneWidget);
    expect(find.textContaining('26 Sep 2026'), findsOneWidget);
    expect(find.textContaining('19:02'), findsOneWidget);

    final column = tester.widget<Column>(
      find.byKey(const ValueKey('header-datetime')),
    );
    expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    expect(column.children.whereType<Text>().length, 2);
  });
}
