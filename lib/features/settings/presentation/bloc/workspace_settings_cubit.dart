import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Editable workspace preferences (mock / in-memory).
class WorkspaceSettings extends Equatable {
  const WorkspaceSettings({
    required this.workspaceName,
    required this.supportEmail,
    required this.timezone,
    required this.language,
    required this.emailNotifications,
    required this.slackNotifications,
  });

  final String workspaceName;
  final String supportEmail;
  final String timezone;
  final String language;
  final bool emailNotifications;
  final bool slackNotifications;

  factory WorkspaceSettings.defaults() {
    return const WorkspaceSettings(
      workspaceName: 'Acme Support',
      supportEmail: 'support@acme.example',
      timezone: 'UTC',
      language: 'English',
      emailNotifications: true,
      slackNotifications: false,
    );
  }

  WorkspaceSettings copyWith({
    String? workspaceName,
    String? supportEmail,
    String? timezone,
    String? language,
    bool? emailNotifications,
    bool? slackNotifications,
  }) {
    return WorkspaceSettings(
      workspaceName: workspaceName ?? this.workspaceName,
      supportEmail: supportEmail ?? this.supportEmail,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      slackNotifications: slackNotifications ?? this.slackNotifications,
    );
  }

  @override
  List<Object?> get props => [
        workspaceName,
        supportEmail,
        timezone,
        language,
        emailNotifications,
        slackNotifications,
      ];
}

class WorkspaceSettingsCubit extends Cubit<WorkspaceSettings> {
  WorkspaceSettingsCubit({WorkspaceSettings? initial})
      : super(initial ?? WorkspaceSettings.defaults());

  void update(WorkspaceSettings next) => emit(next);
}
