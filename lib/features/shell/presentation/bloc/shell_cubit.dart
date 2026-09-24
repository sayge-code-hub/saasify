import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Destination shown in the adaptive shell navigation.
class ShellDestination extends Equatable {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String location;

  @override
  List<Object?> get props => [label, icon, selectedIcon, location];
}

/// Default destinations for the foundation shell.
abstract final class ShellDestinations {
  static const home = ShellDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    location: '/',
  );

  static const settings = ShellDestination(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    location: '/settings',
  );

  static const List<ShellDestination> all = [home, settings];
}

final class ShellState extends Equatable {
  const ShellState({this.selectedIndex = 0});

  final int selectedIndex;

  ShellDestination get selected => ShellDestinations.all[selectedIndex];

  ShellState copyWith({int? selectedIndex}) {
    return ShellState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }

  @override
  List<Object?> get props => [selectedIndex];
}

class ShellCubit extends Cubit<ShellState> {
  ShellCubit({int initialIndex = 0})
      : super(ShellState(selectedIndex: initialIndex));

  void selectIndex(int index) {
    if (index < 0 || index >= ShellDestinations.all.length) return;
    if (index == state.selectedIndex) return;
    emit(state.copyWith(selectedIndex: index));
  }

  void selectLocation(String location) {
    final index = ShellDestinations.all.indexWhere(
      (d) => d.location == location,
    );
    if (index == -1) return;
    selectIndex(index);
  }
}
