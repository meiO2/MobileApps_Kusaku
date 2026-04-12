import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Services/transaction_pin_store.dart';

import 'payment_confirmation_models.dart';
import '../Widgets/kusaku_auth_widgets.dart';
import '../Widgets/payment_confirmation_widgets.dart';

class PaymentConfirmationPage extends StatefulWidget {
  PaymentConfirmationPage({
    super.key,
    PaymentConfirmationData? data,
    this.onSubmitPayment,
  })  : data = data ?? _defaultPaymentData,
        assert((data ?? _defaultPaymentData).categories.length > 0, 'Payment categories must not be empty');

  final PaymentConfirmationData data;
  final Future<PaymentSubmissionResult> Function(
    PaymentSubmissionPayload payload,
  )? onSubmitPayment;

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  bool _isCategoryOpen = false;
  bool _showSavingConfirmation = false;
  PaymentFlowStatus _paymentStatus = PaymentFlowStatus.idle;
  int? _previousSelectedIndex;
  String? _errorMessage;

  int _selectedIndex = 0;

  bool get _isPaymentSuccessful => _paymentStatus == PaymentFlowStatus.success;
  bool get _isSubmitting => _paymentStatus == PaymentFlowStatus.submitting;
  List<PaymentCategoryData> get _categories => widget.data.categories;
  List<PaymentDetailLine> get _paymentDetails => buildPaymentDetailLines(
    amount: widget.data.amount,
    transactionFee: widget.data.transactionFee,
    remainingBalance: widget.data.remainingBalance,
  );

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
                    Center(
                      child: PaymentMethodTag(
                        label: widget.data.methodLabel,
                        icon: paymentMethodIcon(widget.data.methodType),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PaymentMerchantCard(merchant: widget.data.merchant),
                    if (_isPaymentSuccessful) ...[
                      const SizedBox(height: 18),
                      Expanded(
                        child: _PaymentSuccessSection(
                          title: widget.data.successTitle,
                          amountLabel: formatPaymentCurrency(widget.data.amount),
                          merchantName: widget.data.merchant.name,
                          methodLabel:
                              widget.data.successMethodLabel ?? widget.data.methodLabel,
                          onBack: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      PaymentDetailsSection(items: _paymentDetails),
                      const SizedBox(height: 10),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: PaymentConfirmationColors.priceRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
                  confirmText: _isSubmitting ? 'Memproses...' : 'Bayar',
                  isCancelEnabled: !_isSubmitting,
                  isConfirmEnabled: !_isSubmitting,
                ),
              ),
            ),
    );
  }

  Future<void> _handlePaymentConfirmation() async {
    if (_isSubmitting) {
      return;
    }

    final enteredPin = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const KusakuPinInputDialog(
        title: 'Masukan PIN',
      ),
    );

    if (!mounted || enteredPin == null) {
      return;
    }

    final localPin = TransactionPinStore.pin;
    if (localPin != null && localPin.isNotEmpty && enteredPin != localPin) {
      setState(() {
        _paymentStatus = PaymentFlowStatus.failure;
        _errorMessage = 'PIN yang dimasukkan tidak sesuai.';
      });
      return;
    }

    setState(() {
      _paymentStatus = PaymentFlowStatus.submitting;
      _errorMessage = null;
    });

    final result = await _submitPayment(enteredPin);

    if (!mounted) {
      return;
    }

    setState(() {
      _isCategoryOpen = false;
      _showSavingConfirmation = false;
      _previousSelectedIndex = null;
      _paymentStatus =
          result.isSuccess ? PaymentFlowStatus.success : PaymentFlowStatus.failure;
      _errorMessage = result.isSuccess ? null : result.errorMessage;
    });
  }

  Future<PaymentSubmissionResult> _submitPayment(String enteredPin) async {
    final selectedCategory = _categories[_selectedIndex];
    final payload = PaymentSubmissionPayload(
      transactionId: widget.data.transactionId,
      categoryId: selectedCategory.id,
      pin: enteredPin,
      amount: widget.data.amount,
      methodType: widget.data.methodType,
      usedSavingBalance: selectedCategory.isSaving,
    );

    if (widget.onSubmitPayment != null) {
      try {
        final result = await widget.onSubmitPayment!(payload);
        if (result.isSuccess || (result.errorMessage?.isNotEmpty ?? false)) {
          return result;
        }

        return const PaymentSubmissionResult(
          isSuccess: false,
          errorMessage: 'Transaksi gagal diproses.',
        );
      } catch (_) {
        return const PaymentSubmissionResult(
          isSuccess: false,
          errorMessage: 'Terjadi kendala saat memproses pembayaran.',
        );
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const PaymentSubmissionResult(isSuccess: true);
  }

  void _toggleCategory() {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _showSavingConfirmation = false;
      _isCategoryOpen = !_isCategoryOpen;
    });
  }

  void _selectCategory(int index) {
    if (_isSubmitting) {
      return;
    }

    final nextCategory = _categories[index];

    setState(() {
      _errorMessage = null;
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
    if (_isSubmitting) {
      return;
    }

    setState(() {
      if (_previousSelectedIndex != null) {
        _selectedIndex = _previousSelectedIndex!;
      }
      _previousSelectedIndex = null;
      _showSavingConfirmation = false;
    });
  }

  void _confirmSavingCategory() {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _previousSelectedIndex = null;
      _showSavingConfirmation = false;
    });
  }
}

class _PaymentSuccessSection extends StatelessWidget {
  const _PaymentSuccessSection({
    required this.title,
    required this.amountLabel,
    required this.merchantName,
    required this.methodLabel,
    required this.onBack,
  });

  final String title;
  final String amountLabel;
  final String merchantName;
  final String methodLabel;
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
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                _PaymentSuccessInfoRow(
                  label: 'Produk',
                  value: merchantName,
                ),
                const SizedBox(height: 18),
                const Divider(color: Colors.white60, thickness: 1),
                const SizedBox(height: 18),
                _PaymentSuccessInfoRow(
                  label: 'Metode Pembayaran',
                  value: methodLabel,
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

final PaymentConfirmationData _defaultPaymentData = PaymentConfirmationData(
  transactionId: 'sample-transaction',
  methodType: PaymentMethodType.qris,
  methodLabel: 'Pembayaran Qris',
  amount: 50000,
  transactionFee: 0,
  remainingBalance: 14950000,
  merchant: PaymentMerchantInfo(
    name: 'Starbucek',
    accountName: 'a.n. PT Starbucek Indonesia',
    transactedAt: DateTime(2026, 3, 1, 12, 0),
    logoText: 'S',
  ),
  categories: [
    PaymentCategoryData(
      id: 'food-drink',
      name: 'Makan & Minum',
      icon: Icons.restaurant,
      remainingAmount: 5950000,
    ),
    PaymentCategoryData(
      id: 'transport',
      name: 'Transportasi',
      icon: Icons.pedal_bike,
      remainingAmount: 6000000,
    ),
    PaymentCategoryData(
      id: 'investment',
      name: 'Investasi',
      icon: Icons.account_balance,
      remainingAmount: 6000000,
    ),
    PaymentCategoryData(
      id: 'saving',
      name: 'Tabungan',
      icon: Icons.savings,
      remainingAmount: 6000000,
      isSaving: true,
    ),
    PaymentCategoryData(
      id: 'home-needs',
      name: 'Kebutuhan Rumah',
      icon: Icons.home_filled,
      remainingAmount: 6000000,
    ),
    PaymentCategoryData(
      id: 'shopping',
      name: 'Belanja',
      icon: Icons.shopping_bag,
      remainingAmount: 6000000,
    ),
    PaymentCategoryData(
      id: 'other',
      name: 'Lainnya',
      icon: Icons.more_horiz,
      remainingAmount: 6000000,
    ),
  ],
  successMethodLabel: 'Qris Kusaku',
);

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
