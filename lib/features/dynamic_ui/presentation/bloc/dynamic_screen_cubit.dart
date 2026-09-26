import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/dynamic_ui/data/dynamic_screen_repository.dart';
import 'package:saasify/features/dynamic_ui/domain/dynamic_screen.dart';

enum DynamicScreenStatus { initial, loading, ready, failure }

class DynamicScreenState extends Equatable {
  const DynamicScreenState({
    this.status = DynamicScreenStatus.initial,
    this.config,
    this.values = const {},
    this.busy = false,
    this.errorMessage,
  });

  final DynamicScreenStatus status;
  final DynamicScreenConfig? config;
  final Map<String, String> values;
  final bool busy;
  final String? errorMessage;

  DynamicScreenState copyWith({
    DynamicScreenStatus? status,
    DynamicScreenConfig? config,
    Map<String, String>? values,
    bool? busy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DynamicScreenState(
      status: status ?? this.status,
      config: config ?? this.config,
      values: values ?? this.values,
      busy: busy ?? this.busy,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, config, values, busy, errorMessage];
}

class DynamicScreenCubit extends Cubit<DynamicScreenState> {
  DynamicScreenCubit({
    required this.screenId,
    DynamicScreenRepository? repository,
  })  : _repository = repository ?? const DynamicScreenRepository(),
        super(const DynamicScreenState());

  final String screenId;
  final DynamicScreenRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: DynamicScreenStatus.loading, clearError: true));
    try {
      final config = await _repository.fetchScreen(screenId);
      final values = <String, String>{};
      for (final row in config.rows) {
        for (final field in row.fields) {
          if (field.defaultValue != null) {
            values[field.key] = field.defaultValue!;
          }
        }
      }
      emit(
        state.copyWith(
          status: DynamicScreenStatus.ready,
          config: config,
          values: values,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DynamicScreenStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void setValue(String key, String? value) {
    final next = Map<String, String>.from(state.values);
    if (value == null || value.isEmpty) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    emit(state.copyWith(values: next));
  }

  void setBusy(bool busy) => emit(state.copyWith(busy: busy));
}
