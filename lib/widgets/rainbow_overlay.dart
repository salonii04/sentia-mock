import 'dart:math';
import 'package:flutter/material.dart';

/// Full-screen sunny / rainbow overlay rendered on the Garden Tab when
/// [ConversationMood.happyProposalTrack] is active.
///
/// Compositing layers:
///   1. Warm golden colour wash (breathes via [_glowCtrl])
///   2. Sun-glow radial gradient anchored to upper-right corner
///   3. Animating rainbow arc (fades in over 1.8 s via [_fadeCtrl])
///   4. Floating sparkle ✨ particles that pulse out-of-phase
///
/// Isolated inside a [RepaintBoundary] by the caller.
class RainbowOverlay extends StatefulWidget {
  const RainbowOverlay({super.key});

  @override
  State<RainbowOverlay> createState() => _RainbowOverlayState();
}

class _RainbowOverlayState extends State<RainbowOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── 1. Warm golden colour wash ─────────────────────────────
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) => Container(
            color: const Color(0xFFFFE066)
                .withOpacity(0.055 + 0.03 * _glowCtrl.value),
          ),
        ),

        // ── 2. Sun-glow (upper-right corner) ──────────────────────
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) => Positioned(
            top: -90,
            right: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFE566)
                        .withOpacity(0.28 + 0.16 * _glowCtrl.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── 3. Rainbow arc (fades in) ──────────────────────────────
        AnimatedBuilder(
          animation: _fadeAnim,
          builder: (_, __) => SizedBox.expand(
            child: CustomPaint(
              willChange: false,
              painter: _RainbowArcPainter(opacity: _fadeAnim.value),
            ),
          ),
        ),

        // ── 4. Sparkle particles ───────────────────────────────────
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) => _SparkleLayer(pulse: _glowCtrl.value),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rainbow arc — CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

class _RainbowArcPainter extends CustomPainter {
  final double opacity;
  const _RainbowArcPainter({required this.opacity});

  // Ordered from outermost band to innermost band.
  static const _colors = [
    Color(0xFFFF2222), // red
    Color(0xFFFF8800), // orange
    Color(0xFFFFEE00), // yellow
    Color(0xFF22CC44), // green
    Color(0xFF2255FF), // blue
    Color(0xFF8811EE), // violet
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Arc geometry:
    //   Center sits at 52% of height — slightly below mid-screen.
    //   Radius ≈ 60% of width → arc peaks near the top of the screen and
    //   touches the left/right edges, giving a classic rainbow silhouette.
    final cx = size.width * 0.50;
    final cy = size.height * 1.08;
    final baseRadius = size.width * 0.92;
    const bandWidth = 12.0;
    const bandGap = 13.5;

    for (int i = 0; i < _colors.length; i++) {
      final paint = Paint()
        ..color = _colors[i].withOpacity(opacity * 0.36)
        ..style = PaintingStyle.stroke
        ..strokeWidth = bandWidth
        ..strokeCap = StrokeCap.round;

      final radius = baseRadius - i * bandGap;
      final rect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: radius * 2,
        height: radius * 2,
      );

      // startAngle = π (left side), sweepAngle = -π
      // → counterclockwise from left, through top, to right = upper semicircle.
      canvas.drawArc(rect, pi, -pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RainbowArcPainter old) => old.opacity != opacity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkle layer — LayoutBuilder + fixed normalised positions
// ─────────────────────────────────────────────────────────────────────────────

class _SparkleLayer extends StatelessWidget {
  final double pulse;
  const _SparkleLayer({required this.pulse});

  // Normalised (x,y) positions — deliberately scattered across the upper sky.
  static const _positions = [
    Offset(0.12, 0.09),
    Offset(0.80, 0.06),
    Offset(0.52, 0.03),
    Offset(0.28, 0.16),
    Offset(0.68, 0.12),
    Offset(0.42, 0.21),
    Offset(0.88, 0.19),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Stack(
        children: _positions.asMap().entries.map((e) {
          // Alternate phase so not all sparkles blink together.
          final v = e.key.isEven ? pulse : 1.0 - pulse;
          return Positioned(
            left: e.value.dx * constraints.maxWidth - 10,
            top: e.value.dy * constraints.maxHeight - 10,
            child: Opacity(
              opacity: (0.30 + 0.70 * v).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.65 + 0.60 * v,
                child: const Text('✨', style: TextStyle(fontSize: 18)),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
