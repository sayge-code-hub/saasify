import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class NavSubmodule extends Equatable {
  const NavSubmodule({
    required this.id,
    required this.label,
    required this.location,
  });

  final String id;
  final String label;
  final String location;

  @override
  List<Object?> get props => [id, label, location];
}

class NavModule extends Equatable {
  const NavModule({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.location,
    this.children = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String? location;
  final List<NavSubmodule> children;

  bool get hasChildren => children.isNotEmpty;

  @override
  List<Object?> get props =>
      [id, label, icon, selectedIcon, location, children];
}

/// Canonical admin navigation tree.
abstract final class AppModules {
  static const ticketing = NavModule(
    id: 'ticketing',
    label: 'Ticketing',
    icon: Icons.confirmation_number_outlined,
    selectedIcon: Icons.confirmation_number,
    location: '/ticketing',
    children: [
      NavSubmodule(
        id: 'ticketing-dashboard',
        label: 'Dashboard',
        location: '/ticketing',
      ),
      NavSubmodule(
        id: 'ticketing-new',
        label: 'Add Ticket',
        location: '/ticketing/new',
      ),
      NavSubmodule(
        id: 'ticketing-all',
        label: 'All Tickets',
        location: '/ticketing/all',
      ),
      NavSubmodule(
        id: 'ticketing-open',
        label: 'Open Tickets',
        location: '/ticketing/open',
      ),
      NavSubmodule(
        id: 'ticketing-pending',
        label: 'Pending Tickets',
        location: '/ticketing/pending',
      ),
      NavSubmodule(
        id: 'ticketing-resolved',
        label: 'Resolved Tickets',
        location: '/ticketing/resolved',
      ),
      NavSubmodule(
        id: 'ticketing-priority',
        label: 'Priority Tickets',
        location: '/ticketing/priority',
      ),
      NavSubmodule(
        id: 'ticketing-config',
        label: 'Config',
        location: '/ticketing/config',
      ),
    ],
  );

  static const dynamicUi = NavModule(
    id: 'dynamic-ui',
    label: 'Dynamic UI',
    icon: Icons.dashboard_customize_outlined,
    selectedIcon: Icons.dashboard_customize,
    location: '/dynamic/create-ticket',
    children: [
      NavSubmodule(
        id: 'dynamic-create-ticket',
        label: 'BDUI Add Ticket',
        location: '/dynamic/create-ticket',
      ),
    ],
  );

  static const List<NavModule> all = [ticketing, dynamicUi];

  static bool isLocationActive(String currentPath, String location) {
    if (currentPath == location) return true;

    // Dashboard is only the ticketing root — not nested list routes.
    if (location == '/ticketing') {
      return currentPath == '/ticketing';
    }

    // Detail views keep All Tickets highlighted.
    if (location == '/ticketing/all' &&
        currentPath.startsWith('/ticketing/tickets/')) {
      return true;
    }

    return false;
  }

  static bool isModuleExpandedForPath(NavModule module, String currentPath) {
    if (!module.hasChildren) return false;
    if (module.id == 'ticketing') {
      return currentPath == '/ticketing' ||
          currentPath.startsWith('/ticketing/');
    }
    if (module.id == 'dynamic-ui') {
      return currentPath == '/dynamic' || currentPath.startsWith('/dynamic/');
    }
    return module.children.any(
      (child) =>
          currentPath == child.location ||
          currentPath.startsWith('${child.location}/'),
    );
  }
}
