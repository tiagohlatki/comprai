import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/login_prototype_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../utils/route_names.dart';

/// Notifica o GoRouter sempre que o estado de autenticação do Supabase mudar.
/// Isso torna o redirect reativo — sem depender de timing.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authNotifier = _AuthChangeNotifier();

final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final location = state.matchedLocation;

    // Rota raiz: ponto de aterrissagem do OAuth — encaminha para o destino certo
    if (location == '/') {
      return isLoggedIn ? RouteNames.home : RouteNames.login;
    }

    final isAuthRoute =
        location == RouteNames.login ||
        location == RouteNames.register ||
        location == '/prototype';

    if (isLoggedIn && isAuthRoute) return RouteNames.home;
    if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      name: RouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: RouteNames.home,
      name: RouteNames.home,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Home — em construção'))),
    ),
    GoRoute(
      path: '/prototype',
      builder: (context, state) => const LoginPrototypePage(),
    ),
  ],
);
