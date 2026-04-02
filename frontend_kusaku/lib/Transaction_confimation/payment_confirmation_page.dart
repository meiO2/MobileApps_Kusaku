import 'package:flutter/material.dart';

import '../Widgets/kusaku_auth_widgets.dart';
import '../Widgets/payment_confirmation_widgets.dart';

class PaymentConfirmationPage extends StatefulWidget {
  const PaymentConfirmationPage({super.key});

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  static const int _paymentAmount = 50000;
  static const List<PaymentDetailItem> _paymentDetails = [
    PaymentDetailItem(
      label: 'Harga',
      value: 'Rp 50.000',
      valueColor: PaymentConfirmationColors.priceRed,
    ),
    PaymentDetailItem(
      label: 'Biaya Transaksi',
      value: 'Gratis',
      valueColor: PaymentConfirmationColors.priceFree,
    ),
    PaymentDetailItem(
      label: 'Saldo Tersisa',
      value: 'Rp 14.950.000',
      valueColor: PaymentConfirmationColors.priceBlue,
    ),
  ];

  bool _isCategoryOpen = false;
  bool _showSavingConfirmation = false;
  bool _isPaymentSuccessful = false;
  int? _previousSelectedIndex;

  final List<PaymentCategoryOption> _categories = const [
    PaymentCategoryOption('Makan & Minum', Icons.restaurant, 5950000),
    PaymentCategoryOption('Transportasi', Icons.pedal_bike, 6000000),
    PaymentCategoryOption('Investasi', Icons.account_balance, 6000000),
    PaymentCategoryOption('Tabungan', Icons.savings, 6000000, isSaving: true),
    PaymentCategoryOption('Kebutuhan Rumah', Icons.home_filled, 6000000),
    PaymentCategoryOption('Belanja', Icons.shopping_bag, 6000000),
    PaymentCategoryOption('Lainnya', Icons.more_horiz, 6000000),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selected = _categories[_selectedIndex];

    return Scaffold(
      backgroundColor: PaymentConfirmationColors.pageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PaymentConfirmationHeader(title: 'Konfirmasi Pembayaran'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: PaymentMethodTag(
                        label: 'Pembayaran Qris',
                        icon: Icons.qr_code_2_rounded,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const PaymentMerchantCard(),
                    if (_isPaymentSuccessful) ...[
                      const SizedBox(height: 18),
                      Expanded(
                        child: _PaymentSuccessSection(
                          amountLabel: formatPaymentCurrency(_paymentAmount),
                          onBack: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      const PaymentDetailsSection(items: _paymentDetails),
                      const SizedBox(height: 10),
                      Expanded(
                        child: PaymentCategorySection(
                          selectedCategory: selected,
                          categories: _categories,
                          selectedIndex: _selectedIndex,
                          isCategoryOpen: _isCategoryOpen,
                          showSavingConfirmation: _showSavingConfirmation,
                          onToggleCategory: _toggleCategory,
                          onSelectCategory: _selectCategory,
                          onCancelSavingCategory: _cancelSavingCategory,
                          onConfirmSavingCategory: _confirmSavingCategory,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isPaymentSuccessful
          ? null
          : SafeArea(
              top: false,
              child: Container(
                color: PaymentConfirmationColors.pageBg,
                child: PaymentActionButtons(
                  onCancel: () => Navigator.of(context).maybePop(),
                  onConfirm: () {
                    _handlePaymentConfirmation();
                  },
                  confirmText: 'Bayar',
                ),
              ),
            ),
    );
  }

  Future<void> _handlePaymentConfirmation() async {
    final enteredPin = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const KusakuPinInputDialog(
        title: 'Masukan PIN',
      ),
    );

    if (!mounted || enteredPin == null) {
      return;
    }

    setState(() {
      _isPaymentSuccessful = true;
      _isCategoryOpen = false;
      _showSavingConfirmation = false;
      _previousSelectedIndex = null;
    });
  }

  void _toggleCategory() {
    setState(() {
      _showSavingConfirmation = false;
      _isCategoryOpen = !_isCategoryOpen;
    });
  }

  void _selectCategory(int index) {
    final nextCategory = _categories[index];

    setState(() {
      if (nextCategory.isSaving) {
        _previousSelectedIndex = _selectedIndex;
        _selectedIndex = index;
        _showSavingConfirmation = true;
        _isCategoryOpen = false;
        return;
      }

      _selectedIndex = index;
      _previousSelectedIndex = null;
      _showSavingConfirmation = false;
      _isCategoryOpen = false;
    });
  }

  void _cancelSavingCategory() {
    setState(() {
      if (_previousSelectedIndex != null) {
        _selectedIndex = _previousSelectedIndex!;
      }
      _previousSelectedIndex = null;
      _showSavingConfirmation = false;
    });
  }

  void _confirmSavingCategory() {
    setState(() {
      _previousSelectedIndex = null;
      _showSavingConfirmation = false;
    });
  }
}

class _PaymentSuccessSection extends StatelessWidget {
  const _PaymentSuccessSection({
    required this.amountLabel,
    required this.onBack,
  });

  final String amountLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
      decoration: BoxDecoration(
        color: PaymentConfirmationColors.headerDark,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Transaksi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white60, thickness: 1),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/Vector.png',
                  height: 94,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Payment Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF72D44D),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amountLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                const _PaymentSuccessInfoRow(
                  label: 'Produk',
                  value: 'Starbucek',
                ),
                const SizedBox(height: 18),
                const Divider(color: Colors.white60, thickness: 1),
                const SizedBox(height: 18),
                const _PaymentSuccessInfoRow(
                  label: 'Metode Pembayaran',
                  value: 'Qris Kusaku',
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSuccessInfoRow extends StatelessWidget {
  const _PaymentSuccessInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
