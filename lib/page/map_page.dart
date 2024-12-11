import 'dart:convert'; // jsonEncode 사용을 위해 import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dx_customer_app/component/bottom_nav.dart';
import 'package:dx_customer_app/component/common_app_bar.dart';
import 'package:dx_customer_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  WebViewController? _controller;
  String? _lastSentStoresJson;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      Position position = await _getCurrentLocation();
      String htmlString = await _loadHtmlWithCurrentLocation(position);

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'Flutter',
          onMessageReceived: _onJavaScriptMessageReceived,
        )
        ..loadHtmlString(htmlString);

      if(mounted) {
        setState(() {
          _controller = controller;
        });
      }
      await _sendDataToWebView(controller);
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  Future<String> _loadHtmlWithCurrentLocation(Position position) async {
    String htmlString = await rootBundle.loadString('assets/html/map.html');
    htmlString = htmlString.replaceFirst(
        'CURRENT_LATITUDE', position.latitude.toString());
    htmlString = htmlString.replaceFirst(
        'CURRENT_LONGITUDE', position.longitude.toString());
    return htmlString;
  }

  Future<void> _sendDataToWebView(WebViewController controller) async {
    try {
      List<Map<String, dynamic>> stores = await fetchStoreData();
      String storesJson = jsonEncode(stores);

      if (_lastSentStoresJson == storesJson) return; // 동일 데이터 전달 방지
      _lastSentStoresJson = storesJson;

      int retryCount = 0;
      const maxRetries = 10;

      while (retryCount < maxRetries) {
        final result = await controller.runJavaScriptReturningResult('''
          typeof isMapReady !== "undefined" && isMapReady ? "ready" : "not_ready";
        ''') as String;

        if (result == '"ready"') {
          await controller.runJavaScript('addMarkers(${jsonEncode(storesJson)});');
          print("JavaScript 실행 완료");
          return;
        } else {
          print("지도 초기화가 완료되지 않았습니다. (${retryCount + 1}/${maxRetries})");
          await Future.delayed(const Duration(seconds: 1));
          retryCount++;
        }
      }

      throw Exception("지도 초기화 타임아웃: 초기화가 너무 오래 걸립니다.");
    } catch (error) {
      print("JavaScript 실행 중 오류 발생: $error");
    }
  }

  void _onJavaScriptMessageReceived(JavaScriptMessage message) {
    try {
      final storeData = jsonDecode(message.message);
      print('매장 데이터 수신: $storeData');
      Navigator.pushNamed(
        context,
        '/order',
        arguments: {
          'storeName': storeData['store_name'],
          'storeDetails': storeData,
        },
      );
    } catch (e) {
      print('JavaScript 메시지 처리 중 오류: $e');
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('위치 서비스가 비활성화되어 있습니다.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<Map<String, dynamic>>> fetchStoreData() async {
    final snapshot = await FirebaseFirestore.instance.collection('stores').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 주변'),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller!),
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        onTap: (index) => _onBottomNavTap(index),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
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
  }
}
