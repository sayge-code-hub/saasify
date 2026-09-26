import 'package:equatable/equatable.dart';

enum DynamicFieldType { text, textarea, dropdown, radio }

enum DynamicButtonVariant { filled, outlined, text }

enum DynamicActionType {
  navigate,
  api,
  dialog,
  dismiss,
  toast,
  sequence,
  none,
}

class DynamicOption extends Equatable {
  const DynamicOption({required this.value, required this.label});

  final String value;
  final String label;

  factory DynamicOption.fromJson(Map<String, dynamic> json) {
    return DynamicOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? json['value']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [value, label];
}

class DynamicFieldConfig extends Equatable {
  const DynamicFieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.hint,
    this.defaultValue,
    this.maxLines = 1,
    this.flex = 1,
    this.options = const [],
  });

  final String key;
  final String label;
  final DynamicFieldType type;
  final bool required;
  final String? hint;
  final String? defaultValue;
  final int maxLines;
  final int flex;
  final List<DynamicOption> options;

  factory DynamicFieldConfig.fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type']?.toString() ?? 'text').toLowerCase();
    final type = switch (typeRaw) {
      'textarea' => DynamicFieldType.textarea,
      'dropdown' || 'select' => DynamicFieldType.dropdown,
      'radio' => DynamicFieldType.radio,
      _ => DynamicFieldType.text,
    };
    final optionsJson = json['options'];
    return DynamicFieldConfig(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: type,
      required: json['required'] == true,
      hint: json['hint']?.toString(),
      defaultValue: json['defaultValue']?.toString(),
      maxLines: (json['maxLines'] as num?)?.toInt() ??
          (type == DynamicFieldType.textarea ? 4 : 1),
      flex: (json['flex'] as num?)?.toInt() ?? 1,
      options: optionsJson is List
          ? [
              for (final item in optionsJson)
                if (item is Map<String, dynamic>) DynamicOption.fromJson(item),
            ]
          : const [],
    );
  }

  @override
  List<Object?> get props => [
        key,
        label,
        type,
        required,
        hint,
        defaultValue,
        maxLines,
        flex,
        options,
      ];
}

class DynamicRowConfig extends Equatable {
  const DynamicRowConfig({
    required this.id,
    required this.fields,
  });

  final String id;
  final List<DynamicFieldConfig> fields;

  factory DynamicRowConfig.fromJson(Map<String, dynamic> json) {
    final fieldsJson = json['fields'];
    final fields = <DynamicFieldConfig>[];
    if (fieldsJson is List) {
      for (final item in fieldsJson) {
        if (item is Map<String, dynamic>) {
          fields.add(DynamicFieldConfig.fromJson(item));
        }
        if (fields.length >= 2) break; // max 2 widgets per row
      }
    }
    return DynamicRowConfig(
      id: json['id']?.toString() ?? 'row',
      fields: fields,
    );
  }

  @override
  List<Object?> get props => [id, fields];
}

class DynamicApiConfig extends Equatable {
  const DynamicApiConfig({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body = const {},
    this.onSuccess,
    this.onError,
  });

  final String method;
  final String url;
  final Map<String, String> headers;
  final Map<String, dynamic> body;
  final DynamicAction? onSuccess;
  final DynamicAction? onError;

  factory DynamicApiConfig.fromJson(Map<String, dynamic> json) {
    final headersRaw = json['headers'];
    final bodyRaw = json['body'];
    return DynamicApiConfig(
      method: (json['method']?.toString() ?? 'POST').toUpperCase(),
      url: json['url']?.toString() ?? '',
      headers: headersRaw is Map
          ? {
              for (final e in headersRaw.entries)
                e.key.toString(): e.value.toString(),
            }
          : const {},
      body: bodyRaw is Map<String, dynamic>
          ? Map<String, dynamic>.from(bodyRaw)
          : bodyRaw is Map
              ? {
                  for (final e in bodyRaw.entries)
                    e.key.toString(): e.value,
                }
              : const {},
      onSuccess: json['onSuccess'] is Map<String, dynamic>
          ? DynamicAction.fromJson(json['onSuccess'] as Map<String, dynamic>)
          : null,
      onError: json['onError'] is Map<String, dynamic>
          ? DynamicAction.fromJson(json['onError'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [method, url, headers, body, onSuccess, onError];
}

class DynamicDialogConfig extends Equatable {
  const DynamicDialogConfig({
    required this.title,
    required this.message,
    this.barrierDismissible = true,
    this.actions = const [],
  });

  final String title;
  final String message;
  final bool barrierDismissible;
  final List<DynamicButtonConfig> actions;

  factory DynamicDialogConfig.fromJson(Map<String, dynamic> json) {
    final actionsJson = json['actions'];
    return DynamicDialogConfig(
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      barrierDismissible: json['barrierDismissible'] != false,
      actions: actionsJson is List
          ? [
              for (final item in actionsJson)
                if (item is Map<String, dynamic>)
                  DynamicButtonConfig.fromJson(item),
            ]
          : const [],
    );
  }

  @override
  List<Object?> get props => [title, message, barrierDismissible, actions];
}

class DynamicAction extends Equatable {
  const DynamicAction({
    required this.type,
    this.route,
    this.message,
    this.api,
    this.dialog,
    this.steps = const [],
  });

  final DynamicActionType type;
  final String? route;
  final String? message;
  final DynamicApiConfig? api;
  final DynamicDialogConfig? dialog;
  final List<DynamicAction> steps;

  factory DynamicAction.fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type']?.toString() ?? 'none').toLowerCase();
    final type = switch (typeRaw) {
      'navigate' => DynamicActionType.navigate,
      'api' => DynamicActionType.api,
      'dialog' || 'confirm' => DynamicActionType.dialog,
      'dismiss' => DynamicActionType.dismiss,
      'toast' => DynamicActionType.toast,
      'sequence' => DynamicActionType.sequence,
      _ => DynamicActionType.none,
    };

    final stepsJson = json['steps'];
    return DynamicAction(
      type: type,
      route: json['route']?.toString(),
      message: json['message']?.toString(),
      api: type == DynamicActionType.api
          ? DynamicApiConfig.fromJson(json)
          : null,
      dialog: json['dialog'] is Map<String, dynamic>
          ? DynamicDialogConfig.fromJson(json['dialog'] as Map<String, dynamic>)
          : null,
      steps: stepsJson is List
          ? [
              for (final item in stepsJson)
                if (item is Map<String, dynamic>) DynamicAction.fromJson(item),
            ]
          : const [],
    );
  }

  @override
  List<Object?> get props => [type, route, message, api, dialog, steps];
}

class DynamicButtonConfig extends Equatable {
  const DynamicButtonConfig({
    required this.id,
    required this.label,
    this.variant = DynamicButtonVariant.filled,
    this.validateForm = false,
    this.onClick,
  });

  final String id;
  final String label;
  final DynamicButtonVariant variant;
  final bool validateForm;
  final DynamicAction? onClick;

  factory DynamicButtonConfig.fromJson(Map<String, dynamic> json) {
    final variantRaw = (json['variant']?.toString() ?? 'filled').toLowerCase();
    final variant = switch (variantRaw) {
      'outlined' => DynamicButtonVariant.outlined,
      'text' => DynamicButtonVariant.text,
      _ => DynamicButtonVariant.filled,
    };
    return DynamicButtonConfig(
      id: json['id']?.toString() ?? json['label']?.toString() ?? 'button',
      label: json['label']?.toString() ?? 'Button',
      variant: variant,
      validateForm: json['validateForm'] == true,
      onClick: json['onClick'] is Map<String, dynamic>
          ? DynamicAction.fromJson(json['onClick'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, label, variant, validateForm, onClick];
}

class DynamicScreenConfig extends Equatable {
  const DynamicScreenConfig({
    required this.id,
    required this.title,
    this.headerTitle,
    this.cardWidthFactor = 0.95,
    this.stickyActions = true,
    this.actionsAlign = 'end',
    this.rows = const [],
    this.buttons = const [],
  });

  final String id;
  final String title;
  final String? headerTitle;
  final double cardWidthFactor;
  final bool stickyActions;
  final String actionsAlign;
  final List<DynamicRowConfig> rows;
  final List<DynamicButtonConfig> buttons;

  factory DynamicScreenConfig.fromJson(Map<String, dynamic> json) {
    final rowsJson = json['rows'];
    final buttonsJson = json['buttons'];
    return DynamicScreenConfig(
      id: json['id']?.toString() ?? 'screen',
      title: json['title']?.toString() ?? 'Form',
      headerTitle: json['headerTitle']?.toString(),
      cardWidthFactor:
          (json['cardWidthFactor'] as num?)?.toDouble().clamp(0.2, 1.0) ?? 0.95,
      stickyActions: json['stickyActions'] != false,
      actionsAlign: json['actionsAlign']?.toString() ?? 'end',
      rows: rowsJson is List
          ? [
              for (final item in rowsJson)
                if (item is Map<String, dynamic>) DynamicRowConfig.fromJson(item),
            ]
          : const [],
      buttons: buttonsJson is List
          ? [
              for (final item in buttonsJson)
                if (item is Map<String, dynamic>)
                  DynamicButtonConfig.fromJson(item),
            ]
          : const [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        headerTitle,
        cardWidthFactor,
        stickyActions,
        actionsAlign,
        rows,
        buttons,
      ];
}
