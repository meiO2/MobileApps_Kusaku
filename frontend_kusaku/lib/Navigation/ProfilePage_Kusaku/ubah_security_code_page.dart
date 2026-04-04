import 'dart:async';
import 'package:flutter/material.dart';

class UbahSecurityCodePage extends StatefulWidget {
  const UbahSecurityCodePage({super.key});

  @override
  State<UbahSecurityCodePage> createState() => _UbahSecurityCodePageState();
}

enum _SecurityStep { enterCurrent, createNew, success }

class _UbahSecurityCodePageState extends State<UbahSecurityCodePage> {
  _SecurityStep _step = _SecurityStep.enterCurrent;
  String _currentInput = '';
  String _newInput = '';
  Timer? _successTimer;

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  void _onCurrentKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_currentInput.isNotEmpty)
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      } else if (_currentInput.length < 6) {
        _currentInput += key;
        if (_currentInput.length == 6) {
          // TODO: validate current PIN against API
          // For now, any 6-digit code is accepted
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => _step = _SecurityStep.createNew);
          });
        }
      }
    });
  }

  void _onNewKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_newInput.isNotEmpty)
          _newInput = _newInput.substring(0, _newInput.length - 1);
      } else if (_newInput.length < 6) {
        _newInput += key;
        if (_newInput.length == 6) {
          // TODO: call API to update security code with _newInput
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() => _step = _SecurityStep.success);
              // Auto-navigate back to profile after 3 seconds
              _successTimer = Timer(const Duration(seconds: 3), () {
                if (mounted) {
                  // Pop back to profile (pop twice: this page + any intermediate)
                  Navigator.of(context).pop();
                }
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text(
          'UBAH SECURITY CODE',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _SecurityStep.enterCurrent:
        return _buildPinEntry(
          key: const ValueKey('current'),
          title: 'Masukan Security Code Anda saat ini',
          subtitle: 'Security Code digunakan untuk masuk ke akun Anda\ndan bertransaksi',
          input: _currentInput,
          onKey: _onCurrentKey,
        );
      case _SecurityStep.createNew:
        return _buildPinEntry(
          key: const ValueKey('new'),
          title: 'Buat Security Code baru',
          subtitle: 'Security Code digunakan untuk masuk ke akun Anda\ndan bertransaksi',
          input: _newInput,
          onKey: _onNewKey,
        );
      case _SecurityStep.success:
        return _buildSuccess();
    }
  }

  Widget _buildPinEntry({
    required Key key,
    required String title,
    required String subtitle,
    required String input,
    required Function(String) onKey,
  }) {
    return SingleChildScrollView(
      key: key,
      child: Column(
        children: [
          // ── White card with title + PIN dots ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // PIN dots / dashes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    final filled = i < input.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 28,
                      height: 3,
                      decoration: BoxDecoration(
                        color: filled
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Numpad ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                '1', '2', '3',
                '4', '5', '6',
                '7', '8', '9',
                '',  '0', '⌫',
              ].map((key) {
                if (key.isEmpty) return const SizedBox();
                return TextButton(
                  onPressed: () => onKey(key),
                  child: Text(
                    key,
                    style: TextStyle(
                      fontSize: key == '⌫' ? 18 : 24,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      key: const ValueKey('success'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 20),
          const Text(
            'Berhasil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kembali ke profil dalam 3 detik...',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}