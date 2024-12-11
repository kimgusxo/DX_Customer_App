import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 파일을 사용하기 위해 필요한 패키지

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  const MainAppBar({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1.0), // 아래쪽 테두리
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0), // title 위쪽에 패딩 추가
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SvgPicture.asset(
              'assets/1_home_logo.svg', // 로고 경로 설정
              height: 40, // 로고 크기
              width: 40,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // 앱바 높이
}
