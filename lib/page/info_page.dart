import 'package:dx_customer_app/component/bottom_nav.dart';
import 'package:dx_customer_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:dx_customer_app/component/common_app_bar.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomIndex = 2; // "이용 안내" 기본 선택

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 탭 개수 설정
  }

  @override
  void dispose() {
    _tabController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (_currentBottomIndex == index) return; // 현재 페이지에서는 아무 동작도 하지 않음
    setState(() {
      _currentBottomIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home'); // 홈으로 이동
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map'); // 내 주변으로 이동
        break;
      case 2:
        // 현재 페이지
        break;
      case 3:
        final isSubscribed =
          Provider.of<UserProvider>(context, listen: false).user?.isSubscribe;
        Navigator.pushReplacementNamed(
          context,
          isSubscribed == true ? '/mine' : '/not/mine',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: '이용 안내',
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white, // 탭바 배경을 흰색으로 설정
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: '주방 이용'),
                Tab(text: '클리닝 룸'),
                Tab(text: '상품 구매'),
                Tab(text: '정기권'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                KitchenInfoView(),
                CleanInfoView(),
                PurchaseInfoView(),
                TicketInfoView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentBottomIndex,
        onTap: _onBottomNavTap, // 하단 네비게이션 탭 클릭 시 동작
      ),
    );
  }
}

class KitchenInfoView extends StatelessWidget {
  const KitchenInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/kitchen_usage.png', // 주방 이용 안내 이미지
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CleanInfoView extends StatelessWidget {
  const CleanInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/cleaning_room.png', // 클리닝 룸 안내 이미지
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PurchaseInfoView extends StatelessWidget {
  const PurchaseInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/product_purchase.png', // 상품 구매 안내 이미지
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TicketInfoView extends StatelessWidget {
  const TicketInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/subscription.png', // 정기권 안내 이미지
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
