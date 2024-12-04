import 'package:flutter/material.dart';
import 'package:fukuhub/widgets/black_rounded_button.dart';
import 'package:fukuhub/widgets/door_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.isFirstNavigatedSocialLoginButton});

  final bool isFirstNavigatedSocialLoginButton;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final String mainPicture = "assets/images/fuku_hub.png";
  final String doorPicture = 'assets/images/door_Test.png';
  bool _loginDoorVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _loginDoorVisible = true;
      });
    });
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
                  'assets/images/fukuback.jpeg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(1), // 투명도 설정
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
                  ],
                ),
                AnimatedOpacity(
                  opacity: _loginDoorVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          "福島の記憶を保存します",
                          style: TextStyle(
                              fontFamily: 'sana',
                              fontSize: 50,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const DoorAnimationWidget(),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: BlackRoundedButton(
                            text: "記憶の中に入る門", heroTag: "enter", method: () {}),
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
