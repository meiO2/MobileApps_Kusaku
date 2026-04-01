import 'package:flutter/material.dart';
import '../Widgets/payment_confirmation_widgets.dart';

class PaymentConfirmationPage extends StatefulWidget {
  const PaymentConfirmationPage({super.key});

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  bool _isCategoryOpen = false;
  bool _showSavingConfirmation = false;
  int? _previousSelectedIndex;

  final List<PaymentCategoryOption> _categories = const [
    PaymentCategoryOption('Makan & Minum', Icons.restaurant, 'Rp 5.950.000'),
    PaymentCategoryOption('Transportasi', Icons.pedal_bike, 'Rp 6.000.000'),
    PaymentCategoryOption('Investasi', Icons.account_balance, 'Rp 6.000.000'),
    PaymentCategoryOption('Tabungan', Icons.savings, 'Rp 6.000.000', isSaving: true),
    PaymentCategoryOption('Kebutuhan Rumah', Icons.home_filled, 'Rp 6.000.000'),
    PaymentCategoryOption('Belanja', Icons.shopping_bag, 'Rp 6.000.000'),
    PaymentCategoryOption('Lainnya', Icons.more_horiz, 'Rp 6.000.000'),
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
                    