import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dx_customer_app/component/main_app_bar.dart';
import 'package:dx_customer_app/page/order_page.dart';
import 'package:dx_customer_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../component/bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    // Firestore 컬렉션에서 데이터 가져오기
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('stores').get();

    // 가져온 데이터를 리스트로 변환
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'store_id': data['store_id'],
        'name': data['store_name'],
        'address': data['store_address'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'image': data['url'], // 모든 이미지 고정
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'LG 라이프스테이션',
        subtitle: '방문하려는 지점을 선택해 주세요',
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('데이터를 가져오는 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('등록된 매장이 없습니다.'));
          }

          final locations = snapshot.data!;
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        location['image']!,
                        fit: BoxFit.cover,
                        width: 99,
                        height: 103,
                      ),
                    ),
                    title: Text(
                      location['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      location['address']!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFFF6B01),
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPage(
                              storeName: location['name']!,
                              storeDetails: location,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/info');
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
        },
      ),
    );
  }
}
