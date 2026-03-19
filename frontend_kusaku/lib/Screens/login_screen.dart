import 'package:flutter/material.dart';

import '../Widgets/kusaku_auth_widgets.dart';

class LoginScreen extends StatelessWidget {
	const LoginScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: KusakuColors.backgroundBlue,
			body: SafeArea(
				child: Column(
					children: const [
						KusakuAuthHeader(
							logoAsset: 'assets/images/Logo.png',
							titleAsset: 'assets/images/KUSAKU.png',
						),
						SizedBox(height: 10),
						Expanded(
							child: Align(
								alignment: Alignment.topCenter,
								child: FractionallySizedBox(
									heightFactor: 0.80,
									widthFactor: 0.95,
									child: KusakuAuthCard(
										child: SizedBox.expand(),
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
