import 'package:flutter/material.dart';
import 'package:fukuhub/widgets/door_widget.dart';

class ColorRoundedButton extends StatefulWidget {
  const ColorRoundedButton({
    super.key,
    required this.text,
    required this.heroTag,
    required this.method,
  });

  final String text;
  final String heroTag;
  final void Function() method;

  @override
  State<ColorRoundedButton> createState() => _ColorRoundedButtonState();
}

class _ColorRoundedButtonState extends State<ColorRoundedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // 애니메이션 전체 반복 주기
      vsync: this,
    )..repeat(reverse: true); // 반복 애니메이션

    // 좌우 움직임 애니메이션 (지속적으로 천천히 이동)
    _shakeAnimation = Tween<double>(begin: -3, end: 3)
        .chain(CurveTween(curve: Curves.easeInOut)) // 부드럽게 이동
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _shakeAnimation.value), // 좌우 움직임 애니메이션 적용
          child: GestureDetector(
            onTap: widget.method,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // 모서리 둥글게
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 252, 204, 218)
                        .withOpacity(0.8), // 파스텔 핑크
                    const Color.fromARGB(255, 210, 236, 212)
                        .withOpacity(0.8), // 파스텔 민트
                    const Color.fromARGB(255, 252, 204, 218).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    const DoorAnimationWidget(),
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontFamily: 'sana',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
