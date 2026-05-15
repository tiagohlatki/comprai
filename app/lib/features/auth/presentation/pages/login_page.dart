import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_dark_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAutenticado) context.go(RouteNames.home);
          if (state is AuthErro) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthCarregando;
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AuthDarkBackground(
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 2),
                            const AuthLogo(),
                            const Spacer(flex: 2),
                            GoogleSignInButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.read<AuthBloc>().add(
                                      const AuthGoogleLoginSolicitado(),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            const AuthDividerOr(),
                            const SizedBox(height: 16),
                            AuthDarkInput(
                              controller: _emailController,
                              label: 'E-mail',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Informe seu e-mail';
                                }
                                if (!v.contains('@')) return 'E-mail inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            AuthDarkInput(
                              controller: _senhaController,
                              label: 'Senha',
                              icon: Icons.lock_outlined,
                              obscure: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Informe sua senha';
                                }
                                if (v.length < 6) return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AuthGradientButton(
                              label: 'Entrar',
                              isLoading: isLoading,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                          AuthLoginSolicitado(
                                            email: _emailController.text.trim(),
                                            senha: _senhaController.text,
                                          ),
                                        );
                                      }
                                    },
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.go(RouteNames.register),
                              child: const Text(
                                'Não tem conta? Cadastre-se',
                                style: TextStyle(color: Color(0xFF6EE7B7)),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
