import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Your existing imports
import '../../Services/transaction_pin_store.dart';
import '../../Widgets/kusaku_auth_widgets.dart';
import 'phone_signin_screen.dart';
import '../Singup_Screen-frontend/sign_up_screen.dart';
import '../ForgotPassword_Screen-frontend/forgot_password_screen.dart';
import 'package:frontend_kusaku/navbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  bool _obscurePassword = true;
  bool _isLoading = false; // Tracks API request status

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _loadLastSession(); // Auto-fill username if exists
  }

  // Logic to "Remember" the last user for PIN access
  Future<void> _loadLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('last_username');
    if (savedUsername != null) {
      setState(() {
        _usernameController.text = savedUsername;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- API LOGIC: CONNECTING TO DJANGO ---
  Future<void> _handleLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in both fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Hits your Django Login View
      final response = await http.post(
        Uri.parse('http://10.93.20.130:8000/api/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // PERSISTENCE: Save session data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_username', username);
        await prefs.setInt('user_id', data['user_id']); 

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(errorData['error'] ?? 'Username or password incorrect');
      }
    } catch (e) {
      _showSnackBar('Connection failed. Is the server running on 10.93.20.130?');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KusakuColors.backgroundBlue,
      bottomNavigationBar: KusakuBottomPinPanel(
        onPressed: () async {
          // PIN Path: Only works if a username is in the controller (already logged in once)
          if (_usernameController.text.isEmpty) {
            _showSnackBar('Please login with your password first.');
            return;
          }

          if (!TransactionPinStore.hasPin) {
            _showSnackBar('PIN belum dibuat. Selesaikan Sign Up dulu.');
            return;
          }

          final String? pin = await showDialog<String>(
            context: context,
            builder: (context) => const KusakuPinInputDialog(),
          );

          if (!mounted || pin == null) return;

          // Check PIN against your local TransactionPinStore
          if (pin == TransactionPinStore.pin) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainShell()), 
            );
          } else {
            _showSnackBar('PIN salah. Silakan coba lagi.');
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              KusakuAuthHeader(
                logoAsset: 'assets/images/Logo.png',
                titleAsset: 'assets/images/KUSAKU.png',
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.95,
                  child: KusakuAuthCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Welcome Back!',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 18),
                          KusakuInputField(
                            controller: _usernameController,
                            hintText: 'Username',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 10),
                          KusakuInputField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(top: 10, right: 12),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 11, color: KusakuColors.primaryBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: _isLoading 
                              ? const CircularProgressIndicator()
                              : KusakuGradientButton(
                                  text: 'Log in',
                                  onPressed: _handleLogin,
                                ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            thickness: 2,
                            color: Color(0xFF9F8BC9),
                          ),
                          const SizedBox(height: 20),
                          KusakuInputField(
                            controller: _phoneController,
                            hintText: 'Phone Number',
                            icon: Icons.smartphone,
                            keyboardType: TextInputType.phone,
                            readOnly: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PhoneSignInScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account yet? ",
                                style: TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: KusakuColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}