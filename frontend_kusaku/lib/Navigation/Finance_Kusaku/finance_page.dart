import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Navigation/Finance_Kusaku/chat_si_pintar_page.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  // TODO: semangat masukkin APInya
  static const String _bulanLabel = 'Bulan maret tersisa 29 hari lagi';
  static const String _weekLabel = 'Februari 2026';

  static const List<_CalendarDay> _weekDays = [
    _CalendarDay(day: 'Sun', date: 22),
    _CalendarDay(day: 'Mon', date: 23),
    _CalendarDay(day: 'Tue', date: 24),
    _CalendarDay(day: 'Wed', date: 25),
    _CalendarDay(day: 'Thu', date: 26),
    _CalendarDay(day: 'Fri', date: 27),
    _CalendarDay(day: 'Sat', date: 28, isToday: true), // probably ask GPT about this, karna ini kan cmn keep track of day and not calender
  ];

  // TODO: replace with real category data from API lol
  static const List<_BudgetCategory> _categories = [
    _BudgetCategory(icon: Icons.home_outlined, iconColor: Color.fromARGB(255, 70, 119, 255), label: 'Kebutuhan Rumah', sisaBulanIni: 6000000),
    _BudgetCategory(icon: Icons.restaurant_outlined, iconColor: Color.fromARGB(255, 70, 119, 255), label: 'Makan & Minum', sisaBulanIni: 3000000),
    _BudgetCategory(icon: Icons.directions_car_outlined, iconColor: Color.fromARGB(255, 70, 119, 255), label: 'Transportasi', sisaBulanIni: 500000),
    _BudgetCategory(icon: Icons.trending_up_outlined, iconColor: Color.fromARGB(255, 70, 119, 255), label: 'Investasi', sisaBulanIni: 2750000),
    _BudgetCategory(icon: Icons.savings_outlined, iconColor: Color.fromARGB(255, 70, 119, 255), label: 'Tabungan', sisaBulanIni: 2750000),
  ];

  String _formatRp(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
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
          'Pengaturan Keuanganmu',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ── Blue header ──
            Container(
              width: double.infinity,
              color: const Color(0xFF1D4ED8),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Saldo card — tap to open Si Pintar ──
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatSiPintarPage()),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 180, 210, 255),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Text section ──
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saldo Bulan Ini',
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'Rp -', // replace with API yak
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Divider(
                                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                                  thickness: 1,
                                  height: 1,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  _bulanLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ── Icon / Image ──
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 208, 55, 255).withOpacity(0.67), //67 67 67
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'images/sipintar/sipintar.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Static weekly calendar (display only) ──
                  Text(_weekLabel,
                      style: 
                      const TextStyle(
                          color: Color.fromARGB(255, 109, 143, 255), fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weekDays.map((d) => _DayCell(day: d)).toList(),
                  ),
                ],
              ),
            ),

            // ── Category list ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _categories.length,
                itemBuilder: (context, i) => _CategoryTile(
                  category: _categories[i],
                  formatRp: _formatRp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final _CalendarDay day;
  const _DayCell({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day.day,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: day.isToday ? Color(0xFF1E3A8A) : Color(0xFF1E3A8A))),
        const SizedBox(height: 4),
        Container(
          width: 65,
          height: 30,
          decoration: BoxDecoration(
            color: day.isToday
                ? const Color.fromARGB(255, 86, 154, 255)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${day.date}',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    day.isToday ? FontWeight.w700 : FontWeight.w800,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final _BudgetCategory category;
  final String Function(int) formatRp;
  const _CategoryTile({required this.category, required this.formatRp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category.icon, color: category.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
                const Text('Sisa bulan ini',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Text(formatRp(category.sisaBulanIni),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
        ],
      ),
    );
  }
}

class _CalendarDay {
  final String day;
  final int date;
  final bool isToday;
  const _CalendarDay(
      {required this.day, required this.date, this.isToday = false});
}

class _BudgetCategory {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int sisaBulanIni;
  const _BudgetCategory({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sisaBulanIni,
  });
}