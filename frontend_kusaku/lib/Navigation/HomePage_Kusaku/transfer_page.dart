import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_pulsa_page.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

enum _TransferStep {
  selectMethod,
  selectRecipient,
  enterDetails,
  confirm,
  pinVerify,
  success,
}

class _TransferPageState extends State<TransferPage> {
  _TransferStep _step = _TransferStep.selectMethod;
  String _selectedMethod = '';
  String _recipientCode = '';
  String _recipientName = '';
  String _amount = '';
  String _pesan = '';

  final TextEditingController _pesanController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  static const int _maxTransfer = 30000000;

  // Dummy recipients — TODO: replace with real API data
  final List<_Recipient> _allRecipients = const [
    _Recipient(code: '1414 2323 45', name: 'Badrul'),
    _Recipient(code: '0812 3456 789', name: 'Siti'),
    _Recipient(code: '0898 7654 321', name: 'Andi'),
    _Recipient(code: '1234 5678 90', name: 'Rina'),
  ];

  List<_Recipient> get _filtered {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _allRecipients;
    return _allRecipients
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.code.toLowerCase().contains(q))
        .toList();
  }

  int get _amountInt => int.tryParse(_amount) ?? 0;

  String _formatRp(int v) => v
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  void _onAmountKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amount.isNotEmpty)
          _amount = _amount.substring(0, _amount.length - 1);
      } else {
        final next = _amount + key;
        final val = int.tryParse(next) ?? 0;
        if (val <= _maxTransfer) {
          _amount = next;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimal transfer adalah Rp 30.000.000'),
              backgroundColor: Color(0xFFDC2626),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _goBack() {
    setState(() {
      switch (_step) {
        case _TransferStep.selectRecipient:
          _step = _TransferStep.selectMethod;
          break;
        case _TransferStep.enterDetails:
          _step = _TransferStep.selectRecipient;
          break;
        case _TransferStep.confirm:
          _step = _TransferStep.enterDetails;
          break;
        case _TransferStep.pinVerify:
          _step = _TransferStep.confirm;
          break;
        case _TransferStep.success:
          _reset();
          break;
        default:
          Navigator.of(context).pop();
      }
    });
  }

  void _reset() {
    setState(() {
      _step = _TransferStep.selectMethod;
      _selectedMethod = '';
      _recipientCode = '';
      _recipientName = '';
      _amount = '';
      _pesan = '';
      _pesanController.clear();
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _pesanController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D4ED8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Kusaku',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _step == _TransferStep.selectMethod
              ? () => Navigator.of(context).pop()
              : _goBack,
        ),
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _TransferStep.selectMethod:
        return _buildSelectMethod();
      case _TransferStep.selectRecipient:
        return _buildSelectRecipient();
      case _TransferStep.enterDetails:
        return _buildEnterDetails();
      case _TransferStep.confirm:
        return _buildConfirm();
      case _TransferStep.pinVerify:
        return _buildPinStep();
      case _TransferStep.success:
        return _buildSuccess();
    }
  }

  // ── Step 1: Choose method ──
  Widget _buildSelectMethod() {
    return Container(
      key: const ValueKey('method'),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // TODO: replace with real Kode Kusaku from session
            const Text(
              'Kode Kusaku: 081234567890',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MethodButton(
                    icon: Icons.account_circle_outlined,
                    label: 'Kusaku',
                    onTap: () => setState(() {
                      _selectedMethod = 'Kusaku';
                      _step = _TransferStep.selectRecipient;
                    }),
                  ),
                  _MethodButton(
                    icon: Icons.account_balance_outlined,
                    label: 'Bank Lain',
                    onTap: () => setState(() {
                      _selectedMethod = 'Bank Lain';
                      _step = _TransferStep.selectRecipient;
                    }),
                  ),
                  _MethodButton(
                    icon: Icons.credit_card_outlined,
                    label: 'Virtual\nAccount',
                    onTap: () => setState(() {
                      _selectedMethod = 'Virtual Account';
                      _step = _TransferStep.selectRecipient;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.search, size: 18, color: Color(0xFF6B7280)),
                SizedBox(width: 6),
                Text('Terakhir',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(width: 24),
                Text('Favorit',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Cari tujuan transfer',
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Pick recipient ──
  Widget _buildSelectRecipient() {
    return Container(
      key: const ValueKey('recipient'),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: replace with real Kode Kusaku from session
            const Text(
              'Kode Kusaku: 081234567890',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Masukkan kode kusaku/no. handphone',
                hintStyle: const TextStyle(
                    fontSize: 13, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFF1D4ED8),
                hintMaxLines: 1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                suffixStyle: const TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.search, size: 18, color: Color(0xFF6B7280)),
                SizedBox(width: 6),
                Text('Terakhir',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(width: 24),
                Text('Favorit',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Cari tujuan transfer',
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final r = _filtered[i];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFBFDBFE),
                      child: Icon(Icons.person, color: Color(0xFF1D4ED8)),
                    ),
                    title: Text(r.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(r.code),
                    onTap: () => setState(() {
                      _recipientCode = r.code;
                      _recipientName = r.name;
                      _step = _TransferStep.enterDetails;
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Amount + pesan ──
  Widget _buildEnterDetails() {
    return Container(
      key: const ValueKey('details'),
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tujuan Transfer',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_recipientCode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text(_recipientName,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Dari Akun:',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280))),
                  // TODO: real from session
                  const Text('Kode Kusaku: 081234567890',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  const Text('Jumlah',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Row(
                    children: [
                      const Text('IDR  ',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6B7280))),
                      Text(
                        _amount.isEmpty ? '0' : _formatRp(_amountInt),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _amount.isEmpty
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),
                  const Text('Pesan',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  TextField(
                    controller: _pesanController,
                    onChanged: (v) => _pesan = v,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan (opsional)',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 13),
                    ),
                  ),
                  const Divider(color: Color(0xFFE5E7EB)),
                ],
              ),
            ),
          ),

          // Numpad + button pinned to bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                '1', '2', '3',
                '4', '5', '6',
                '7', '8', '9',
                '',  '0', '⌫',
              ].map((key) {
                if (key.isEmpty) return const SizedBox();
                return TextButton(
                  onPressed: () => _onAmountKey(key),
                  child: Text(key,
                      style: TextStyle(
                        fontSize: key == '⌫' ? 18 : 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D4ED8),
                      )),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _amountInt > 0
                    ? () => setState(
                        () => _step = _TransferStep.confirm)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  disabledBackgroundColor: const Color(0xFFBFDBFE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Konfirmasi',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Confirm ──
  Widget _buildConfirm() {
    return Container(
      key: const ValueKey('confirm'),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Konfirmasi Transfer',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // TODO: real from session
                  _ConfirmBlock(title: 'Dari Akun:', lines: [
                    '081234567890',
                    'Kasepiano',
                  ]),
                  const Divider(color: Colors.white24, height: 24),
                  _ConfirmBlock(title: 'Tujuan', lines: [
                    _recipientCode,
                    _recipientName,
                  ]),
                  const Divider(color: Colors.white24, height: 24),
                  _ConfirmBlock(title: 'Jumlah', lines: [
                    'IDR',
                    _formatRp(_amountInt),
                  ]),
                  if (_pesan.isNotEmpty) ...[
                    const Divider(color: Colors.white24, height: 24),
                    _ConfirmBlock(title: 'Pesan', lines: [_pesan]),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    setState(() => _step = _TransferStep.pinVerify),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 38, 109),
                  foregroundColor: Colors.white,
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
    );
  }

  // ── Step 5: PIN ──
  Widget _buildPinStep() {
    // Show PIN sheet on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_step == _TransferStep.pinVerify && mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => PinBottomSheet(
            onSuccess: () {
              Navigator.of(context).pop();
              setState(() => _step = _TransferStep.success);
            },
          ),
        );
      }
    });

    return Container(
      key: const ValueKey('pin'),
      color: Colors.white,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  // ── Step 6: Success ──
  Widget _buildSuccess() {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Container(
      key: const ValueKey('success'),
      color: const Color(0xFF1D4ED8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Transfer" label with divider — matches the design
            const Center(
              child: Text(
                'Transfer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),

            // Green success card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.insert_drive_file_outlined,
                      color: Color(0xFF16A34A), size: 85),
                  const SizedBox(height: 10),
                  const Text(
                    'Transfer Successful!',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatRp(_amountInt)}',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.bold,
                      height: 2.5,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Summary rows — matches design layout
            _SuccessRow(
                label: 'Dari Akun:', value: '081234567890'), // TODO: real
            _SuccessRow(label: 'Tanggal  :', value: dateStr),
            _SuccessRow(label: 'Tujuan   :', value: _recipientCode),

            const Spacer(),

            // White outlined Konfirmasi button at bottom
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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
    );
  }
}

// ── Helper widgets ──

class _MethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MethodButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF1D4ED8), size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ConfirmBlock extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _ConfirmBlock({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        ...lines.map((l) => Text(l,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14))),
      ],
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final String label;
  final String value;
  const _SuccessRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _Recipient {
  final String code;
  final String name;
  const _Recipient({required this.code, required this.name});
}