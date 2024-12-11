import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dx_customer_app/component/bottom_nav.dart';
import 'package:dx_customer_app/component/common_app_bar.dart';
import 'package:dx_customer_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // UserProvider 사용

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  Future<List<Map<String, dynamic>>> fetchOrdersWithSubcollections(String userId) async {
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> orders = [];

    for (var orderDoc in ordersSnapshot.docs) {
      final orderData = orderDoc.data();

      try {
        final mealKitsSnapshot = await orderDoc.reference.collection('meal_kits').get();
        final laundrySuppliesSnapshot = await orderDoc.reference.collection('laundry_supplies').get();
        final laundryTicketsSnapshot = await orderDoc.reference.collection('laundry_tickets').get();
        final homeAppliancesSnapshot = await orderDoc.reference.collection('home_appliances').get();

        // meal_kits_order 데이터 처리
        final mealKitCount = mealKitsSnapshot.docs.fold<int>(0, (sum, doc) {
          return sum + (doc.data()['quantity'] as int);
        });

        // laundry_supplies_order 데이터 처리
        final laundrySuppliesCount = laundrySuppliesSnapshot.docs.fold<int>(0, (sum, doc) {
          return sum + (doc.data()['quantity'] as int);
        });

        // laundry_tickets_used 데이터 처리
        final laundryUsage = laundryTicketsSnapshot.docs
            .where((doc) => doc.data()['is_used'] == true)
            .map((doc) {
          final ticketId = doc.data()['laundry_ticket_id'];
          switch (ticketId) {
            case 1:
              return '세탁기';
            case 2:
              return '건조기';
            case 3:
              return '스타일러';
            case 4:
              return '슈케어';
            default:
              return '기타';
          }
        }).toList();

        // home_appliances_used 데이터 처리
        final homeAppliances = homeAppliancesSnapshot.docs
            .where((doc) => doc.data()['is_used'] == true)
            .map((doc) => '가전제품 ${doc.data()['home_appliances_id']}번')
            .toList();

        // order_time 처리
        DateTime? orderTime;
        try {
          if (orderData['order_time'] is Timestamp) {
            orderTime = (orderData['order_time'] as Timestamp).toDate();
          } else if (orderData['order_time'] is String) {
            orderTime = DateTime.parse(orderData['order_time']);
          }
        } catch (e) {
          print('order_time 파싱 실패: ${orderData['order_time']}, 오류: $e');
        }

        if (orderTime == null) {
          print('order_time이 비어 있습니다. 기본값으로 설정합니다.');
          orderTime = DateTime.now(); // 기본값 설정
        }

        // 최종 데이터 병합
        orders.add({
          'orderId': orderData['order_id'],
          'totalPrice': orderData['order_total_price'],
          'orderTime': orderTime,
          'spaceUsed': orderData['space_is_used'] == true ? '주방 이용권 O' : '주방 이용권 X',
          'mealKitCount': mealKitCount,
          'laundryCount': laundrySuppliesCount,
          'laundryUsage': laundryUsage,
          'homeAppliances': homeAppliances,
        });
      } catch (e) {
        print('하위 컬렉션 데이터 가져오기 오류: $e');
      }
    }

    return orders;
  }

  String _calculateSubscriptionEndDate(DateTime? subscribeDate) {
    if (subscribeDate == null) {
      return '구독 날짜를 가져올 수 없습니다.';
    }
    final endDate = DateTime(
      subscribeDate.year,
      subscribeDate.month + 1,
      subscribeDate.day,
    );
    return '${endDate.year}.${endDate.month.toString().padLeft(2, '0')}.${endDate.day.toString().padLeft(2, '0')}까지';
  }

  Widget _buildSubscriptionInfo(UserModel user) {
    final subscriptionEndDate =
            user.isSubscribe ? _calculateSubscriptionEndDate(user.isSubscribeDate) : '가입 필요';


    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.isSubscribe ? '정기권 이용중' : '정기권 미가입',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                '남은 기간',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                subscriptionEndDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.access_time,
            color: Colors.orange,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        '나의 이용내역',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            '${item['totalPrice']} 원',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '밀키트 ${item['mealKitCount']}개, 세탁용품 ${item['laundryCount']}개',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                '${item['spaceUsed']}\n${item['laundryUsage'].join(', ')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Text(
            '${item['orderTime']}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildHistoryList(String kakaoId) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrdersWithSubcollections(kakaoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('이용 내역이 없습니다.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildHistoryItem(orders[index]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      return const Center(
        child: Text('사용자 정보를 불러오지 못했습니다.'),
      );
    }

    return Scaffold(
      appBar: const CommonAppBar(
        title: '나의 이용권',
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubscriptionInfo(user),
          const Divider(thickness: 1),
          _buildHistoryHeader(),
          _buildHistoryList(user.kakaoId),
        ],
      ),
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