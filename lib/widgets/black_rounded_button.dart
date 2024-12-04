import 'package:flutter/material.dart';

class BlackRoundedButton extends StatefulWidget {
  const BlackRoundedButton({
    super.key,
    required this.text,
    required this.heroTag,
    required this.method,
  });

  final String text;
  final String heroTag;
  final void Function() method;

  @override
  State<BlackRoundedButton> createState() => _BlackRoundedButtonState();
}

class _BlackRoundedButtonState extends State<BlackRoundedButton>
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
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFA6C1), // 파스텔 핑크
                    Color.fromARGB(255, 121, 239, 133), // 파스텔 민트
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
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'sana',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
