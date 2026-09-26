import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/features/dynamic_ui/data/mock_dynamic_screens.dart';
import 'package:saasify/features/dynamic_ui/domain/dynamic_screen.dart';
import 'package:saasify/features/dynamic_ui/data/dynamic_screen_repository.dart';

void main() {
  group('DynamicScreenConfig', () {
    test('parses create-ticket mock with max 2 fields per row', () {
      final config = DynamicScreenConfig.fromJson(
        MockDynamicScreens.createTicketScreenJson(),
      );

      expect(config.id, 'create-ticket');
      expect(config.cardWidthFactor, 0.95);
      expect(config.stickyActions, isTrue);
      expect(config.rows, isNotEmpty);
      expect(config.buttons, hasLength(2));

      for (final row in config.rows) {
        expect(row.fields.length, lessThanOrEqualTo(2));
      }

      final types = config.rows
          .expand((r) => r.fields)
          .map((f) => f.type)
          .toSet();
      expect(types, contains(DynamicFieldType.text));
      expect(types, contains(DynamicFieldType.dropdown));
      expect(types, contains(DynamicFieldType.textarea));
      expect(types, contains(DynamicFieldType.radio));

      final save = config.buttons.firstWhere((b) => b.id == 'save');
      expect(save.validateForm, isTrue);
      expect(save.onClick?.type, DynamicActionType.dialog);
      expect(save.onClick?.dialog?.actions, isNotEmpty);

      final confirm = save.onClick!.dialog!.actions
          .firstWhere((a) => a.id == 'dialog-confirm');
      expect(confirm.onClick?.type, DynamicActionType.api);
      expect(confirm.onClick?.api?.method, 'POST');
      expect(confirm.onClick?.api?.url, '/api/tickets');
    });

    test('template resolver substitutes field and response tokens', () {
      final out = DynamicTemplate.resolve(
        'Ticket {{response.id}} for {{header}}',
        {'header': 'PDF broken'},
        response: {'id': 'TCK-99'},
      );
      expect(out, 'Ticket TCK-99 for PDF broken');
    });
  });
}
