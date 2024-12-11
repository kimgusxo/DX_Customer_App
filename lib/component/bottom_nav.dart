import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFFF6E8),
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.orange[200],
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/0_tabbar_home.svg',
            height: 24, // 아이콘 크기 조절
            color: currentIndex == 0 ? Colors.orange : Colors.orange[200],
          ),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/0_tabbar_map.svg',
            height: 24,
            color: currentIndex == 1 ? Colors.orange : Colors.orange[200],
          ),
          label: '내 주변',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/0_tabbar_quest.svg',
            height: 24,
            color: currentIndex == 2 ? Colors.orange : Colors.orange[200],
          ),
          label: '이용 안내',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/0_tabbar_my.svg',
            height: 24,
            color: currentIndex == 3 ? Colors.orange : Colors.orange[200],
          ),
          label: '내 이용권',
        ),
      ],
    );
  }
}
