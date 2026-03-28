import 'package:flutter/material.dart';
import 'Navigation/HomePage_Kusaku/home_page.dart';
import 'Navigation/Finance_Kusaku/finance_page.dart';
import 'Navigation/Scan_Kusaku/scan_page.dart';
import 'Navigation/History_Kusaku/history_page.dart';
import 'Navigation/ProfilePage_Kusaku/profile_page.dart';

// nanti ini semua musti di redirect posisi folder/filenya, cmn gua jujur lagi prioritasin ini jalan aja dlu
//oh untungnya flutter sendiri udah benerin selama gua pindahinnya bener, LET'S FUCKING GOOOO

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FinancePage(),  
    const HistoryPage(),   
    const ProfilePage(),
  ];

  void _onNavTapped(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScanPage()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex,
        children: [
          _pages[0], // Home
          _pages[1], // Finance
          _pages[2], // History
          _pages[3], // Profile
        ],
      ),
      bottomNavigationBar: _KusakuNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

class _KusakuNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _KusakuNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: 'Finance',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              Expanded(
                child: 
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D4ED8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x441D4ED8),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.crop_free_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isSelected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF1D4ED8);
    const inactiveColor = Color(0xFF9CA3AF);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}