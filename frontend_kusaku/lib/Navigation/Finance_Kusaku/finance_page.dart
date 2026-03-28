import 'package:flutter/material.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Finance'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: const SizedBox(),
    );
  }
}