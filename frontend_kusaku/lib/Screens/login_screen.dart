import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // Warna tema aplikasi Kusaku
    const Color primaryDark = Color(0xFF3B2E4B);
    const Color primaryLight = Color(0xFF93C5FD);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          
          // FORM LOGIN UTAMA (USERNAME & PASS)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Welcome Back!",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Silakan masuk untuk mengatur pengeluaranmu.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // TextField Username / No. HP
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Username / No. HP",
                      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryDark, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TextField Password
                  TextField(
                    obscureText: true, // Menyamarkan teks password
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryDark, width: 2),
                      ),
                      suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Tombol Login Utama
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Aksi saat tombol login ditekan
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),