import 'package:dx_customer_app/component/common_app_bar.dart';
import 'package:flutter/material.dart';

class PaymentComplete extends StatelessWidget {
  const PaymentComplete({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(
        title: '결제 완료',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '결제가 완료되었습니다.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 나의 이용권 페이지로 돌아가기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
