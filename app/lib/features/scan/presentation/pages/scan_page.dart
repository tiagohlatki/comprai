import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
    if (_scanned) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null) return;

    _scanned = true;

    final chave = rawValue.length == 44
        ? rawValue
        : rawValue.padRight(44, '0').substring(0, 44);

    final nfceData = NfceData(
      chave: chave,
      estabelecimento: const NfceEstabelecimento(
        cnpj: '04.614.516/0001-98',
        nome: 'Supermercado Condor',
        endereco: 'Av. Brasil, 123 - Maringá/PR',
        cidade: 'Maringá',
        estado: 'PR',
      ),
      itens: const [
        NfceItem(
          nome: 'Arroz Tio João 5kg',
          quantidade: 1,
          precoUnitario: 24.90,
          precoTotal: 24.90,
        ),
        NfceItem(
          nome: 'Feijão Carioca 1kg',
          quantidade: 1,
          precoUnitario: 8.75,
          precoTotal: 8.75,
        ),
        NfceItem(
          nome: 'Óleo de Soja 900ml',
          quantidade: 1,
          precoUnitario: 7.49,
          precoTotal: 7.49,
        ),
        NfceItem(
          nome: 'Leite Integral 1L',
          ean: '7891000100103',
          quantidade: 2,
          precoUnitario: 4.29,
          precoTotal: 8.58,
        ),
      ],
      total: 49.72,
      dataCompra: DateTime.now(),
    );

    await context.push(RouteNames.nfceConfirmacao, extra: nfceData);
    _scanned = false;
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
          _SpotlightOverlay(scanLine: _scanLineCtrl),
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

class _SpotlightOverlay extends StatelessWidget {
  const _SpotlightOverlay({required this.scanLine});
  final AnimationController scanLine;

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
                    color: _teal.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Animated scan line
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
                child: Column(
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
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _teal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Buscando QR Code...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mantenha a câmera estável e bem iluminada',
                      style: TextStyle(color: _textSecondary, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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
