import 'package:flutter/material.dart';

class TopUpPulsaPage extends StatefulWidget {
  const TopUpPulsaPage({super.key});

  @override
  State<TopUpPulsaPage> createState() => _TopUpPulsaPageState();
}

class _TopUpPulsaPageState extends State<TopUpPulsaPage> {
  int? _selectedPackage;
  bool _paymentSuccess = false;

  final List<_PulsaPackage> _packages = const [
    _PulsaPackage(nominal: 5000, bayar: 6000),
    _PulsaPackage(nominal: 10000, bayar: 12000),
    _PulsaPackage(nominal: 15000, bayar: 18000),
    _PulsaPackage(nominal: 25000, bayar: 30000),
    _PulsaPackage(nominal: 50000, bayar: 60000),
    _PulsaPackage(nominal: 100000, bayar: 120000),
  ];

  String _formatRp(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _onTapPackage(int index) {
    // Reset payment state when tapping a new/same package
    setState(() {
      _paymentSuccess = false;
      _selectedPackage = index;
    });
  }

  void _onConfirm() {
    if (_selectedPackage == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PinBottomSheet(
        onSuccess: () {
          Navigator.of(context).pop();
          setState(() => _paymentSuccess = true);
        },
      ),
    );
  }

  void _reset() {
    setState(() {
      _selectedPackage = null;
      _paymentSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        _selectedPackage != null ? _packages[_selectedPackage!] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title:
            const Text('Pulsa', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Scrollable package section ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone number display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _paymentSuccess
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '0812*****890', // TODO: real masked phone from user session
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _paymentSuccess
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pemilihan paket pulsa',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF111827)),
                  ),
                  const Text(
                    'Fee: 20%',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final pkg = _packages[index];
                      final isSelected = _selectedPackage == index;
                      return GestureDetector(
                        onTap: () => _onTapPackage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFFBFDBFE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatRp(pkg.nominal),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1D4ED8),
                                ),
                              ),
                              Text(
                                'Bayar: Rp ${_formatRp(pkg.bayar)}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected
                                      ? Colors.white70
                                      : const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom confirmation panel ──
          if (selected != null)
            Container(
              width: double.infinity,
              color: const Color(0xFF1D4ED8),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row with back arrow
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _reset,
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Konfirmasi Pembayaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Success card
                  if (_paymentSuccess) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Color(0xFF16A34A), size: 40),
                          const SizedBox(height: 4),
                          const Text(
                            'Payment Successful!',
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rp ${_formatRp(selected.bayar)}',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Detail rows
                  _DetailRow(
                    label: 'Produk',
                    value: 'Pulsa ${_formatRp(selected.nominal)}',
                  ),
                  const SizedBox(height: 6),
                  const _DetailRow(
                    label: 'Metode Pembayaran',
                    value: 'Kusaku',
                  ),
                  const SizedBox(height: 14),

                  if (!_paymentSuccess)
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1D4ED8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Konfirmasi',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Shared PIN bottom sheet ──
class PinBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const PinBottomSheet({super.key, required this.onSuccess});

  @override
  State<PinBottomSheet> createState() => _PinBottomSheetState();
}

class _PinBottomSheetState extends State<PinBottomSheet> {
  final List<String> _pin = [];

  void _onKey(String key) {
    if (key == '⌫') {
      if (_pin.isNotEmpty) setState(() => _pin.removeLast());
    } else {
      if (_pin.length < 6) {
        setState(() => _pin.add(key));
        if (_pin.length == 6) {
          // TODO: validate PIN against real user PIN from API
          Future.delayed(
              const Duration(milliseconds: 300), widget.onSuccess);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Masukan PIN',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    i < _pin.length ? '*' : '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫']
                  .map((key) {
                if (key.isEmpty) return const SizedBox();
                return TextButton(
                  onPressed: () => _onKey(key),
                  child: Text(
                    key,
                    style: TextStyle(
                      fontSize: key == '⌫' ? 18 : 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// Keep private alias so this file still compiles internally
class _PinBottomSheet extends PinBottomSheet {
  const _PinBottomSheet({required super.onSuccess});
}

class _PulsaPackage {
  final int nominal;
  final int bayar;
  const _PulsaPackage({required this.nominal, required this.bayar});
}