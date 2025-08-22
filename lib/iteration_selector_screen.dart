import 'package:flutter/material.dart';
import 'dart:math' as math;

class IterationSelectorScreen extends StatefulWidget {
  final Function(int) onIterationsSelected;
  final bool isDarkMode;
  final Function toggleTheme;

  const IterationSelectorScreen({
    Key? key,
    required this.onIterationsSelected,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  State<IterationSelectorScreen> createState() => _IterationSelectorScreenState();
}

class _IterationSelectorScreenState extends State<IterationSelectorScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  double _currentRotation = 0;
  int _selectedIterations = 50; // Valor por defecto
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationController.addListener(() {
      setState(() {
        _currentRotation = _rotationAnimation.value;
        _selectedIterations = _calculateIterationsFromRotation(_currentRotation);
      });
    });

    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
        _pulseController.repeat(reverse: true);
      }
    });

    // Iniciar animación de pulso sutil
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int _calculateIterationsFromRotation(double rotation) {
    const totalNumbers = 190; // 10 a 199
    const startNumber = 10;
    
    double normalizedRotation = (rotation % (2 * math.pi)) / (2 * math.pi);
    int index = (normalizedRotation * totalNumbers).floor();
    
    return startNumber + index;
  }

  void _spinPolygon() {
    if (_isSpinning) return;
    
    setState(() {
      _isSpinning = true;
    });

    _pulseController.stop();

    double randomSpins = 4 + math.Random().nextDouble() * 6;
    double targetRotation = _currentRotation + (randomSpins * 2 * math.pi);

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutCubic,
    ));

    _rotationController.reset();
    _rotationController.forward();
  }

  void _startGame() {
    widget.onIterationsSelected(_selectedIterations);
  }

  String _getDifficultyText(int iterations) {
    if (iterations < 30) return "Muy Fácil";
    if (iterations < 60) return "Fácil";
    if (iterations < 100) return "Medio";
    if (iterations < 150) return "Difícil";
    return "Muy Difícil";
  }

  Color _getDifficultyColor() {
    if (_selectedIterations < 30) return Colors.green;
    if (_selectedIterations < 60) return Colors.lightGreen;
    if (_selectedIterations < 100) return Colors.orange;
    if (_selectedIterations < 150) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDarkMode
                  ? [
                      const Color(0xFF121829),
                      const Color(0xFF1E293B),
                    ]
                  : [
                      const Color(0xFFF5F7FA),
                      const Color(0xFFE9EDF5),
                    ],
            ),
          ),
          child: Column(
            children: [
              // Header con toggle theme
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => widget.toggleTheme(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (!widget.isDarkMode)
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.1),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                          ],
                        ),
                        child: Icon(
                          widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Título
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      'SUDOKU',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 8,
                      ),
                    ),
                    Text(
                      'Selecciona las iteraciones',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor.withValues(alpha:0.7),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Info de iteraciones seleccionadas
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            if (!widget.isDarkMode)
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.1),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Iteraciones: $_selectedIterations',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor().withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _getDifficultyColor(),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _getDifficultyText(_selectedIterations),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getDifficultyColor(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Polígono selector
                      GestureDetector(
                        onTap: _spinPolygon,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _scaleAnimation,
                            _pulseAnimation,
                          ]),
                          builder: (context, child) {
                            double scale = _scaleAnimation.value;
                            if (!_isSpinning) {
                              scale *= _pulseAnimation.value;
                            }
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(alpha:0.3),
                                      blurRadius: _isSpinning ? 30 : 15,
                                      spreadRadius: _isSpinning ? 5 : 2,
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  size: const Size(280, 280),
                                  painter: IterationPolygonPainter(
                                    rotation: _currentRotation,
                                    isDarkMode: widget.isDarkMode,
                                    isSpinning: _isSpinning,
                                    selectedIterations: _selectedIterations,
                                    colorScheme: colorScheme,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Botón girar
                      ElevatedButton(
                        onPressed: _isSpinning ? null : _spinPolygon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: _isSpinning ? 0 : 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSpinning) ...[
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ] else ...[
                              const Icon(Icons.casino, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _isSpinning ? 'Girando...' : 'Girar Selector',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón comenzar juego
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'COMENZAR JUEGO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IterationPolygonPainter extends CustomPainter {
  final double rotation;
  final bool isDarkMode;
  final bool isSpinning;
  final int selectedIterations;
  final ColorScheme colorScheme;

  IterationPolygonPainter({
    required this.rotation,
    required this.isDarkMode,
    required this.isSpinning,
    required this.selectedIterations,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    const sides = 190;

    // Colores principales
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final surfaceColor = colorScheme.surface;

    // Paint para el fondo principal
    final backgroundPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;

    // Paint para el borde exterior
    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Dibujar círculo de fondo
    canvas.drawCircle(center, radius, backgroundPaint);

    // Dibujar segmentos individuales
    for (int i = 0; i < sides; i++) {
      const segmentAngle = 2 * math.pi / sides;
      final startAngle = (segmentAngle * i) + rotation;
       const sweepAngle = segmentAngle * 0.9;

      int segmentIteration = 10 + i;
      
      // Determinar color del segmento
      Color segmentColor;
      if (segmentIteration == selectedIterations && !isSpinning) {
        segmentColor = secondaryColor;
      } else {
        double factor = i / sides;
        segmentColor = Color.lerp(
          primaryColor.withValues(alpha:0.2),
          primaryColor.withValues(alpha:0.6),
          factor,
        )!;
      }

      final segmentPaint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        segmentPaint,
      );
    }

    // Borde exterior
    canvas.drawCircle(center, radius, borderPaint);

    // Círculo central
    final centerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, centerPaint);

    // Círculo central interno
    final centerInnerPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerInnerPaint);

    // Indicador superior (flecha)
    if (!isSpinning) {
      final indicatorPaint = Paint()
        ..color = secondaryColor
        ..style = PaintingStyle.fill;

      final indicatorPath = Path();
      final tipY = center.dy - radius - 25;
      final baseY = center.dy - radius - 10;
      
      indicatorPath.moveTo(center.dx, tipY);
      indicatorPath.lineTo(center.dx - 12, baseY);
      indicatorPath.lineTo(center.dx + 12, baseY);
      indicatorPath.close();

      canvas.drawPath(indicatorPath, indicatorPaint);

      // Sombra del indicador
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha:0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawPath(indicatorPath, shadowPaint);
    }

    // Efecto de brillo cuando gira
    if (isSpinning) {
      final glowPaint = Paint()
        ..color = primaryColor.withValues(alpha:0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(center, radius + 8, glowPaint);
    }

    // Líneas radiales decorativas
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha:0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      final angle = (2 * math.pi * i / 12) + rotation * 0.3;
      final startX = center.dx + (radius - 20) * math.cos(angle);
      final startY = center.dy + (radius - 20) * math.sin(angle);
      final endX = center.dx + (radius - 5) * math.cos(angle);
      final endY = center.dy + (radius - 5) * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}