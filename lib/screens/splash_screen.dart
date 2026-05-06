import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Scale-in: escudo aparece do zero
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  // Draw: traçado do checkmark
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkAnim;

  // Sheen: brilho deslizando pelo escudo
  late final AnimationController _sheenCtrl;
  late final Animation<double> _sheenAnim;

  // Glow rim: pulso de luz na borda
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    // 1) Scale-in (0ms → 350ms)
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: Curves.easeOutBack,
    );

    // 2) Check draw (350ms → 800ms)
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _checkAnim = CurvedAnimation(
      parent: _checkCtrl,
      curve: Curves.easeInOut,
    );

    // 3) Sheen sweep (580ms → 1100ms)
    _sheenCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sheenAnim = CurvedAnimation(
      parent: _sheenCtrl,
      curve: Curves.easeOut,
    );

    // 4) Glow pulse (800ms → 1300ms)
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _glowAnim = CurvedAnimation(
      parent: _glowCtrl,
      curve: Curves.easeOut,
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // 1) Escudo entra
    await _scaleCtrl.forward();

    // 2) Check começa a desenhar (start paralelo com sheen ligeiramente depois)
    _checkCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _sheenCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 250));

    // 3) Glow no rim quando check termina
    _glowCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 350));

    // 4) Aguarda um momento e navega
    await Future.delayed(const Duration(milliseconds: 300));
    _goToNextScreen();
  }

  void _goToNextScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthWrapper(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _checkCtrl.dispose();
    _sheenCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnim,
            _checkAnim,
            _sheenAnim,
            _glowAnim,
          ]),
          builder: (context, _) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(
                opacity: _scaleAnim.value.clamp(0.0, 1.0),
                child: SizedBox(
                  width: 220,
                  height: 260,
                  child: CustomPaint(
                    painter: _EthosShieldPainter(
                      checkProgress: _checkAnim.value,
                      sheenProgress: _sheenAnim.value,
                      glowProgress: _glowAnim.value,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EthosShieldPainter extends CustomPainter {
  final double checkProgress;
  final double sheenProgress;
  final double glowProgress;

  _EthosShieldPainter({
    required this.checkProgress,
    required this.sheenProgress,
    required this.glowProgress,
  });

  Path _shieldPath(Size size) {
    final cx = size.width / 2;
    final path = Path();
    path.moveTo(cx, size.height * 0.04);
    path.lineTo(size.width * 0.96, size.height * 0.18);
    path.lineTo(size.width * 0.96, size.height * 0.52);
    path.quadraticBezierTo(
        size.width * 0.96, size.height * 0.85, cx, size.height * 0.97);
    path.quadraticBezierTo(size.width * 0.04, size.height * 0.85,
        size.width * 0.04, size.height * 0.52);
    path.lineTo(size.width * 0.04, size.height * 0.18);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final shieldPath = _shieldPath(size);
    final cx = size.width / 2;

    // ── Outer rim (silver/white) ──────────────────────────────────────────────
    final rimPaint = Paint()
      ..color = const Color(0xFFD0DDD0)
      ..style = PaintingStyle.fill;

    final rimScaleMatrix = Matrix4.identity()
      ..translate(cx, size.height / 2)
      ..scale(1.04, 1.04)
      ..translate(-cx, -size.height / 2);
    canvas.drawPath(
      shieldPath.transform(rimScaleMatrix.storage),
      rimPaint,
    );

    // ── Glow rim ──────────────────────────────────────────────────────────────
    if (glowProgress > 0) {
      final glowOpacity = (sin(glowProgress * pi) * 0.9).clamp(0.0, 1.0);
      final glowPaint = Paint()
        ..color = const Color(0xFF44FF55).withOpacity(glowOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 + glowProgress * 6
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, 12 * glowProgress);
      canvas.drawPath(shieldPath, glowPaint);
    }

    // ── Shield body ───────────────────────────────────────────────────────────
    final bodyPaint = Paint()
      ..color = const Color(0xFF111E14)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, bodyPaint);

    // ── Left darker half ──────────────────────────────────────────────────────
    canvas.save();
    canvas.clipPath(shieldPath);
    final leftHalf = Path()
      ..moveTo(cx, 0)
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(cx, size.height)
      ..close();
    canvas.drawPath(
      leftHalf,
      Paint()
        ..color = const Color(0xFF0A1510).withOpacity(0.55)
        ..style = PaintingStyle.fill,
    );

    // ── Document lines ────────────────────────────────────────────────────────
    final docRect = Rect.fromLTWH(
      size.width * 0.29,
      size.height * 0.28,
      size.width * 0.42,
      size.height * 0.38,
    );
    final docPaint = Paint()
      ..color = const Color(0xFF172418).withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(docRect, const Radius.circular(4)),
      docPaint,
    );
    final linePaint = Paint()
      ..color = const Color(0xFF1D5C28).withOpacity(0.7)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    const lineCount = 5;
    for (int i = 0; i < lineCount; i++) {
      final y = docRect.top + 16 + i * 14.0;
      final widthFraction = 0.55 + (i % 3) * 0.08;
      canvas.drawLine(
        Offset(docRect.left + 10, y),
        Offset(docRect.left + 10 + docRect.width * widthFraction, y),
        linePaint..color = const Color(0xFF1D5C28).withOpacity(0.65 - i * 0.07),
      );
    }

    // ── Sheen sweep ───────────────────────────────────────────────────────────
    if (sheenProgress > 0 && sheenProgress < 1) {
      final sheenX = -size.width * 0.5 + sheenProgress * size.width * 2.2;
      final sheenRect =
          Rect.fromLTWH(sheenX, 0, size.width * 0.38, size.height);
      final sheenGrad = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0.28),
          Colors.white.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      final sheenPaint = Paint()..shader = sheenGrad.createShader(sheenRect);

      // Skew the sheen slightly
      canvas.save();
      canvas.transform(
        (Matrix4.identity()..setEntry(0, 1, -0.2)).storage,
      );
      canvas.drawRect(sheenRect, sheenPaint);
      canvas.restore();
    }

    canvas.restore(); // end clip

    // ── Check mark ────────────────────────────────────────────────────────────
    if (checkProgress > 0) {
      // Define checkmark points
      final p0 = Offset(size.width * 0.27, size.height * 0.50);
      final p1 = Offset(size.width * 0.44, size.height * 0.64);
      final p2 = Offset(size.width * 0.73, size.height * 0.34);

      // Total path length approx (for progress interpolation)
      final seg1Len = (p1 - p0).distance;
      final seg2Len = (p2 - p1).distance;
      final totalLen = seg1Len + seg2Len;

      Offset currentEnd;
      if (checkProgress <= seg1Len / totalLen) {
        final t = checkProgress / (seg1Len / totalLen);
        currentEnd = Offset.lerp(p0, p1, t)!;
      } else {
        final t = (checkProgress - seg1Len / totalLen) / (seg2Len / totalLen);
        currentEnd = Offset.lerp(p1, p2, t.clamp(0.0, 1.0))!;
      }

      // Glow layer
      final glowCheckPaint = Paint()
        ..color = const Color(0xFF44FF55).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final checkPath = Path()..moveTo(p0.dx, p0.dy);
      if (checkProgress > seg1Len / totalLen) {
        checkPath.lineTo(p1.dx, p1.dy);
        checkPath.lineTo(currentEnd.dx, currentEnd.dy);
      } else {
        checkPath.lineTo(currentEnd.dx, currentEnd.dy);
      }
      canvas.drawPath(checkPath, glowCheckPaint);

      // Main green check
      final checkPaint = Paint()
        ..color = const Color(0xFF33EE44)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(checkPath, checkPaint);

      // Bright inner line
      final innerPaint = Paint()
        ..color = const Color(0xAABBFFCC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(checkPath, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EthosShieldPainter old) =>
      old.checkProgress != checkProgress ||
      old.sheenProgress != sheenProgress ||
      old.glowProgress != glowProgress;
}
