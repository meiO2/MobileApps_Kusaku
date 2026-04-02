import 'package:flutter/material.dart';
import '../Widgets/payment_confirmation_widgets.dart';

class PaymentConfirmationPage extends StatefulWidget {
  const PaymentConfirmationPage({super.key});

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
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
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: PaymentConfirmationColors.pageBg,
          child: PaymentActionButtons(
            onCancel: () => Navigator.of(context).maybePop(),
            onConfirm: _handlePaymentConfirmation,
            confirmText: 'Bayar',
          ),
        ),
      ),
    );
  }

  void _handlePaymentConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran diproses...'),
        duration: Duration(seconds: 2),
      ),
    );
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
