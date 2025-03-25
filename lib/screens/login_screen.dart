import 'package:flutter/material.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/widgets/personalized_textfield.dart';

import '../widgets/auth/animated_button.dart';
import '../widgets/auth/custom_social_button.dart';
import '../widgets/auth/or_divider.dart';
import '../widgets/auth/auth_input_field.dart';
import '../widgets/auth/shake_widget.dart';
import '../widgets/auth/shake_widget_state.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // logo
          Icon(
            Icons.restaurant,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 20),

          // email field
          AuthInputField(
            textEditingController: emailController,
            hintText: "Email",
            leftIcon: Icons.email_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 20),

          // password field
          AuthInputField(
            textEditingController: passwordController,
            hintText: "Password",
            isPassword: true,
            leftIcon: Icons.key_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 20),

          // login button with shake animation
          ShakeWidget(
            key: _shakeKey,
            shakeOffset: 10,
            child: AnimatedButton(
              onTap: () {
                if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                  _shakeKey.currentState?.shake();
                } else {
                  // Proceed with login logic
                  // Add your login implementation here
                }
              },
              child: PersonalizedButton(
                text: "Login",
                onPressed: null, // We're handling the tap in AnimatedButton
              ),
            ),
          ),

          // Rest of your widgets remain unchanged
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  // Navigate to sign up screen
                },
                child: Text("Sign up"),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const DividerWithText(),
          const SizedBox(height: 20),

          // Social buttons
          CustomSocialButton(
            onTap: () {},
            icon: 'assets/facebook.svg',
            text: 'Join using Facebook',
            margin: 0,
          ),

          const SizedBox(height: 20),

          CustomSocialButton(
            onTap: () {},
            icon: 'assets/google.svg',
            text: 'Join using Google',
            margin: 0,
          ),
        ]
      ),
    );
  }
}