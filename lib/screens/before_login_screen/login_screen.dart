import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fukuhub/screens/after_login_screen/homepage.dart';
import 'signup_screen.dart';
import 'package:fukuhub/widgets/orange_rounded_button.dart';
import 'package:fukuhub/widgets/textbox_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.isFirstNavigatedSocialLoginButton});

  final bool isFirstNavigatedSocialLoginButton;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final String mainPicture = "assets/images/fuku_hub.png";
  bool _loginColumnVisible = false;

  // 이메일 및 비밀번호 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
  Future<void> _loginWithEmailAndPassword() async {
    late String email;
    late String password;

    setState(() {
      email = _emailController.text;
      password = _passwordController.text;
    });

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (mounted && credential.user != null) {
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                // 유저를 찾을 수 없습니다
                'ユーザーが見つかりません。',
                style: TextStyle(
                  fontFamily: 'sana',
                  fontSize: 15,
                ),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else if (e.code == 'wrong-password') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                // 비밀번호가 잘못되었습니다.
                'パスワードが正しくありません。',
                style: TextStyle(
                  fontFamily: 'sana',
                  fontSize: 15,
                ),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                // 계정을 찾을 수 없습니다
                'アカウントが見つかりません。',
                style: TextStyle(
                  fontFamily: 'sana',
                  fontSize: 15,
                ),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 1),
          ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ログイン",
                            style: TextStyle(
                                fontFamily: 'sana',
                                fontSize: 30,
                                fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextBoxWidget(
                            labelText: "Eメール",
                            obscureText: false,
                            controller: _emailController, // 컨트롤러 전달
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextBoxWidget(
                            labelText: "パスワード",
                            obscureText: true,
                            controller: _passwordController, // 컨트롤러 전달
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "アカウントが必要ですか",
                            style: TextStyle(
                                fontFamily: 'sana',
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          InkWell(
                            onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const SignUp(
                                    isFirstNavigatedSocialLoginButton: false,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = 0.0;
                                    const end = 1.0;
                                    final opacityTween =
                                        Tween(begin: begin, end: end);
                                    final opacityAnimation =
                                        animation.drive(opacityTween);
                                    return FadeTransition(
                                      opacity: opacityAnimation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(
                                      seconds: 1), // 애니메이션의 길이 설정

                                  fullscreenDialog: true,
                                )),
                            child: const Text(
                              "会員加入",
                              style: TextStyle(
                                fontFamily: 'sana',
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        width: 150,
                        height: 50,
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
                          method: _loginWithEmailAndPassword,
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
