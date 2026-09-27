import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/app/router/app_router.dart';
import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/settings/presentation/bloc/company_logo_cubit.dart';
import 'package:saasify/features/settings/presentation/bloc/workspace_settings_cubit.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

class SaasifyApp extends StatefulWidget {
  const SaasifyApp({
    super.key,
    this.authCubit,
    this.ticketListCubit,
    this.ticketConfigCubit,
    this.shellCubit,
    this.companyLogoCubit,
    this.workspaceSettingsCubit,
  });

  final AuthCubit? authCubit;
  final TicketListCubit? ticketListCubit;
  final TicketConfigCubit? ticketConfigCubit;
  final ShellCubit? shellCubit;
  final CompanyLogoCubit? companyLogoCubit;
  final WorkspaceSettingsCubit? workspaceSettingsCubit;

  @override
  State<SaasifyApp> createState() => _SaasifyAppState();
}

class _SaasifyAppState extends State<SaasifyApp> {
  late final AuthCubit _authCubit;
  late final TicketListCubit _ticketListCubit;
  late final TicketConfigCubit _ticketConfigCubit;
  late final ShellCubit _shellCubit;
  late final CompanyLogoCubit _companyLogoCubit;
  late final WorkspaceSettingsCubit _workspaceSettingsCubit;
  late final AuthRouterRefresh _authRefresh;
  late final GoRouter _router;
  late final bool _ownsAuth;
  late final bool _ownsTickets;
  late final bool _ownsConfig;
  late final bool _ownsShell;
  late final bool _ownsCompanyLogo;
  late final bool _ownsWorkspaceSettings;

  @override
  void initState() {
    super.initState();
    _ownsAuth = widget.authCubit == null;
    _ownsTickets = widget.ticketListCubit == null;
    _ownsConfig = widget.ticketConfigCubit == null;
    _ownsShell = widget.shellCubit == null;
    _ownsCompanyLogo = widget.companyLogoCubit == null;
    _ownsWorkspaceSettings = widget.workspaceSettingsCubit == null;
    _authCubit = widget.authCubit ?? AuthCubit();
    _ticketListCubit = widget.ticketListCubit ?? TicketListCubit();
    _ticketConfigCubit = widget.ticketConfigCubit ?? TicketConfigCubit();
    _shellCubit = widget.shellCubit ?? ShellCubit();
    _companyLogoCubit = widget.companyLogoCubit ?? CompanyLogoCubit();
    _workspaceSettingsCubit =
        widget.workspaceSettingsCubit ?? WorkspaceSettingsCubit();
    _authRefresh = AuthRouterRefresh(_authCubit);
    _router = createAppRouter(
      authCubit: _authCubit,
      refreshListenable: _authRefresh,
    );
  }

  @override
  void dispose() {
    _authRefresh.dispose();
    if (_ownsAuth) _authCubit.close();
    if (_ownsTickets) _ticketListCubit.close();
    if (_ownsConfig) _ticketConfigCubit.close();
    if (_ownsShell) _shellCubit.close();
    if (_ownsCompanyLogo) _companyLogoCubit.close();
    if (_ownsWorkspaceSettings) _workspaceSettingsCubit.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _ticketListCubit),
        BlocProvider.value(value: _ticketConfigCubit),
        BlocProvider.value(value: _shellCubit),
        BlocProvider.value(value: _companyLogoCubit),
        BlocProvider.value(value: _workspaceSettingsCubit),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
