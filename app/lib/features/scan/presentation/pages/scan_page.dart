import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/route_names.dart';
import '../../domain/entities/nfce_data.dart';

const _card = Color(0xFF161B22);
const _teal = Color(0xFF00B4D8);
const _border = Color(0xFF30363D);
const _textSecondary = Color(0xFF8B949E);

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLineCtrl;
  bool _scanned = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || _loading) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null) return;

    setState(() {
      _scanned = true;
      _loading = true;
      _errorMessage = null;
    });

    try {
      final nfceData = await _consultarSefaz(rawValue);
      if (!mounted) return;
      await context.push(RouteNames.nfceConfirmacao, extra: nfceData);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _friendlyError(e));
    } finally {
      if (mounted) {
        setState(() {
          _scanned = false;
          _loading = false;
        });
      }
    }
  }

  Future<NfceData> _consultarSefaz(String rawValue) async {
    final response = await Supabase.instance.client.functions.invoke(
      'consultar-nfce',
      body: {'url': rawValue},
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Resposta vazia da Edge Function');
    }

    if (data is Map<String, dynamic> && data.containsKey('error')) {
      throw Exception(data['error']);
    }

    return NfceData.fromJson(data as Map<String, dynamic>);
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('44 dígitos') || msg.contains('não encontrada')) {
      return 'QR Code inválido. Certifique-se de escanear uma NFC-e.';
    }
    if (msg.contains('status 5') || msg.contains('status 4')) {
      return 'Portal da SEFAZ indisponível. Tente novamente em breve.';
    }
    if (msg.contains('timeout') || msg.contains('SocketException')) {
      return 'Sem conexão com a internet.';
    }
    return 'Erro ao consultar NFC-e. Tente novamente.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera background
          MobileScanner(onDetect: _onDetect),
          // Grain overlay
          CustomPaint(painter: _CameraGrainPainter(), size: Size.infinite),
          // Spotlight overlay with scan line
          _SpotlightOverlay(
            scanLine: _scanLineCtrl,
            isLoading: _loading,
            errorMessage: _errorMessage,
            onDismissError: () => setState(() => _errorMessage = null),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Escanear NFC-e',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spotlight overlay
// ---------------------------------------------------------------------------
class _SpotlightOverlay extends StatelessWidget {
  const _SpotlightOverlay({
    required this.scanLine,
    required this.isLoading,
    required this.errorMessage,
    required this.onDismissError,
  });

  final AnimationController scanLine;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onDismissError;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        const cutoutSize = 220.0;
        const cutoutRadius = 20.0;
        final cutoutLeft = (w - cutoutSize) / 2;
        final cutoutTop = (h - cutoutSize) / 2;

        return Stack(
          children: [
            // Semi-transparent overlay with cutout
            ClipPath(
              clipper: _CutoutClipper(
                cutoutRect: Rect.fromLTWH(
                  cutoutLeft,
                  cutoutTop,
                  cutoutSize,
                  cutoutSize,
                ),
                radius: cutoutRadius,
              ),
              child: Container(color: Colors.black.withValues(alpha: 0.65)),
            ),
            // Teal border around cutout
            Positioned(
              left: cutoutLeft - 1.5,
              top: cutoutTop - 1.5,
              child: Container(
                width: cutoutSize + 3,
                height: cutoutSize + 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cutoutRadius + 1.5),
                  border: Border.all(
                    color: isLoading
                        ? Colors.white.withValues(alpha: 0.4)
                        : _teal.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Animated scan line (hidden while loading)
            if (!isLoading)
              AnimatedBuilder(
                animation: scanLine,
                builder: (context, _) {
                  final y = cutoutTop + scanLine.value * cutoutSize;
                  return Positioned(
                    left: cutoutLeft + 8,
                    top: y,
                    width: cutoutSize - 16,
                    height: 2.5,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _teal.withValues(alpha: 0),
                            _teal,
                            _teal.withValues(alpha: 0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _teal.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            // Loading spinner inside cutout
            if (isLoading)
              Positioned(
                left: cutoutLeft,
                top: cutoutTop,
                width: cutoutSize,
                height: cutoutSize,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: _teal,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            // Bottom sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                decoration: const BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: errorMessage != null
                    ? _ErrorSheet(
                        message: errorMessage!,
                        onDismiss: onDismissError,
                      )
                    : _StatusSheet(isLoading: isLoading),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusSheet extends StatelessWidget {
  const _StatusSheet({required this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: _teal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isLoading ? Colors.white : _teal,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isLoading ? 'Consultando SEFAZ…' : 'Buscando QR Code...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isLoading
              ? 'Aguarde, buscando dados da nota fiscal'
              : 'Mantenha a câmera estável e bem iluminada',
          style: const TextStyle(color: _textSecondary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorSheet extends StatelessWidget {
  const _ErrorSheet({required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Tentar novamente',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Painters & Clippers
// ---------------------------------------------------------------------------
class _CutoutClipper extends CustomClipper<Path> {
  const _CutoutClipper({required this.cutoutRect, required this.radius});
  final Rect cutoutRect;
  final double radius;

  @override
  Path getClip(Size size) {
    final outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, Radius.circular(radius)));
    return Path.combine(PathOperation.difference, outer, inner);
  }

  @override
  bool shouldReclip(_) => false;
}

class _CameraGrainPainter extends CustomPainter {
  final math.Random _rng = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.02);
    for (var i = 0; i < 500; i++) {
      canvas.drawCircle(
        Offset(_rng.nextDouble() * size.width, _rng.nextDouble() * size.height),
        _rng.nextDouble() * 1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
