import 'package:dx_customer_app/page/sign_up_page.dart';
import 'package:dx_customer_app/providers/user_provider.dart';
import 'package:dx_customer_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      final userService = UserService();
      
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        await UserApi.instance.loginWithKakaoTalk(); // 카카오톡으로 로그인
      } else {
        await UserApi.instance.loginWithKakaoAccount(); // 카카오 계정으로 로그인
      }

      // 사용자 정보 가져오기
      final user = await UserApi.instance.me();
      final kakaoId = user.id.toString();
      // 카카오 닉네임 가져오기
      final name = user.kakaoAccount?.profile?.nickname ?? 'Unknown';

      // Firestore에서 유저 데이터 가져오기
      final existingUser = await userService.fetchUser(kakaoId);
      
      if (existingUser != null) {
        // Provider에 유저 데이터 저장
        Provider.of<UserProvider>(context, listen: false).setUser(existingUser);
        // 이미 가입된 사용자 → 홈 페이지로 이동
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: user,
        );
      } else {
        // 회원가입 필요 → 회원가입 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(
              kakaoId: kakaoId,
              name: name,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error during Kakao login: $e');
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인 오류'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B01), // 배경색
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/0_login_logo.svg', // 업로드한 로고 파일 경로
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              '집에서는 오롯이 휴식만',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/0_login_graphic.png', // 업로드한 그래픽 파일 경로
                  fit: BoxFit.cover,
                  height: 140,
                  width: 140,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _loginWithKakao(context),
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
              label: const Text(
                '카카오로 시작하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE600),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
