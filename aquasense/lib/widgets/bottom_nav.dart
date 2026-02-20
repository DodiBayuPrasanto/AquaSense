import 'package:flutter/material.dart';
import '../pages/home.dart';
import '../pages/statistik.dart';
import '../pages/profil.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final Color activeColor = const Color(0xFF1A53D4);
  final Color inactiveColor = const Color(0xFFC3C3C3);

  // Pindah ke dalam build() agar context sudah tersedia
  // dan tidak ada masalah inisialisasi sebelum widget siap.
  List<Widget> get _pages => const [HomePage(), StatistikPage(), ProfilPage()];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Hindari rebuild jika index sama
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //IndexedStack menjaga state halaman tetap hidup saat berpindah tab
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          elevation: 8,
          backgroundColor: Colors.white,
          enableFeedback: false,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/Home.png',
                width: 24,
                height: 24,
                color: inactiveColor,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.home_outlined, size: 24, color: inactiveColor),
              ),
              activeIcon: Image.asset(
                'assets/icons/Home_Off.png',
                width: 24,
                height: 24,
                color: activeColor,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.home, size: 24, color: activeColor),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/Statistik_On.png',
                width: 24,
                height: 24,
                color: inactiveColor,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.bar_chart_outlined,
                  size: 24,
                  color: inactiveColor,
                ),
              ),
              activeIcon: Image.asset(
                'assets/icons/Statistik.png',
                width: 24,
                height: 24,
                color: activeColor,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.bar_chart, size: 24, color: activeColor),
              ),
              label: 'Statistik',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/Profil_On.png',
                width: 24,
                height: 24,
                color: inactiveColor,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person_outline, size: 24, color: inactiveColor),
              ),
              activeIcon: Image.asset(
                'assets/icons/Profil.png',
                width: 24,
                height: 24,
                color: activeColor,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 24, color: activeColor),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
