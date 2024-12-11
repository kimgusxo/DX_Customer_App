import 'package:dx_customer_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../component/bottom_nav.dart';
import '../component/common_app_bar.dart';

class OrderPage extends StatefulWidget {
  final String storeName;
  final Map<String, dynamic> storeDetails;

  const OrderPage({
    super.key,
    required this.storeName,
    required this.storeDetails,
  });

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    const localServerUrl = 'http://192.168.0.89:5173'; // Vite 서버 주소

    // WebViewController 초기화
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // JavaScript 허용
      ..setBackgroundColor(const Color(0x00000000)) // 투명 배경
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            print('Page started loading: $url');// storeId 전달
            final storeId = widget.storeDetails['store_id'];
            if (storeId != null) {
              await _webViewController.runJavaScript(
                'receiveStoreId("$storeId");', // JavaScript 함수 호출
              );
              print('storeId 전달 완료: $storeId');
            } else {
              print('storeId가 null입니다.');
            }
        },
          onPageFinished: (url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (error) {
            print('Web resource error: $error');
          },
        ),
      )
      ..loadRequest(Uri.parse(localServerUrl)); // Google 페이지 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.storeName, // 매장 이름을 AppBar 제목으로 설정
      ),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: _webViewController), // WebView
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0, // 현재 탭 설정
        onTap: (index) {
          // BottomNav에서 선택된 탭에 따라 페이지 변경
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
              final isSubscribed =
                  Provider.of<UserProvider>(context, listen: false).user?.isSubscribe;
              Navigator.pushReplacementNamed(
                context,
                isSubscribed == true ? '/mine' : '/not/mine',
              );
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}
