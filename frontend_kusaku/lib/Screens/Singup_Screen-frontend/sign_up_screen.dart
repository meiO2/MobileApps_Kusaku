import 'package:flutter/material.dart';

import '../../Widgets/kusaku_auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KusakuColors.backgroundBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            children: [
              const KusakuAuthHeader(
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
                        children: [
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
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          KusakuInputField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm Password',
                            icon: Icons.lock,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          KusakuInputField(
                            controller: _emailController,
                            hintText: 'Email address',
                            icon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          KusakuInputField(
                            controller: _phoneController,
                            hintText: 'Phone Number',
                            icon: Icons.smartphone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: KusakuGradientButton(
                              text: 'Sign Up',
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Log in',
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
