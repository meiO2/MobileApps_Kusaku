import 'package:flutter/material.dart';

class KusakuColors {
  static const Color backgroundBlue = Color(0xFFDBEAFE);
  static const Color cardPurple = Color(0xFFD8B4FE);
  static const Color primaryDark = Color(0xFF3B2E4B);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFF93C5FD);
  static const Color fieldBackground = Color(0xFFF3F4F6);
  static const Color hint = Color(0xFF9CA3AF);
}

class KusakuAuthHeader extends StatelessWidget {
  const KusakuAuthHeader({
    required this.logoAsset,
    required this.titleAsset,
    super.key,
  });

  final String logoAsset;
  final String titleAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Column(
        children: [
          Image.asset(
            logoAsset,
            width: 96,
            height: 96,
          ),
          const SizedBox(height: 8),
          Image.asset(
            titleAsset,
            width: 150,
          ),
        ],
      ),
    );
  }
}

class KusakuAuthCard extends StatelessWidget {
  const KusakuAuthCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: KusakuColors.cardPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class KusakuInputField extends StatelessWidget {
  const KusakuInputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KusakuColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: KusakuColors.hint,
          ),
          prefixIcon: const Icon(Icons.circle, color: Colors.transparent, size: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ).copyWith(
          prefixIcon: Icon(icon, color: KusakuColors.primaryDark),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class KusakuGradientButton extends StatelessWidget {
  const KusakuGradientButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KusakuColors.primaryBlue, KusakuColors.lightBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class KusakuBottomPinPanel extends StatelessWidget {
  const KusakuBottomPinPanel({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.lock, size: 18),
                label: const Text(
                  'LOGIN WITH PIN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KusakuColors.primaryDark,
                  side: const BorderSide(color: KusakuColors.primaryDark, width: 2),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}