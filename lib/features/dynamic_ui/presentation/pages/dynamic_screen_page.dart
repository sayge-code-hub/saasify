import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/dynamic_ui/presentation/bloc/dynamic_screen_cubit.dart';
import 'package:saasify/features/dynamic_ui/presentation/widgets/dynamic_screen_renderer.dart';

/// Host page for a backend-driven screen identified by [screenId].
class DynamicScreenPage extends StatelessWidget {
  const DynamicScreenPage({required this.screenId, super.key});

  final String screenId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DynamicScreenCubit(screenId: screenId)..load(),
      child: const DynamicScreenRenderer(),
    );
  }
}
