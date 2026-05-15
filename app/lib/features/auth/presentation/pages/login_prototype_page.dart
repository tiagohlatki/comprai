import 'package:flutter/material.dart';

class LoginPrototypePage extends StatefulWidget {
  const LoginPrototypePage({super.key});

  @override
  State<LoginPrototypePage> createState() => _LoginPrototypePageState();
}

class _LoginPrototypePageState extends State<LoginPrototypePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protótipos de login'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: '1 · Dark'),
            Tab(text: '2 · Colorido'),
            Tab(text: '3 · Material You'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [_StyleDark(), _StyleColorido(), _StyleMaterialYou()],
      ),
    );
  }
}

// ── Style 1: Moderno & minimalista (dark) ────────────────────────────────────

class _StyleDark extends StatelessWidget {
  const _StyleDark();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D0D1A), Color(0xFF1A1A3E)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
                ).createShader(bounds),
                child: const Text(
                  'comprai',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Compare preços. Economize de verdade.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              _GoogleButtonDark(),
              const SizedBox(height: 16),
              const _DividerOr(dark: true),
              const SizedBox(height: 16),
              _DarkInput(label: 'E-mail', icon: Icons.email_outlined),
              const SizedBox(height: 12),
              _DarkInput(
                label: 'Senha',
                icon: Icons.lock_outlined,
                obscure: true,
              ),
              const SizedBox(height: 24),
              _GradientButton(label: 'Entrar'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
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
    );
  }
}

class _GoogleButtonDark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF374151)),
        backgroundColor: const Color(0xFF111827),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoogleLogo(),
          const SizedBox(width: 12),
          const Text('Continuar com Google', style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  const _GradientButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _DarkInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscure;
  const _DarkInput({
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(icon, color: const Color(0xFF6EE7B7), size: 20),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6EE7B7)),
        ),
      ),
    );
  }
}

// ── Style 2: Clean & colorido ────────────────────────────────────────────────

class _StyleColorido extends StatelessWidget {
  const _StyleColorido();

  static const _green = Color(0xFF00C48C);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_rounded,
                    size: 44,
                    color: _green,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'comprai',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: _green,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Compare preços e economize nas compras',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _GoogleButtonColorido(),
              const SizedBox(height: 20),
              const _DividerOr(dark: false),
              const SizedBox(height: 20),
              TextFormField(
                decoration: _inputDeco('E-mail', Icons.email_outlined),
              ),
              const SizedBox(height: 14),
              TextFormField(
                obscureText: true,
                decoration: _inputDeco('Senha', Icons.lock_outlined),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(color: _green, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem conta? ',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: _green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: _green),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}

class _GoogleButtonColorido extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1F1F1F),
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoogleLogo(),
          const SizedBox(width: 10),
          const Text(
            'Continuar com Google',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Style 3: Material You ────────────────────────────────────────────────────

class _StyleMaterialYou extends StatelessWidget {
  const _StyleMaterialYou();

  @override
  Widget build(BuildContext context) {
    final cs = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00C48C),
      brightness: Brightness.light,
    );
    return Theme(
      data: ThemeData(colorScheme: cs, useMaterial3: true),
      child: Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          return ColoredBox(
            color: cs.surface,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'comprai',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                        letterSpacing: -1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compare preços e economize nas compras',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Card(
                      elevation: 0,
                      color: cs.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton.tonal(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _GoogleLogo(),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Continuar com Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const _DividerOr(dark: false),
                            const SizedBox(height: 20),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: cs.surface,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: cs.surface,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Não tem conta? Cadastre-se'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────────────────────

class _DividerOr extends StatelessWidget {
  final bool dark;
  const _DividerOr({required this.dark});

  @override
  Widget build(BuildContext context) {
    final color = dark ? const Color(0xFF374151) : Colors.grey.shade300;
    final textColor = dark ? const Color(0xFF6B7280) : Colors.grey.shade400;
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: TextStyle(color: textColor, fontSize: 13)),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final path = Path();

    void arc(Color color, double startAngle, double sweepAngle) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.85);
      path.reset();
      path.moveTo(cx, cy);
      path.arcTo(rect, startAngle, sweepAngle, false);
      path.close();
      canvas.drawPath(path, paint);
    }

    arc(const Color(0xFFEA4335), -1.57, 1.57);
    arc(const Color(0xFFFBBC05), 0, 1.57);
    arc(const Color(0xFF34A853), 1.57, 1.57);
    arc(const Color(0xFF4285F4), 3.14, 1.57);

    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, holePaint);

    final clipRect = Rect.fromLTRB(cx, cy - r, cx + r, cy);
    canvas.clipRect(clipRect);
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTRB(cx, cy - r * 0.3, cx + r, cy + r * 0.3),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
