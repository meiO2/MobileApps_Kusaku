import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/transfer_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/qris_kita_page.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _userId;
  int? balance;
  bool isLoadingBalance = true;

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final PageController _carouselController = PageController();
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  final List<String> _bannerImages = [
    'images/banner/banner1.jpg',
    'images/banner/banner2.png',
  ];

  // TODO: replace with real activity data from API
  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      label: 'Qris Starbucek',
      subtitle: 'Hari ini',
      amount: '-Rp 45.000',
      iconBgColor: Color.fromARGB(255, 255, 185, 100),
      iconData: Icons.coffee,
      iconColor: Color.fromARGB(255, 255, 134, 20),
    ),
    _ActivityItem(
      label: 'Bensin Pertama',
      subtitle: 'Hari ini',
      amount: '-Rp 500.000',
      iconBgColor: Color.fromARGB(255, 105, 195, 255),
      iconData: Icons.local_gas_station,
      iconColor: Color.fromARGB(255, 29, 63, 255),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _initData();

    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentCarouselIndex + 1) % _bannerImages.length;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      print("User ID not found");
      return;
    }

    _userId = userId;
    await fetchBalance(userId);
  }

  Future<void> fetchBalance(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}balance/$userId/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          balance = data['balance'];
          isLoadingBalance = false;
        });
      } else {
        setState(() => isLoadingBalance = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoadingBalance = false);
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),

        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 21, 60, 167),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Kusaku',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 177, 198, 255),
                child: Column(
                  children: [

                    // ── Purple thingy ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color.fromARGB(255, 186, 152, 241)],
                            begin: Alignment.topCenter, // fixed gradasinya
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color.fromARGB(255, 10, 2, 31).withOpacity(0.3), width: 4.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Wallet icon + Total Saldo
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Total Saldo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text(
                                isLoadingBalance
                                    ? 'Loading...'
                                    : formatter.format(balance ?? 0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),

                              // Divider between balance and buttons
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                  color: Colors.white.withOpacity(0.3),
                                  thickness: 1,
                                  height: 1,
                                ),
                              ),

                              // Quick action buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _QuickAction(
                                    icon: Icons.add,
                                    label: 'Top Up',
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => const TopUpPage()),
                                    ),
                                  ),
                                  _QuickAction(
                                    icon: Icons.swap_horiz,
                                    label: 'Transfer',
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const TransferPage()),
                                    ),
                                  ),
                                  _QuickAction(
                                    icon: Icons.qr_code_scanner,
                                    label: 'Qris Kita',
                                    onTap: () {
                                      if (_userId != null) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => QrisKitaPage(userId: _userId!),
                                          ),
                                        );
                                      }
                                    }
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Dark blue promo strip ──
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: const Text(
                        'Top Up Kusaku sesering mungkin, raih total 67\nperak Kusaku points!', //what the hell
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Quick Insight ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lightbulb_outline,
                            color: Color(0xFFCA8A04), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Insight! ✨',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 2),
                            // TODO: replace with real insight from API
                            Text(
                              'Kamu sudah pakai 40% saldo bulan ini',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Recent Activity ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(14, 14, 14, 8),
                        child: Text(
                          'Aktivitas terbaru',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      ...List.generate(
                        _activities.length,
                        (index) => _ActivityTile(
                          item: _activities[index],
                          isLast: index == _activities.length - 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Auto-scrolling banner carousel ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 190,
                    child: PageView.builder(
                      controller: _carouselController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bannerImages.length,
                      onPageChanged: (i) =>
                          setState(() => _currentCarouselIndex = i),
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _bannerImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFFE5E7EB),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined,
                                    size: 36, color: Colors.grey.shade400),
                                const SizedBox(height: 6),
                                Text(
                                  _bannerImages[index],
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade400),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Carousel dots
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _bannerImages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentCarouselIndex == i ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentCarouselIndex == i
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick action button ──
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Activity tile ──
class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  final bool isLast;
  const _ActivityTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Colored icon container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.iconData, color: item.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827))),
                    Text(item.subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              Text(item.amount,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626))),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1,
              thickness: 0.5,
              indent: 68,
              color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _ActivityItem {
  final String label;
  final String subtitle;
  final String amount;
  final Color iconBgColor;
  final IconData iconData;
  final Color iconColor;
  const _ActivityItem({
    required this.label,
    required this.subtitle,
    required this.amount,
    required this.iconBgColor,
    required this.iconData,
    required this.iconColor,
  });
}