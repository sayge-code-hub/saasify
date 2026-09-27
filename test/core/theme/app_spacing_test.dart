import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_page.dart';

void main() {
  test('pageContentTop matches the compact page padding scale', () {
    expect(AppSpacing.pageContentTop, AppSpacing.md);
    expect(AppSpacing.pageContentTop, lessThan(AppSpacing.xxl));
  });

  testWidgets('AppPage uses pageContentTop for vertical inset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(1200, 800)),
          child: AppPage(child: SizedBox(key: ValueKey('page-child'))),
        ),
      ),
    );

    final padding = tester.widget<Padding>(
      find
          .descendant(
            of: find.byType(ConstrainedBox),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(
      (padding.padding as EdgeInsets).top,
      AppSpacing.pageContentTop,
    );
  });
}
