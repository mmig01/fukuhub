import 'package:fukuhub/screens/after_login_screen/homepage.dart';
import 'package:flutter/material.dart';

class TotalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TotalAppBar({
    super.key,
    required this.logo,
  });

  final String logo;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // AppBar를 투명하게 설정
      scrolledUnderElevation: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 60,
                  child: Image.asset(
                    logo,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const Homepage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(
                                  milliseconds: 500), // 애니메이션의 길이 설정
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 500),
                              fullscreenDialog: false,
                            ),
                            (Route<dynamic> route) => false, // 모든 이전 화면을 제거
                          );
                        },
                        child: const Text(
                          'Home',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    TextButton(
                        onPressed: () {},
                        child: const Text(
                          'etc',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.black.withOpacity(0.1), // 경계선 색상
          height: 1.0, // 경계선 두께
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
