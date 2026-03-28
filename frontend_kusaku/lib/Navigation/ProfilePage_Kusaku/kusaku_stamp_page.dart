import 'package:flutter/material.dart';

class KusakuStampPage extends StatelessWidget {
  const KusakuStampPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text(
          'Kusaku Stamp',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: SizedBox(), // TODO: fill in Kusaku Stamp content
      ),
    );
  }
}