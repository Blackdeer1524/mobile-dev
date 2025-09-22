import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class AnimationControllerWork extends StatefulWidget {
  const AnimationControllerWork();
  @override
  _AnimationControllerState createState() => _AnimationControllerState();
}

// 25
// Правильный n-угольник диаметра d, разбитый на треугольники отрезками,
// соединяющими его центр со всеми вершинами. Треугольники должны
// быть закрашены случайными цветами.
class _AnimationControllerState extends State<AnimationControllerWork> {
  var _sides = 3;
  var _radius = 100.0;

  @override
  Widget build(BuildContext context) {
    final minSides = 3.0;
    final maxSides = 15.0;
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Polygons')),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: CustomPaint(
                painter: ShapePainter(_sides, _radius),
                child: Container(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8),
              child: Text('Sides'),
            ),
            CupertinoSlider(
              value: _sides.toDouble(),
              min: minSides,
              max: maxSides,
              divisions: (maxSides - minSides).round(),
              onChanged: (value) {
                setState(() {
                  _sides = value.round();
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8),
              child: Text('Size'),
            ),
            CupertinoSlider(
              value: _radius,
              min: 10.0,
              max: MediaQuery.of(context).size.width / 2,
              onChanged: (value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final int anglesCount;
  final double diam;
  final List<Color> triangleColors;
  ShapePainter(this.anglesCount, this.diam)
    : triangleColors = List<Color>.generate(anglesCount, (int i) {
        final rnd = math.Random();
        return Color.fromARGB(
          255,
          100 + rnd.nextInt(156),
          100 + rnd.nextInt(156),
          100 + rnd.nextInt(156),
        );
      });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = diam / 2;
    final double stepAngle = 2 * math.pi / anglesCount;

    final List<Offset> vertices = List<Offset>.generate(anglesCount, (int i) {
      final double a = stepAngle * i;
      return Offset(
        center.dx + math.cos(a) * radius,
        center.dy + math.sin(a) * radius,
      );
    });

    for (int i = 0; i < anglesCount; i++) {
      final int next = (i + 1) % anglesCount;
      final Path tri = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(vertices[i].dx, vertices[i].dy)
        ..lineTo(vertices[next].dx, vertices[next].dy)
        ..close();

      final Paint fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = triangleColors[i % triangleColors.length];
      canvas.drawPath(tri, fillPaint);
    }

    final Path outline = Path()..addPolygon(vertices, true);
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF000000);
    canvas.drawPath(outline, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
