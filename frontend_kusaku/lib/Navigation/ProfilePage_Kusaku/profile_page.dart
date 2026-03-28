import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/kusaku_points_page.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/kusaku_stamp_page.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/kebijakan_privasi_page.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/syarat_ketentuan_page.dart';
import '../../Screens/Login_Screen-frontend/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = "Loading...";
  String _phone = "...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) return;

      // Call your backend Profile Search API
      final response = await http.get(
        Uri.parse('http://10.93.20.130:8000/api/users/profile/$userId/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _username = data['username'] ?? "User";
          _phone = data['phone_number'] ?? "No Phone"; // Assuming your Account model has this field
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get first letter for Avatar
    String avatarLetter = _username.isNotEmpty ? _username[0].toUpperCase() : "?";

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar — Shows first letter of username
                    Container(
                      width: 55,
                      height: 55,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          avatarLetter,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & phone — Real data from backend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _username,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _phone,
                            style: const TextStyle(
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
            const _SectionLabel(label: 'Reward'),
            _MenuTile(
              icon: Icons.add_box_outlined,
              label: 'Kusaku Points',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KusakuPointsPage()),
              ),
            ),
            _MenuTile(
              icon: Icons.card_giftcard_outlined,
              label: 'Kusaku Stamp',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KusakuStampPage()),
              ),
              isLast: true,
            ),

            const SizedBox(height: 20),

            // ── Section: Bantuan ──
            const _SectionLabel(label: 'Bantuan'),
            _MenuTile(
              icon: Icons.help_outline,
              label: 'Pusat Bantuan',
              onTap: () {},
              isLast: true,
            ),

            const SizedBox(height: 20),

            // ── Section: Keamanan ──
            const _SectionLabel(label: 'Keamanan'),
            _MenuTile(
              icon: Icons.lock_outline,
              label: 'Ubah Security Code',
              onTap: () {},
            ),
            const _FingerprintTile(),

            const SizedBox(height: 20),

            // ── Section: Tentang ──
            const _SectionLabel(label: 'Tentang'),
            _MenuTile(
              icon: Icons.emoji_events_outlined,
              label: 'Keuntungan Pakai Kusaku',
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.menu_book_outlined,
              label: 'Panduan Kusaku',
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.description_outlined,
              label: 'Syarat dan Ketentuan',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SyaratKetentuanPage()),
              ),
            ),
            _MenuTile(
              icon: Icons.security_outlined,
              label: 'Kebijakan Privasi',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KebijakanPrivasiPage()),
              ),
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
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear the session
              
              if (!mounted) return;
              Navigator.of(ctx).pop(); // Close the dialog

              // This clears the entire stack and uses your pageBuilder
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    // You can add custom fade/slide logic here if you want
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white),), 
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
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
              color: Color(0xFFE5E7EB),
            ),
        ],
      ),
    );
  }
}

// ── Fingerprint toggle tile ──
class _FingerprintTile extends StatefulWidget {
  const _FingerprintTile();

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