import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dx_customer_app/component/bottom_nav.dart';
import 'package:dx_customer_app/component/common_app_bar.dart';
import 'package:dx_customer_app/component/payment_complete.dart';
import 'package:dx_customer_app/page/info_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // UserProvider 사용

class NotMinePage extends StatelessWidget {
  const NotMinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(
        title: '나의 이용권',
      ),
      body: const NotMineContent(),
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/info');
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }
}

class NotMineContent extends StatelessWidget {
  const NotMineContent({Key? key}) : super(key: key);

  Future<void> _updateSubscription(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.kakaoId; // 상태에서 userId 가져오기

    if (userId == null) {
      print('유저 ID를 가져오지 못했습니다.');
      return;
    }

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'isSubscribe': true,
        'isSubscribeDate': FieldValue.serverTimestamp(), // 서버 시간으로 저장
      });
      print('Subscription 업데이트 성공');
    } catch (e) {
      print('Subscription 업데이트 실패: $e');
    }
  }

  void _showPurchasePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '정기권을 구매하시겠습니까?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '(이용 기간 30일)',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '100,000원',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '정기권 이용 혜택',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '1. 주방 이용과 클리닝 가전 이용 무제한',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '2. 상품 구매 시 10% 할인',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '아래 결제하기 버튼을 누르면\n100,000원이 결제됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // 팝업 닫기
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // 팝업 닫기
                        await _updateSubscription(context); // 구독 업데이트 호출
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentComplete(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('결제하기'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '이용중인 정기권 없음',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoPage(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/물음표아이콘.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _showPurchasePopup(context); // 팝업 호출
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('정기권 구매'),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '나의 이용내역',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text(
            '히스토리가 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
