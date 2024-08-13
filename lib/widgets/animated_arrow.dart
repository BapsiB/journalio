import 'package:flutter/material.dart';

class AnimatedArrow extends StatefulWidget {
  final int selectedIndex;

  const AnimatedArrow({Key? key, required this.selectedIndex})
      : super(key: key);

  @override
  _AnimatedArrowState createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _updatePosition();
  }

  @override
  void didUpdateWidget(AnimatedArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _updatePosition();
    }
  }

  void _updatePosition() {
    final newPosition = widget.selectedIndex / 6;
    _animation = Tween<double>(
      begin: _animation.value,
      end: newPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth / 7;
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final arrowPosition = barWidth * (_animation.value * 6 + 0.5);
            return Container(
              width: constraints.maxWidth,
              height: 20,
              child: Stack(
                children: [
                  Positioned(
                    left: arrowPosition - 5, // Center the 30px wide arrow
                    child: CustomPaint(
                      size: Size(10, 6),
                      painter: ArrowPainter(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 177, 202, 223)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
