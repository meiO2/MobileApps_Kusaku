import 'package:flutter/material.dart';

class PaymentConfirmationColors {
  static const Color headerDark = Color(0xFF1E3A8A);
  static const Color pageBg = Color(0xFFF4F8FF);
  static const Color paymentMethodBg = Color(0xFFBCDEFF);
  static const Color paymentMethodText = Color(0xFF575AFF);
  static const Color sectionBg = Color(0xFFE3FCFF);
  static const Color detailLabel = Color(0xFF1A1A1A);
  static const Color priceRed = Color(0xFFFF0004);
  static const Color priceFree = Color(0xFF00A80B);
  static const Color priceBlue = Color(0xFF407CFF);
  static const Color categoryAmount = Color(0xFF00388D);
  static const Color selectedCategoryBg = Color(0xFFE3E5E8);
  static const Color savingCategoryBg = Color(0xFFFF8686);
  static const Color savingConfirmationBg = Color(0xFFFFC1C1);
  static const Color buttonCancel = Color(0xFFFCA5A5);
  static const Color buttonPay = Color(0xFF4032FF);
  static const Color borderGrey = Color(0xFFD5D8DE);
}

class PaymentConfirmationHeader extends StatelessWidget {
  const PaymentConfirmationHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 6, bottom: 22),
      decoration: const BoxDecoration(color: PaymentConfirmationColors.headerDark),
      child: Column(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0B0B0D),
              border: Border.all(color: const Color(0xFF12246B), width: 2),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentCardShell extends StatelessWidget {
  const PaymentCardShell({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6D9DE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PaymentMethodTag extends StatelessWidget {
  const PaymentMethodTag({required this.label, this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: PaymentConfirmationColors.paymentMethodBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: PaymentConfirmationColors.paymentMethodText, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF081223),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}