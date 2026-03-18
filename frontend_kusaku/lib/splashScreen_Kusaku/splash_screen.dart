import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // 1. Animasi Putaran Logo
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4), 
      vsync: this,
    )..repeat();

    // 2. Timer 3 detik, lalu pindah INSTAN ke halaman login
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreenPlaceholder(),
          transitionDuration: Duration.zero, // Transisi Instan sesuai request
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF93C5FD), // Latar belakang biru muda
      body: Stack(
        children: [
          // Bagian Tengah: Logo (Berputar) dan Judul "KUSAKU"
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo berputar
                RotationTransition(
                  turns: _rotationController,
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: 100, // Sesuaikan ukuran
                  ),
                ),
                const SizedBox(height: 20),
                // Gambar Teks "KUSAKU"
                Image.asset(
                  'assets/images/KUSAKU.png',
                  width: 150, // Sesuaikan ukuran
                ),
              ],
            ),
          ),
          // Bagian Bawah: Gambar Tagline
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Image.asset(
                'assets/images/Ayo Atur Pengeluaranmu!.png',
                width: 250, // Sesuaikan ukuran
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder Login Screen
class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Halaman Login"),
      ),
    );
  }
}