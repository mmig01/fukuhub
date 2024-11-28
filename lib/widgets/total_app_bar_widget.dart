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
