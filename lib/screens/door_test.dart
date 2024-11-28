import 'package:flutter/material.dart';
import 'after_login_screen/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DoorAnimationExample(),
    );
  }
}

class DoorAnimationExample extends StatefulWidget {
  const DoorAnimationExample({super.key});

  @override
  _DoorAnimationExampleState createState() => _DoorAnimationExampleState();
}

class _DoorAnimationExampleState extends State<DoorAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation; // 문 회전 애니메이션
  late Animation<double> _scaleAnimation; // 문 크기 애니메이션
  late Animation<double> _opacityAnimation; // 문 투명도 애니메이션

  @override
  void initState() {
    super.initState();

    // AnimationController 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // 애니메이션 지속 시간
      vsync: this,
    );

    // 애니메이션 상태 감지
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHomePage(); // 애니메이션 완료 시 HomePage로 이동
      }
    });

    // Tween 정의
    _rotationAnimation = Tween<double>(begin: 0, end: -3.14 / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 리소스 정리
    super.dispose();
  }

  void _toggleAnimation() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Homepage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Door Animation Example')),
      body: Center(
        child: GestureDetector(
          onTap: _toggleAnimation,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value, // 투명도 조정
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..rotateY(_rotationAnimation.value) // 회전 적용
                    ..scale(_scaleAnimation.value), // 크기 변화 적용
                  child: child,
                ),
              );
            },
            child: Container(
              width: 200,
              height: 300,
              color: Colors.brown,
              child: const Center(
                child: Text(
                  'Tap to Open',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
