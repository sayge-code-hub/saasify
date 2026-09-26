import 'package:saasify/features/dynamic_ui/data/mock_dynamic_screens.dart';
import 'package:saasify/features/dynamic_ui/domain/dynamic_screen.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

/// Resolves `{{field}}` and `{{response.x}}` / `{{error.message}}` templates.
abstract final class DynamicTemplate {
  static String resolve(
    String template,
    Map<String, String> values, {
    Map<String, dynamic>? response,
    Object? error,
  }) {
    var out = template;
    for (final entry in values.entries) {
      out = out.replaceAll('{{${entry.key}}}', entry.value);
    }
    if (response != null) {
      response.forEach((key, value) {
        out = out.replaceAll('{{response.$key}}', '$value');
      });
    }
    if (error != null) {
      out = out.replaceAll('{{error.message}}', error.toString());
    }
    // Clear unresolved tokens.
    out = out.replaceAll(RegExp(r'\{\{[^}]+\}\}'), '');
    return out;
  }

  static Map<String, dynamic> resolveMap(
    Map<String, dynamic> source,
    Map<String, String> values, {
    Map<String, dynamic>? response,
    Object? error,
  }) {
    return {
      for (final entry in source.entries)
        entry.key: entry.value is String
            ? resolve(
                entry.value as String,
                values,
                response: response,
                error: error,
              )
            : entry.value is Map<String, dynamic>
                ? resolveMap(
                    entry.value as Map<String, dynamic>,
                    values,
                    response: response,
                    error: error,
                  )
                : entry.value,
    };
  }
}

class DynamicApiResult {
  const DynamicApiResult({
    required this.ok,
    this.data = const {},
    this.error,
  });

  final bool ok;
  final Map<String, dynamic> data;
  final String? error;
}

/// Mock HTTP layer for BDUI `api` actions. Swap later for real networking.
class DynamicMockApiClient {
  DynamicMockApiClient({this.ticketListCubit});

  final TicketListCubit? ticketListCubit;

  Future<DynamicApiResult> request({
    required String method,
    required String url,
    required Map<String, dynamic> body,
    Map<String, String> headers = const {},
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (method == 'POST' && url == '/api/tickets') {
      return _createTicket(body);
    }

    return DynamicApiResult(
      ok: false,
      error: 'No mock handler for $method $url',
    );
  }

  DynamicApiResult _createTicket(Map<String, dynamic> body) {
    final cubit = ticketListCubit;
    if (cubit == null) {
      return const DynamicApiResult(
        ok: false,
        error: 'Ticket service unavailable',
      );
    }

    final header = body['header']?.toString().trim() ?? '';
    final description = body['description']?.toString().trim() ?? '';
    final application = body['application']?.toString().trim() ?? '';
    final distribution = body['distributionList']?.toString().trim() ?? '';
    if (header.isEmpty ||
        description.isEmpty ||
        application.isEmpty ||
        distribution.isEmpty) {
      return const DynamicApiResult(
        ok: false,
        error: 'Missing required ticket fields',
      );
    }

    final priority = switch (body['priority']?.toString().toLowerCase()) {
      'low' => TicketPriority.low,
      'high' => TicketPriority.high,
      'urgent' => TicketPriority.urgent,
      _ => TicketPriority.medium,
    };

    final id = cubit.createTicket(
      subject: header,
      description: description,
      priority: priority,
      application: application,
      distributionList: distribution,
      isBug: body['bug']?.toString().toLowerCase() == 'yes',
      responsibility: body['responsibility']?.toString() ?? '',
      affectedEquipment: body['affectedEquipment']?.toString() ?? '',
    );

    return DynamicApiResult(
      ok: true,
      data: {'id': id, 'status': 'open'},
    );
  }
}

/// Loads screen configs. Today: embedded mock JSON; later: GET /api/screens/:id.
class DynamicScreenRepository {
  const DynamicScreenRepository();

  Future<DynamicScreenConfig> fetchScreen(String screenId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (screenId == MockDynamicScreens.createTicketScreenId) {
      return DynamicScreenConfig.fromJson(
        MockDynamicScreens.createTicketScreenJson(),
      );
    }
    throw StateError('Unknown dynamic screen: $screenId');
  }
}
