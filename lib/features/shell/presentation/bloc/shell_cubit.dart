import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/shell/domain/app_modules.dart';

class ShellState extends Equatable {
  const ShellState({
    this.location = '/',
    this.expandedModuleIds = const {'ticketing'},
  });

  final String location;
  final Set<String> expandedModuleIds;

  ShellState copyWith({
    String? location,
    Set<String>? expandedModuleIds,
  }) {
    return ShellState(
      location: location ?? this.location,
      expandedModuleIds: expandedModuleIds ?? this.expandedModuleIds,
    );
  }

  @override
  List<Object?> get props => [location, expandedModuleIds];
}

class ShellCubit extends Cubit<ShellState> {
  ShellCubit({String initialLocation = '/'})
      : super(
          ShellState(
            location: initialLocation,
            expandedModuleIds: {
              for (final module in AppModules.all)
                if (AppModules.isModuleExpandedForPath(module, initialLocation))
                  module.id,
              'ticketing',
            },
          ),
        );

  void setLocation(String location) {
    final expanded = {...state.expandedModuleIds};
    for (final module in AppModules.all) {
      if (AppModules.isModuleExpandedForPath(module, location)) {
        expanded.add(module.id);
      }
    }
    emit(state.copyWith(location: location, expandedModuleIds: expanded));
  }

  void toggleModule(String moduleId) {
    final expanded = {...state.expandedModuleIds};
    if (expanded.contains(moduleId)) {
      expanded.remove(moduleId);
    } else {
      expanded.add(moduleId);
    }
    emit(state.copyWith(expandedModuleIds: expanded));
  }
}
