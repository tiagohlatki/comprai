import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  // No web, o Supabase agenda o processamento do token OAuth de forma assíncrona.
  // Aguardamos o evento signedIn antes de iniciar o app para que o GoRouter
  // já enxergue a sessão ativa no primeiro redirect.
  if (kIsWeb) {
    final uri = Uri.base;
    final hasOAuthTokens =
        uri.fragment.contains('access_token') ||
        uri.queryParameters.containsKey('code');

    if (hasOAuthTokens &&
        Supabase.instance.client.auth.currentSession == null) {
      try {
        await Supabase.instance.client.auth.onAuthStateChange
            .firstWhere((e) => e.event == AuthChangeEvent.signedIn)
            .timeout(const Duration(seconds: 10));
      } catch (_) {
        // Timeout ou falha — continua normalmente para a tela de login
      }
    }
  }

  await configureDependencies();

  runApp(const CompraiApp());
}

class CompraiApp extends StatelessWidget {
  const CompraiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'comprai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A6B3C)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
