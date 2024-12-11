import 'package:flutter/material.dart';

class SignUpAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SignUpAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false, // 제목 왼쪽 정렬
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false, // 이전 모든 화면 제거
          );
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(
          height: 1.0,
          color: Colors.black, // 검정색 테두리
          thickness: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // 앱바 높이
}
