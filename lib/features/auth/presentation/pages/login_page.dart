import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_logo.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@saasify.io');
  final _passwordController = TextEditingController(text: 'password');
  bool _obscure = true;

  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = !context.isCompact;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ColoredBox(
              color: AppColors.accent,
              child: SizedBox(height: 4),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? AppSpacing.xxl : AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthAuthenticating;
                          final error =
                              state is AuthFailure ? state.message : null;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // group.svg mark
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: AppLogoMark(size: 64),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              // Wordmark lockup
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: AppLogoWordmark(height: 44),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Sign in to the admin workspace',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppTextField(
                                      controller: _emailController,
                                      label: 'Work email',
                                      hint: 'you@company.com',
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      prefixIcon:
                                          const Icon(Icons.mail_outline),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Email is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    AppTextField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      obscureText: _obscure,
                                      textInputAction: TextInputAction.done,
                                      prefixIcon:
                                          const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                      onSubmitted: (_) => _submit(),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    if (error != null) ...[
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        error,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: AppSpacing.xl),
                                    AppButton(
                                      label: 'Sign in',
                                      expand: true,
                                      isLoading: loading,
                                      onPressed: loading ? null : _submit,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Mock auth — any non-empty credentials work.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppColors.inkTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().clearFailure();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
}
