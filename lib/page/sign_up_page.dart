import 'package:dx_customer_app/component/sign_up_app_bar.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class SignUpPage extends StatefulWidget {
  final String kakaoId;
  final String name;

  const SignUpPage({
    required this.kakaoId,
    this.name = '',
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = '남성'; // 기본값

  final UserService _userService = UserService(); // UserService 인스턴스 생성

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveUserData() async {
    try {
      // UserModel 생성
      final user = UserModel(
        kakaoId: widget.kakaoId,
        name: widget.name,
        email: _emailController.text.trim(),
        gender: _gender,
        age: int.parse(_ageController.text.trim()),
        isSubscribe: false, // 기본값
        isSubscribeDate: DateTime(1970, 1, 1), // 구독 상태가 false인 경우 null로 설정
        createdAt: DateTime.now(),
      );

      // Firestore에 저장
      await _userService.saveUser(user);

      // 저장 후 홈 페이지로 이동
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SignUpAppBar(title: '회원가입'),
      backgroundColor: Colors.white, // 배경색 흰색
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              items: const [
                DropdownMenuItem(value: '남성', child: Text('남성')),
                DropdownMenuItem(value: '여성', child: Text('여성')),
              ],
              onChanged: (value) => setState(() {
                _gender = value!;
              }),
              decoration: const InputDecoration(labelText: '성별'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '나이'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // 버튼 색상 주황색
                foregroundColor: Colors.white, // 텍스트 색상 흰색
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 약간의 둥근 모서리
                ),
              ),
              child: const Center(
                child: Text(
                  '회원가입 완료',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
