import 'dart:math';
import 'package:flutter/material.dart';

/// A full-screen animated weather overlay that renders falling rain drops,
/// a rising mist layer at the bottom, and a fountain-area mist puff.
/// Wrap this in [RepaintBoundary] to isolate its repaints from the rest of the
/// widget tree.
class RainOverlay extends StatefulWidget {
  const RainOverlay({super.key});

  @override
  State<RainOverlay> createState() => _RainOverlayState();
}

class _RainOverlayState extends State<RainOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _rainCtrl;
  late final AnimationController _mistCtrl;
  late final List<_Drop> _drops;

  @override
  void initState() {
    super.initState();

    // Fixed seed → consistent rain pattern every time (no jitter on rebuild)
    final rng = Random(1337);
    _drops = List.generate(90, (_) {
      return _Drop(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        speed: 0.22 + rng.nextDouble() * 0.55,
        opacity: 0.28 + rng.nextDouble() * 0.38,
        length: 9.0 + rng.nextDouble() * 11.0,
        width: rng.nextInt(3) == 0 ? 1.5 : 0.9,
      );
    });

    _rainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();

    _mistCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rainCtrl.dispose();
    _mistCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Dark overcast colour wash ───────────────────────────────
        Container(color: const Color(0xFF1C2B3A).withOpacity(0.28)),

        // ── Rain drops (CustomPainter, repaints every frame) ────────
        AnimatedBuilder(
          animation: _rainCtrl,
          builder: (_, __) => SizedBox.expand(
            child: CustomPaint(
              willChange: true,
              painter: _RainPainter(
                progress: _rainCtrl.value,
                drops: _drops,
              ),
            ),
          ),
        ),

        // ── Mist rising from bottom ──────────────────────────────────
        AnimatedBuilder(
          animation: _mistCtrl,
          builder: (_, __) {
            final v = _mistCtrl.value;
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.blueGrey.withOpacity(0.20 + 0.10 * v),
                      Colors.white.withOpacity(0.06 * v),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            );
          },
        ),

        // ── Fountain mist puff (centred, drifts up slightly) ────────
        AnimatedBuilder(
          animation: _mistCtrl,
          builder: (_, __) {
            final v = _mistCtrl.value;
            return Positioned(
              bottom: 140 + 12 * v, // subtle upward drift
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 130,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(55),
                    color: Colors.white.withOpacity(0.04 + 0.05 * v),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.07 * v),
                        blurRadius: 45,
                        spreadRadius: 22,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data & Painter
// ─────────────────────────────────────────────────────────────────────────────

class _Drop {
  final double x;
  final double y;
  final double speed;
  final double opacity;
  final double length;
  final double width;

  const _Drop({
    required this.x,
    required this.y,
    required this.speed,
    required this.opacity,
    required this.length,
    required this.width,
  });
}

class _RainPainter extends CustomPainter {
  final double progress;
  final List<_Drop> drops;

  const _RainPainter({required this.progress, required this.drops});

  @override
  void paint(Canvas canvas, Size size) {
    for (final drop in drops) {
      final paint = Paint()
        ..color = const Color(0xFFC5DCE8).withOpacity(drop.opacity)
        ..strokeWidth = drop.width
        ..strokeCap = StrokeCap.round;

      final x = drop.x * size.width;
      // Loop the Y continuously as progress advances
      final y = ((drop.y + progress * drop.speed) % 1.0) * size.height;

      // Slight diagonal tilt for a natural, wind-blown look
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 1.8, y + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RainPainter old) => old.progress != progress;
}
