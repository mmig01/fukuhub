import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fukuhub/screens/after_login_screen/homepage.dart';
import 'package:fukuhub/widgets/orange_rounded_button.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.isFirstNavigatedSocialLoginButton});

  final bool isFirstNavigatedSocialLoginButton;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final String mainPicture = "assets/images/fuku_hub.png";
  bool _loginColumnVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _loginColumnVisible = true;
      });
    });
  }

  // Firebase 로그인 메서드
  Future<void> _goHomeScreen() async {
    if (mounted) {
      // 로딩 화면을 잠깐 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(), // 로딩 스피너 표시
          );
        },
      );

      // 약간의 지연을 주고 페이지를 이동
      await Future.delayed(const Duration(seconds: 1));

      // 로딩 화면을 닫고 새 페이지로 이동
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 화면 닫기
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Homepage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration:
                const Duration(milliseconds: 500), // 애니메이션의 길이 설정
            reverseTransitionDuration: const Duration(milliseconds: 500),
            fullscreenDialog: false,
          ),
          (Route<dynamic> route) => false, // 모든 이전 화면을 제거
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/background.webp',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5), // 투명도 설정
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: Hero(
                                  tag: mainPicture,
                                  child: Image.asset(mainPicture)),
                            )
                          ],
                        )
                      ],
                    ),
                    const Text(
                      "福島の記憶を保存します",
                      style: TextStyle(
                          fontFamily: 'sana',
                          fontSize: 50,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
                AnimatedOpacity(
                  opacity: _loginColumnVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      Container(
                        width: 200,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: OrangeRoundedButton(
                          text: "ログイン",
                          heroTag: "login_tag",
                          method: _goHomeScreen,
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
