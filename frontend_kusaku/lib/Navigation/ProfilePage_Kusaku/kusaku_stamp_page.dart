import 'package:flutter/material.dart';

class KusakuStampPage extends StatefulWidget {
  const KusakuStampPage({super.key});

  @override
  State<KusakuStampPage> createState() => _KusakuStampPageState();
}

class _KusakuStampPageState extends State<KusakuStampPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO: replace with real stamp data from API
  final List<_StampCard> _aktif = const [
    _StampCard(
      imagePath: 'assets/images/stamp/stamp_gacoan.png',
      title: 'Kusaku Stamp Gacoan March 2026',
      points: 1500,
      deadline: '31 Maret 2026',
      rewardLabel: '15K',
    ),
    _StampCard(
      imagePath: 'assets/images/stamp/stamp_kfc.png',
      title: 'Kusaku Stamp KFC March 2026',
      points: 4000,
      deadline: '31 Maret 2026',
      rewardLabel: '40K',
    ),
  ];

  final List<_StampCard> _tidakAktif = const [
    _StampCard(
      imagePath: 'assets/images/stamp/stamp_expired1.png',
      title: 'Kusaku Stamp Gacoan Feb 2026',
      points: 1500,
      deadline: '28 Februari 2026',
      rewardLabel: '15K', // ubah ini sm API
    ),
  ]; // TODO: Ubah pake API konek

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
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Kusaku Stamp',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Tidak aktif'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StampList(cards: _aktif, isActive: true),
          _StampList(cards: _tidakAktif, isActive: false),
        ],
      ),
    );
  }
}

class _StampList extends StatelessWidget {
  final List<_StampCard> cards;
  final bool isActive;
  const _StampList({required this.cards, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              isActive ? 'Belum ada stamp aktif' : 'Belum ada stamp tidak aktif',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (context, i) => _StampCardWidget(card: cards[i]),
    );
  }
}

class _StampCardWidget extends StatelessWidget {
  final _StampCard card;
  const _StampCardWidget({required this.card});

  String _formatPoints(int p) => p
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 130,
                  child: Image.asset(
                    card.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1E3A8A),
                      child: Center(
                        child: Icon(Icons.image_outlined,
                            size: 40, color: Colors.white.withOpacity(0.4)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reward',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        Text(card.rewardLabel,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF111827))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.card_giftcard,
                        size: 16, color: Color(0xFF1D4ED8)),
                    const SizedBox(width: 6),
                    Text('${_formatPoints(card.points)} Kusaku Points',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Berlaku sampai ${card.deadline}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StampCard {
  final String imagePath;
  final String title;
  final int points;
  final String deadline;
  final String rewardLabel;
  const _StampCard({
    required this.imagePath,
    required this.title,
    required this.points,
    required this.deadline,
    required this.rewardLabel,
  });
}