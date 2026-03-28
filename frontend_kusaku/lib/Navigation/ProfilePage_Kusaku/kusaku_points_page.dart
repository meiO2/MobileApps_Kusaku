import 'package:flutter/material.dart';

class KusakuPointsPage extends StatefulWidget {
  const KusakuPointsPage({super.key});

  @override
  State<KusakuPointsPage> createState() => _KusakuPointsPageState();
}

class _KusakuPointsPageState extends State<KusakuPointsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data — replace with real data later
  final List<_PointTransaction> _didapat = [
    _PointTransaction(date: '16 Maret 2026', month: 'Maret 2026', label: 'Starbuck', points: 50),
    _PointTransaction(date: '8 Maret 2026', month: 'Maret 2026', label: 'Pulsa', points: 60),
    _PointTransaction(date: '14 Februari 2026', month: 'Februari 2026', label: 'Indomaret', points: 30),
    _PointTransaction(date: '3 Februari 2026', month: 'Februari 2026', label: 'Grab Food', points: 40),
  ];

  final List<_PointTransaction> _terpakai = [
    _PointTransaction(date: '30 Februari 2026', month: 'Februari 2026', label: 'Kusaku Stamp Gacoan Feb 2026', points: 1500),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text(
          'Kusaku Point',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Points Summary Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: const Color(0xFFEFF6FF),
            child: Column(
              children: const [
                Text(
                  '110',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Setara dengan Rp 110',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // ── Tabs ──
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1D4ED8),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF1D4ED8),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            tabs: const [
              Tab(text: 'Didapat'),
              Tab(text: 'Terpakai'),
            ],
          ),

          // ── Tab Views ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TransactionList(transactions: _didapat, isEarned: true),
                _TransactionList(transactions: _terpakai, isEarned: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction list grouped by month ──
class _TransactionList extends StatelessWidget {
  final List<_PointTransaction> transactions;
  final bool isEarned;

  const _TransactionList({required this.transactions, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    // Group by month
    final Map<String, List<_PointTransaction>> grouped = {};
    for (final t in transactions) {
      grouped.putIfAbsent(t.month, () => []).add(t);
    }

    return ListView(
      children: grouped.entries.expand((entry) {
        return [
          // Month header
          Container(
            width: double.infinity,
            color: const Color(0xFFF3F4F6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Transactions for that month
          ...entry.value.map((t) => _TransactionTile(transaction: t, isEarned: isEarned)),
        ];
      }).toList(),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final _PointTransaction transaction;
  final bool isEarned;

  const _TransactionTile({required this.transaction, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.date,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  transaction.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                '${_formatPoints(transaction.points)} Points',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isEarned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.5, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    // Format with dot thousands separator e.g. 1500 → 1.500
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

class _PointTransaction {
  final String date;
  final String month;
  final String label;
  final int points;

  const _PointTransaction({
    required this.date,
    required this.month,
    required this.label,
    required this.points,
  });
}