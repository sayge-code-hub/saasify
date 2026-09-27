import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/settings/presentation/bloc/company_logo_cubit.dart';
import 'package:saasify/features/settings/presentation/bloc/workspace_settings_cubit.dart';
import 'package:saasify/features/settings/presentation/widgets/company_brand_logo.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Settings',
            subtitle:
                'Workspace branding, profile, and notification preferences.',
          ),
          SizedBox(height: AppSpacing.lg),
          _CompanyLogoSection(),
          SizedBox(height: AppSpacing.md),
          _WorkspaceProfileSection(),
          SizedBox(height: AppSpacing.md),
          _PreferencesSection(),
          SizedBox(height: AppSpacing.md),
          _NotificationsSection(),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.editing,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
    this.editKey,
    this.cancelKey,
    this.saveKey,
  });

  final String title;
  final String subtitle;
  final bool editing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final Key? editKey;
  final Key? cancelKey;
  final Key? saveKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, variant: AppTextVariant.sectionTitle),
              const SizedBox(height: AppSpacing.xxs),
              AppText(subtitle, variant: AppTextVariant.sectionSubtitle),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (editing) ...[
          AppButton(
            key: cancelKey,
            label: 'Cancel',
            variant: AppButtonVariant.outlined,
            onPressed: onCancel,
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            key: saveKey,
            label: 'Save',
            onPressed: onSave,
          ),
        ] else
          AppButton(
            key: editKey,
            label: 'Edit',
            variant: AppButtonVariant.outlined,
            onPressed: onEdit,
          ),
      ],
    );
  }
}

class _CompanyLogoSection extends StatelessWidget {
  const _CompanyLogoSection();

  Future<void> _pickLogo(BuildContext context) async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    late final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not read that image. Try another file.'),
        ),
      );
      return;
    }
    if (bytes.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not read that image. Try another file.'),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    context.read<CompanyLogoCubit>().setBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final hasLogo = context.watch<CompanyLogoCubit>().state != null;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppText(
            'Company logo',
            variant: AppTextVariant.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.xxs),
          const AppText(
            'Shown in the top-left of the sidebar. PNG or JPG works best.',
            variant: AppTextVariant.sectionSubtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: CompanyBrandLogo(height: 36),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                key: const ValueKey('settings-logo-upload'),
                label: hasLogo ? 'Change logo' : 'Upload logo',
                onPressed: () => _pickLogo(context),
              ),
              if (hasLogo)
                AppButton(
                  key: const ValueKey('settings-logo-remove'),
                  label: 'Remove',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => context.read<CompanyLogoCubit>().clear(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkspaceProfileSection extends StatefulWidget {
  const _WorkspaceProfileSection();

  @override
  State<_WorkspaceProfileSection> createState() =>
      _WorkspaceProfileSectionState();
}

class _WorkspaceProfileSectionState extends State<_WorkspaceProfileSection> {
  bool _editing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<WorkspaceSettingsCubit>().state;
    _nameController = TextEditingController(text: settings.workspaceName);
    _emailController = TextEditingController(text: settings.supportEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncFrom(WorkspaceSettings settings) {
    _nameController.text = settings.workspaceName;
    _emailController.text = settings.supportEmail;
  }

  void _enterEdit() {
    _syncFrom(context.read<WorkspaceSettingsCubit>().state);
    setState(() => _editing = true);
  }

  Future<void> _cancel() async {
    _syncFrom(context.read<WorkspaceSettingsCubit>().state);
    setState(() => _editing = false);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a workspace name and valid support email.'),
        ),
      );
      return;
    }
    final cubit = context.read<WorkspaceSettingsCubit>();
    cubit.update(
      cubit.state.copyWith(workspaceName: name, supportEmail: email),
    );
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<WorkspaceSettingsCubit>().state;
    final titleStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.ink,
      fontWeight: FontWeight.w400,
    );

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Workspace profile',
            subtitle:
                'Name and support contact shown across the admin workspace.',
            editing: _editing,
            onEdit: _enterEdit,
            onCancel: _cancel,
            onSave: _save,
            editKey: const ValueKey('settings-profile-edit'),
            cancelKey: const ValueKey('settings-profile-cancel'),
            saveKey: const ValueKey('settings-profile-save'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Workspace name', style: titleStyle),
          const SizedBox(height: AppSpacing.xs),
          if (_editing)
            AppTextField(
              key: const ValueKey('settings-workspace-name'),
              controller: _nameController,
              hint: 'Acme Support',
            )
          else
            Text(
              settings.workspaceName,
              key: const ValueKey('settings-workspace-name'),
              style: valueStyle,
            ),
          const SizedBox(height: AppSpacing.md),
          Text('Support email', style: titleStyle),
          const SizedBox(height: AppSpacing.xs),
          if (_editing)
            AppTextField(
              key: const ValueKey('settings-support-email'),
              controller: _emailController,
              hint: 'support@company.com',
              keyboardType: TextInputType.emailAddress,
            )
          else
            Text(
              settings.supportEmail,
              key: const ValueKey('settings-support-email'),
              style: valueStyle,
            ),
        ],
      ),
    );
  }
}

class _PreferencesSection extends StatefulWidget {
  const _PreferencesSection();

  @override
  State<_PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<_PreferencesSection> {
  static const _timezones = ['UTC', 'America/New_York', 'Europe/London', 'Asia/Kolkata'];
  static const _languages = ['English', 'Spanish', 'French', 'German'];

  bool _editing = false;
  late String _timezone;
  late String _language;

  @override
  void initState() {
    super.initState();
    final settings = context.read<WorkspaceSettingsCubit>().state;
    _timezone = settings.timezone;
    _language = settings.language;
  }

  void _enterEdit() {
    final settings = context.read<WorkspaceSettingsCubit>().state;
    setState(() {
      _timezone = settings.timezone;
      _language = settings.language;
      _editing = true;
    });
  }

  void _cancel() {
    final settings = context.read<WorkspaceSettingsCubit>().state;
    setState(() {
      _timezone = settings.timezone;
      _language = settings.language;
      _editing = false;
    });
  }

  void _save() {
    final cubit = context.read<WorkspaceSettingsCubit>();
    cubit.update(
      cubit.state.copyWith(timezone: _timezone, language: _language),
    );
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<WorkspaceSettingsCubit>().state;
    final timezone = _editing ? _timezone : settings.timezone;
    final language = _editing ? _language : settings.language;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Preferences',
            subtitle: 'Default timezone and language for this workspace.',
            editing: _editing,
            onEdit: _enterEdit,
            onCancel: _cancel,
            onSave: _save,
            editKey: const ValueKey('settings-prefs-edit'),
            cancelKey: const ValueKey('settings-prefs-cancel'),
            saveKey: const ValueKey('settings-prefs-save'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Timezone',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            key: ValueKey('settings-timezone-$timezone-$_editing'),
            initialValue:
                _timezones.contains(timezone) ? timezone : _timezones.first,
            items: [
              for (final zone in _timezones)
                DropdownMenuItem(value: zone, child: Text(zone)),
            ],
            onChanged: _editing
                ? (value) {
                    if (value == null) return;
                    setState(() => _timezone = value);
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Language',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            key: ValueKey('settings-language-$language-$_editing'),
            initialValue:
                _languages.contains(language) ? language : _languages.first,
            items: [
              for (final lang in _languages)
                DropdownMenuItem(value: lang, child: Text(lang)),
            ],
            onChanged: _editing
                ? (value) {
                    if (value == null) return;
                    setState(() => _language = value);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection();

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool _editing = false;
  late bool _email;
  late bool _slack;

  @override
  void initState() {
    super.initState();
    final settings = context.read<WorkspaceSettingsCubit>().state;
    _email = settings.emailNotifications;
    _slack = settings.slackNotifications;
  }

  void _enterEdit() {
    final settings = context.read<WorkspaceSettingsCubit>().state;
    setState(() {
      _email = settings.emailNotifications;
      _slack = settings.slackNotifications;
      _editing = true;
    });
  }

  void _cancel() {
    final settings = context.read<WorkspaceSettingsCubit>().state;
    setState(() {
      _email = settings.emailNotifications;
      _slack = settings.slackNotifications;
      _editing = false;
    });
  }

  void _save() {
    final cubit = context.read<WorkspaceSettingsCubit>();
    cubit.update(
      cubit.state.copyWith(
        emailNotifications: _email,
        slackNotifications: _slack,
      ),
    );
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<WorkspaceSettingsCubit>().state;
    final email = _editing ? _email : settings.emailNotifications;
    final slack = _editing ? _slack : settings.slackNotifications;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Notifications',
            subtitle: 'Choose how agents are notified about ticket activity.',
            editing: _editing,
            onEdit: _enterEdit,
            onCancel: _cancel,
            onSave: _save,
            editKey: const ValueKey('settings-notify-edit'),
            cancelKey: const ValueKey('settings-notify-cancel'),
            saveKey: const ValueKey('settings-notify-save'),
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            key: const ValueKey('settings-email-notifications'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Email notifications'),
            subtitle: const Text('Send ticket updates to the support inbox.'),
            value: email,
            activeThumbColor: AppColors.accent,
            onChanged: _editing
                ? (value) => setState(() => _email = value)
                : null,
          ),
          SwitchListTile.adaptive(
            key: const ValueKey('settings-slack-notifications'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Slack notifications'),
            subtitle: const Text('Post high-priority alerts to Slack (mock).'),
            value: slack,
            activeThumbColor: AppColors.accent,
            onChanged: _editing
                ? (value) => setState(() => _slack = value)
                : null,
          ),
        ],
      ),
    );
  }
}
