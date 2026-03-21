import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── User Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar circle with initial
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D4ED8),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'K',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Kasepiano',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '081234567890',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ubah button
                    TextButton(
                      onPressed: () {
                        // TODO: navigate to edit profile
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Ubah',
                        style: TextStyle(
                          color: Color(0xFF1D4ED8),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Section: Reward ──
            _SectionLabel(label: 'Reward'),
            _MenuTile(
              icon: Icons.add_box_outlined,
              label: 'Kusaku Points',
              onTap: () => _goToEmpty(context, 'Kusaku Points'),
            ),
            _MenuTile(
              icon: Icons.card_giftcard_outlined,
              label: 'Kusaku Stamp',
              onTap: () => _goToEmpty(context, 'Kusaku Stamp'),
              isLast: true,
            ),

            const SizedBox(height: 20),

            // ── Section: Bantuan ──
            _SectionLabel(label: 'Bantuan'),
            _MenuTile(
              icon: Icons.help_outline,
              label: 'Pusat Bantuan',
              onTap: () => _goToEmpty(context, 'Pusat Bantuan'),
              isLast: true,
            ),

            const SizedBox(height: 20),

            // ── Section: Keamanan ──
            _SectionLabel(label: 'Keamanan'),
            _MenuTile(
              icon: Icons.lock_outline,
              label: 'Ubah Security Code',
              onTap: () => _goToEmpty(context, 'Ubah Security Code'),
            ),
            // Fingerprint toggle row
            _FingerprintTile(),

            const SizedBox(height: 20),

            // ── Section: Tentang ──
            _SectionLabel(label: 'Tentang'),
            _MenuTile(
              icon: Icons.emoji_events_outlined,
              label: 'Keuntungan Pakai Kusaku',
              onTap: () => _goToEmpty(context, 'Keuntungan Pakai Kusaku'),
            ),
            _MenuTile(
              icon: Icons.menu_book_outlined,
              label: 'Panduan Kusaku',
              onTap: () => _goToEmpty(context, 'Panduan Kusaku'),
            ),
            _MenuTile(
              icon: Icons.description_outlined,
              label: 'Syarat dan Ketentuan',
              onTap: () => _goToEmpty(context, 'Syarat dan Ketentuan'),
            ),
            _MenuTile(
              icon: Icons.security_outlined,
              label: 'Kebijakan Privasi',
              onTap: () => _goToEmpty(context, 'Kebijakan Privasi'),
              isLast: true,
            ),

            const SizedBox(height: 28),

            // ── Sign Out Button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _showSignOutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _goToEmpty(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _EmptySubPage(title: title)),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: actual sign out logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}

// ── Section label ──
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

// ── Generic menu tile ──
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: const Color(0xFF374151), size: 22),
            title: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            onTap: onTap,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          if (!isLast)
            const Divider(
              height: 1,
              thickness: 0.5,
              indent: 52,
              endIndent: 0,
              color: Color(0xFFE5E7EB),
            ),
        ],
      ),
    );
  }
}

// ── Fingerprint toggle tile ──
class _FingerprintTile extends StatefulWidget {
  @override
  State<_FingerprintTile> createState() => _FingerprintTileState();
}

class _FingerprintTileState extends State<_FingerprintTile> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.fingerprint, color: Color(0xFF374151), size: 22),
        title: const Text(
          'Fingerprint',
          style: TextStyle(fontSize: 14, color: Color(0xFF111827)),
        ),
        trailing: Switch(
          value: _enabled,
          onChanged: (val) => setState(() => _enabled = val),
          activeColor: const Color(0xFF1D4ED8),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }
}

// ── Generic empty sub-page ──
class _EmptySubPage extends StatelessWidget {
  final String title;
  const _EmptySubPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Halaman ini belum tersedia.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}