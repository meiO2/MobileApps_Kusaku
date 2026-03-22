import 'package:flutter/material.dart';

import '../../Services/transaction_pin_store.dart';
import '../../Services/auth_services/user_credentials_store.dart';
import '../../Widgets/kusaku_auth_widgets.dart';
import '../../home_screen.dart';
import 'phone_signin_screen.dart';
import '../Singup_Screen-frontend/sign_up_screen.dart';
import '../ForgotPassword_Screen-frontend/forgot_password_screen.dart';


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

	@override
	void initState() {
		super.initState();
		_usernameController = TextEditingController();
		_passwordController = TextEditingController();
		_phoneController = TextEditingController();
	}

	@override
	void dispose() {
		_usernameController.dispose();
		_passwordController.dispose();
		_phoneController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: KusakuColors.backgroundBlue,
			bottomNavigationBar: KusakuBottomPinPanel(
				onPressed: () async {
					if (!TransactionPinStore.hasPin) {
						ScaffoldMessenger.of(context).showSnackBar(
							const SnackBar(content: Text('PIN belum dibuat. Selesaikan Sign Up dulu.')),
						);
						return;
					}

					final String? pin = await showDialog<String>(
						context: context,
						builder: (context) => const KusakuPinInputDialog(),
					);

					if (!mounted || pin == null) return;
					if (pin == TransactionPinStore.pin) {
						Navigator.of(context).pushReplacement(
							MaterialPageRoute(builder: (_) => const HomeScreen()),
						);
						return;
					}

					ScaffoldMessenger.of(context).showSnackBar(
						const SnackBar(content: Text('PIN salah. Silakan coba lagi.')), //PIN sementara 123456
					);
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
															style: TextStyle(
																fontSize: 22,
																fontWeight: FontWeight.w700,
															),
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
																style: TextStyle(
																	fontSize: 11,
																	color: KusakuColors.primaryBlue,
																),
															),
														),
													),
													const SizedBox(height: 14),
													Center(
														child: KusakuGradientButton(
															text: 'Log in',
															onPressed: () {
																if (!UserCredentialsStore.hasCredentials) {
																	ScaffoldMessenger.of(context).showSnackBar(
																		const SnackBar(content: Text('Akun belum terdaftar. Selesaikan Sign Up dulu.')),
																	);
																	return;
																}

																final inputUsername = _usernameController.text.trim();
																final inputPassword = _passwordController.text.trim();
																if (inputUsername != UserCredentialsStore.username ||
																	inputPassword != UserCredentialsStore.password) {
																	ScaffoldMessenger.of(context).showSnackBar(
																		const SnackBar(content: Text('Username atau Password salah.')),
																	);
																	return;
																}

																Navigator.of(context).pushReplacement(
																	MaterialPageRoute(builder: (_) => const HomeScreen()),
																);
															},
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
																style: TextStyle(
																	fontSize: 12,
																	color: Color(0xFF1F2937),
																),
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
