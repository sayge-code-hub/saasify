import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';

void main() {
  group('AppBreakpoints.fromWidth', () {
    test('compact below 600', () {
      expect(AppBreakpoints.fromWidth(390), Breakpoint.compact);
      expect(AppBreakpoints.fromWidth(599), Breakpoint.compact);
    });

    test('medium from 600', () {
      expect(AppBreakpoints.fromWidth(600), Breakpoint.medium);
      expect(AppBreakpoints.fromWidth(1023), Breakpoint.medium);
    });

    test('expanded from 1024', () {
      expect(AppBreakpoints.fromWidth(1024), Breakpoint.expanded);
      expect(AppBreakpoints.fromWidth(1440), Breakpoint.expanded);
    });
  });
}
