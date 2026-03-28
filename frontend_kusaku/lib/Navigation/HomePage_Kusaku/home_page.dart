import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: const SizedBox(),
    );
  }
}