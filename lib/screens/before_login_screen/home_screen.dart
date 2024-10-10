import 'package:flutter/material.dart';
import 'package:fukuhub/screens/before_login_screen/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final String mainPicture = "assets/images/fuku_hub.png";
  bool _logoVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _logoVisible = true;
        });
      }
    });

    // 3초 후에 자동으로 다음 페이지로 이동
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Login(
              isFirstNavigatedSocialLoginButton: true,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              final opacityTween = Tween(begin: begin, end: end);
              final opacityAnimation = animation.drive(opacityTween);
              return FadeTransition(
                opacity: opacityAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(seconds: 1), // 애니메이션의 길이 설정

            fullscreenDialog: true,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
              AnimatedOpacity(
                opacity: _logoVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: Hero(
                  tag: mainPicture,
                  child: Image.asset(
                    mainPicture,
                  ),
                ),
              ),
              const Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 55,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
