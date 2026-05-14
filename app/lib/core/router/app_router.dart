import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../utils/route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final isAuthRoute =
        state.matchedLocation == RouteNames.login ||
        state.matchedLocation == RouteNames.register;

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
  ],
);
