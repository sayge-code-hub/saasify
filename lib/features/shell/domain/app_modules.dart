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
  static const overview = NavModule(
    id: 'overview',
    label: 'Overview',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    location: '/',
  );

  static const ticketing = NavModule(
    id: 'ticketing',
    label: 'Ticketing',
    icon: Icons.confirmation_number_outlined,
    selectedIcon: Icons.confirmation_number,
    children: [
      NavSubmodule(
        id: 'ticketing-all',
        label: 'All tickets',
        location: '/ticketing',
      ),
      NavSubmodule(
        id: 'ticketing-open',
        label: 'Open',
        location: '/ticketing/open',
      ),
      NavSubmodule(
        id: 'ticketing-pending',
        label: 'Pending',
        location: '/ticketing/pending',
      ),
      NavSubmodule(
        id: 'ticketing-resolved',
        label: 'Resolved',
        location: '/ticketing/resolved',
      ),
    ],
  );

  static const settings = NavModule(
    id: 'settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    location: '/settings',
  );

  static const List<NavModule> all = [overview, ticketing, settings];

  static bool isLocationActive(String currentPath, String location) {
    if (location == '/') return currentPath == '/';
    if (currentPath == location) return true;
    // Ticket detail should keep Ticketing › All highlighted loosely.
    if (location == '/ticketing' && currentPath.startsWith('/ticketing/tickets')) {
      return true;
    }
    return false;
  }

  static bool isModuleExpandedForPath(NavModule module, String currentPath) {
    if (!module.hasChildren) return false;
    return module.children.any(
      (child) =>
          currentPath == child.location ||
          currentPath.startsWith('${child.location}/') ||
          (child.location == '/ticketing' &&
              currentPath.startsWith('/ticketing')),
    );
  }
}
