import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/di/injection.dart';
import '../../../../core/utils/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

const _bg = Color(0xFF0D1117);
const _card = Color(0xFF161B22);
const _teal = Color(0xFF00B4D8);
const _border = Color(0xFF30363D);
const _textSecondary = Color(0xFF8B949E);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInicial || state is AuthErro) {
            context.go(RouteNames.login);
          }
        },
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Em breve 🚀',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, _) {
            final pulseScale = 1.0 + _pulseCtrl.value * 0.18;
            final pulseOpacity = 0.6 - _pulseCtrl.value * 0.45;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [_teal, Color(0xFF90E0EF)],
                        ).createShader(bounds),
                        child: const Text(
                          'comprai',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthCarregando;
                          return IconButton(
                            tooltip: 'Sair',
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _textSecondary,
                                    ),
                                  )
                                : const Icon(
                                    Icons.logout_rounded,
                                    color: _textSecondary,
                                    size: 22,
                                  ),
                            onPressed: isLoading
                                ? null
                                : () => context.read<AuthBloc>().add(
                                    const AuthSairSolicitado(),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _UserCard(),
                  const Spacer(flex: 2),
                  // Pulsing scan button
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulse ring
                      Transform.scale(
                        scale: pulseScale * 1.3,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _teal.withValues(
                                alpha: pulseOpacity * 0.5,
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Middle pulse ring
                      Transform.scale(
                        scale: pulseScale,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _teal.withValues(alpha: pulseOpacity),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Main button
                      GestureDetector(
                        onTap: () => context.push(RouteNames.scan),
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFF00C9EF), _teal],
                              radius: 0.85,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _teal.withValues(alpha: 0.45),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Toque para escanear uma NFC-e',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Aponte a câmera para o QR Code da nota fiscal',
                    style: TextStyle(color: _textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  // Bottom quick-access row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _QuickAction(
                          icon: Icons.history_rounded,
                          label: 'Histórico',
                          onTap: () => _showComingSoon(context),
                        ),
                        _QuickAction(
                          icon: Icons.list_alt_rounded,
                          label: 'Listas',
                          onTap: () => _showComingSoon(context),
                        ),
                        _QuickAction(
                          icon: Icons.map_rounded,
                          label: 'Mapa',
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};
    final name =
        (meta['full_name'] as String?)?.split(' ').first ??
        user?.email?.split('@').first ??
        'Usuário';
    final email = user?.email ?? '';
    final avatarUrl = meta['avatar_url'] as String?;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: _teal.withValues(alpha: 0.15),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: _teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $name!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(color: _textSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _teal, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: _textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
