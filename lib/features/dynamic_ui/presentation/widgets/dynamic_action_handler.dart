import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/features/dynamic_ui/data/dynamic_screen_repository.dart';
import 'package:saasify/features/dynamic_ui/domain/dynamic_screen.dart';
import 'package:saasify/features/dynamic_ui/presentation/bloc/dynamic_screen_cubit.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

/// Executes backend-declared button / dialog actions.
class DynamicActionHandler {
  DynamicActionHandler(this.context);

  final BuildContext context;

  Future<void> run(
    DynamicAction? action, {
    required bool validateForm,
    GlobalKey<FormState>? formKey,
  }) async {
    if (action == null) return;
    if (validateForm) {
      final ok = formKey?.currentState?.validate() ?? true;
      if (!ok) return;
    }
    await _execute(action);
  }

  Future<void> _execute(DynamicAction action) async {
    switch (action.type) {
      case DynamicActionType.none:
        return;
      case DynamicActionType.dismiss:
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      case DynamicActionType.navigate:
        final route = _resolve(action.route ?? '');
        if (route.isNotEmpty) context.go(route);
      case DynamicActionType.toast:
        final message = _resolve(action.message ?? '');
        if (message.isNotEmpty && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      case DynamicActionType.dialog:
        final dialog = action.dialog;
        if (dialog == null) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: dialog.barrierDismissible,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(_resolve(dialog.title)),
              content: Text(_resolve(dialog.message)),
              actions: [
                for (final button in dialog.actions)
                  TextButton(
                    onPressed: () async {
                      if (button.onClick?.type != DynamicActionType.dismiss) {
                        Navigator.of(dialogContext).pop();
                      } else {
                        Navigator.of(dialogContext).pop();
                        return;
                      }
                      if (!context.mounted) return;
                      await run(
                        button.onClick,
                        validateForm: button.validateForm,
                      );
                    },
                    child: Text(
                      button.label,
                      style: TextStyle(
                        color: button.variant == DynamicButtonVariant.filled
                            ? AppColors.accent
                            : AppColors.inkSecondary,
                        fontWeight: button.variant == DynamicButtonVariant.filled
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      case DynamicActionType.api:
        final api = action.api;
        if (api == null) return;
        final cubit = context.read<DynamicScreenCubit>();
        cubit.setBusy(true);
        try {
          final values = cubit.state.values;
          final body = DynamicTemplate.resolveMap(api.body, values);
          final client = DynamicMockApiClient(
            ticketListCubit: context.read<TicketListCubit>(),
          );
          final result = await client.request(
            method: api.method,
            url: DynamicTemplate.resolve(api.url, values),
            body: body,
            headers: api.headers,
          );
          if (!context.mounted) return;
          if (result.ok) {
            await _executeWithContext(
              api.onSuccess,
              response: result.data,
            );
          } else {
            await _executeWithContext(
              api.onError,
              error: result.error ?? 'Request failed',
            );
          }
        } finally {
          if (context.mounted) {
            context.read<DynamicScreenCubit>().setBusy(false);
          }
        }
      case DynamicActionType.sequence:
        for (final step in action.steps) {
          if (!context.mounted) return;
          await _execute(step);
        }
    }
  }

  Future<void> _executeWithContext(
    DynamicAction? action, {
    Map<String, dynamic>? response,
    Object? error,
  }) async {
    if (action == null) return;
    final values = context.read<DynamicScreenCubit>().state.values;
    final resolved = DynamicAction(
      type: action.type,
      route: action.route == null
          ? null
          : DynamicTemplate.resolve(
              action.route!,
              values,
              response: response,
              error: error,
            ),
      message: action.message == null
          ? null
          : DynamicTemplate.resolve(
              action.message!,
              values,
              response: response,
              error: error,
            ),
      api: action.api,
      dialog: action.dialog,
      steps: [
        for (final step in action.steps)
          DynamicAction(
            type: step.type,
            route: step.route == null
                ? null
                : DynamicTemplate.resolve(
                    step.route!,
                    values,
                    response: response,
                    error: error,
                  ),
            message: step.message == null
                ? null
                : DynamicTemplate.resolve(
                    step.message!,
                    values,
                    response: response,
                    error: error,
                  ),
            api: step.api,
            dialog: step.dialog,
            steps: step.steps,
          ),
      ],
    );
    await _execute(resolved);
  }

  String _resolve(String template) {
    final values = context.read<DynamicScreenCubit>().state.values;
    return DynamicTemplate.resolve(template, values);
  }
}

AppButtonVariant mapButtonVariant(DynamicButtonVariant variant) {
  return switch (variant) {
    DynamicButtonVariant.outlined => AppButtonVariant.outlined,
    DynamicButtonVariant.text => AppButtonVariant.text,
    DynamicButtonVariant.filled => AppButtonVariant.filled,
  };
}
