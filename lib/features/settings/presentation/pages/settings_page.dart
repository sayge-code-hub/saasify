import 'package:flutter/material.dart';

import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';

/// Placeholder settings surface — expand when product specs arrive.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      scrollable: false,
      child: SizedBox(
        height: 420,
        child: AppEmptyState(
          title: 'Settings',
          message:
              'Workspace preferences will land here once product '
              'requirements are specified.',
          icon: Icons.settings_outlined,
        ),
      ),
    );
  }
}
