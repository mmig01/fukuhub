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
  late Animation<double> _skewAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // 문 열림 애니메이션 (회전)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 3.14 / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 오른쪽 확장 애니메이션 (비대칭 확대)
    _skewAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
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
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Homepage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
        ),
        (Route<dynamic> route) => false,
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
          return Transform(
            alignment: Alignment.centerLeft, // 왼쪽을 기준으로 회전
            transform: Matrix4.identity()
              ..rotateY(_rotationAnimation.value) // 회전 애니메이션
              ..setEntry(1, 0, _skewAnimation.value), // 오른쪽 부분만 확장
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // 그림자 색상

                    blurRadius: 30, // 그림자의 흐림 정도
                    // spreadRadius: 10, // 그림자의 확산 정도
                    offset: const Offset(5, 5), // 그림자의 위치
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/door.png',
                fit: BoxFit.cover,
                color: Colors.white.withOpacity(0.98), // 이미지 투명도 설정
                colorBlendMode: BlendMode.modulate, // 블렌드 모드 설정
              ),
            ),
          );
        },
      ),
    );
  }
}
