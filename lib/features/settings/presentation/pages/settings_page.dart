import 'package:flutter/material.dart';

import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';

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
              'Workspace preferences will land here in a later slice. '
              'Ticketing admin UI is the current focus.',
          icon: Icons.settings_outlined,
        ),
      ),
    );
  }
}
