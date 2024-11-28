import 'package:flutter/material.dart';
import 'package:fukuhub/screens/after_login_screen/homepage.dart';

class DoorAnimationWidget extends StatefulWidget {
  const DoorAnimationWidget({super.key});

  @override
  State<DoorAnimationWidget> createState() => _DoorAnimationWidgetState();
}

class _DoorAnimationWidgetState extends State<DoorAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // 문 열림 애니메이션 (회전)
    _rotationAnimation = Tween<double>(begin: 0.0, end: -3.14 / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 문 크기 확대 애니메이션
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });

    // 애니메이션 실행
    _controller.forward().then((_) {
      // 애니메이션 종료 후 다음 화면으로 이동
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Homepage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startAnimation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()..rotateY(_rotationAnimation.value),
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // 그림자 색상
                      blurRadius: 5, // 그림자의 흐림 정도
                      offset: const Offset(2, 2), // 그림자의 위치 (오른쪽과 아래)
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/door.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
