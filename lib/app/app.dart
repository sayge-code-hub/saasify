import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/app/router/app_router.dart';
import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';

class SaasifyApp extends StatelessWidget {
  SaasifyApp({super.key, GoRouter? router})
      : _router = router ?? createAppRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShellCubit(),
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
