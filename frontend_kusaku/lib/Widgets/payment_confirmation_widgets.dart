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

class PaymentDetailsSection extends StatelessWidget {
  const PaymentDetailsSection({required this.items, super.key});

  final List<PaymentDetailItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: PaymentConfirmationColors.sectionBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9DCE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(
              'Rincian Pembayaran',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
            child: PaymentCardShell(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 18,
                  color: Color(0xFFE5E1E1),
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 17,
                            color: PaymentConfirmationColors.detailLabel,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          item.value,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: item.valueColor ?? Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentDetailItem {
  PaymentDetailItem({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}

class PaymentCategoryTile extends StatelessWidget {
  const PaymentCategoryTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.highlightColor,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color? highlightColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: highlightColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6D9DE)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: const Color(0xFF407CFF), size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: PaymentConfirmationColors.categoryAmount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentCategoryOption {
  const PaymentCategoryOption(
    this.name,
    this.icon,
    this.amount, {
    this.isSaving = false,
  });

  final String name;
  final IconData icon;
  final String amount;
  final bool? isSaving;
}

class PaymentMerchantCard extends StatelessWidget {
  const PaymentMerchantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: PaymentCardShell(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC2C2C2)),
                color: const Color(0xFFF2F6F8),
              ),
              child: const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A7A57),
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Starbucek',
                    style: TextStyle(
                      fontSize: 39 / 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'a.n. PT Starbucek Indonesia',
                    style: TextStyle(
                      fontSize: 32 / 2,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black87),
                      SizedBox(width: 6),
                      Text(
                        '1 Maret 2026 | 12.00 WIB',
                        style: TextStyle(
                          fontSize: 31 / 2,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

