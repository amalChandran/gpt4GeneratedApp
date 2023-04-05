import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

void main() {
  runApp(RocketApp());
}

class RocketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rocket App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Center(
          child: Container(width: 100, height: 100, color: Colors.white)),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Offset> _tapPositions = [];
  Offset _lastTapPosition = Offset(0, 0);
  int _counter = 0;

  List<double> _animationProgress = [];
  late AnimationController _controller;

  void _incrementCounter(Offset tappedPosition) {
    print('_incrementCounter');
    setState(() {
      _tapPositions.add(tappedPosition);
      _animationProgress.add(0);
    });

    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _animationProgress.removeAt(0);
        _tapPositions.removeAt(0);
      });
    });

    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(() {
        setState(() {
          for (int i = 0; i < _animationProgress.length; i++) {
            _animationProgress[i] +=
                _controller.value / _animationProgress.length;
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rocket App')),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: StaticRocketPainter(lastTappedOffset: _lastTapPosition),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: RocketPainter(
                  tapPositions: _tapPositions,
                  animationProgress: _animationProgress),
            ),
          ),
          GestureDetector(
            onTapDown: (details) {
              _incrementCounter(details.localPosition);
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                '$_counter',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RocketPainter extends CustomPainter {
  final List<Offset> tapPositions;
  final List<double> animationProgress;

  RocketPainter({required this.tapPositions, required this.animationProgress})
      : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final rocketWidth = 20.0;
    final rocketHeight = 40.0;

    for (int i = 0; i < tapPositions.length; i++) {
      final progress = animationProgress[i];
      final Offset position = tapPositions[i];

      // Calculate rocket position based on tapped position and animation progress
      final double posX = position.dx - rocketWidth / 2;
      final double posY = position.dy - (size.height * progress);

      // Draw rocket as a rectangle
      // final rocketRect =
      //     Rect.fromLTWH(posX, posY - rocketHeight, rocketWidth, rocketHeight);
      // canvas.drawRect(rocketRect, paint);

      _drawRocket(canvas, posX, posY, rocketWidth, rocketHeight);
    }
  }

  void _drawRocket(
      Canvas canvas, double x, double y, double width, double height) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Draw rocket body
    final rocketBody = Path()
      ..moveTo(x + width / 2, y)
      ..lineTo(x + width, y + height / 2)
      ..lineTo(x + width / 2, y + height * 0.75)
      ..lineTo(x, y + height / 2)
      ..close();
    canvas.drawPath(rocketBody, paint);

    // Draw rocket fumes
    paint.color = Colors.orange;
    final fumes = Path()
      ..moveTo(x + width / 4, y + height * 0.75)
      ..lineTo(x + width / 2, y + height)
      ..lineTo(x + 3 * width / 4, y + height * 0.75)
      ..close();
    canvas.drawPath(fumes, paint);
  }

  @override
  bool shouldRepaint(RocketPainter oldDelegate) {
    print('shouldReplaint ${oldDelegate.tapPositions != tapPositions}');

    return true; //oldDelegate.tapPositions != tapPositions;
  }

//   @override
//   bool? hitTest(Offset position) {
//   return rect.contains(position);
//  }
}

class StaticRocketPainter extends CustomPainter {
  Offset lastTappedOffset = Offset(0, 0);

  StaticRocketPainter({required this.lastTappedOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final rocketWidth = 10.0;
    final rocketHeight = 20.0;

    // Calculate the middle of the screen
    // final double posX = (size.width / 2) - (rocketWidth / 2);
    // final double posY = (size.height / 2) - (rocketHeight / 2);

    // Draw the rocket as a rectangle
    final rocketRect = Rect.fromLTWH(
        lastTappedOffset.dx, lastTappedOffset.dy, rocketWidth, rocketHeight);
    canvas.drawRect(rocketRect, paint);
  }

  @override
  bool shouldRepaint(StaticRocketPainter oldDelegate) {
    return false;
  }
}
