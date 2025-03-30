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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final screenSize = MediaQuery.of(context).size;
          final screenWidth = screenSize.width;
          final screenHeight = screenSize.height;
          final aspectRatio = screenWidth / screenHeight;

          final isTablet = screenWidth > 600 && aspectRatio < 1.6; // Regola il valore di aspectRatio se necessario

          if (isTablet) {
            return _buildTabletLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  // icon positioning for tablet
  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Icon(
              Icons.restaurant,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildFormFields(context),
            ),
          ),
        ),
      ],
    );
  }

  // icon positioning for mobile
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          ..._buildFormFields(context),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields(BuildContext context) {
    return [
      const SizedBox(height: 20),
      AuthInputField(
        textEditingController: emailController,
        hintText: "Email",
        leftIcon: Icons.email_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
      ),

      const SizedBox(height: 20),

      AuthInputField(
        textEditingController: passwordController,
        hintText: "Password",
        isPassword: true,
        leftIcon: Icons.key_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
      ),

      const SizedBox(height: 20),

      ShakeWidget(
        key: _shakeKey,
        shakeOffset: 10,
        child: AnimatedButton(
          onTap: () {
            if (emailController.text.isEmpty || passwordController.text.isEmpty) {
              _shakeKey.currentState?.shake();
            } else {
              // Proceed with login logic
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          child: PersonalizedButton(
            text: "Login",
            onPressed: null,
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account?"),
          TextButton(
            onPressed: () {
              // Navigate to sign up screen
              Navigator.of(context).pushReplacementNamed('/signup');
            },
            child: Text("Sign up"),
          ),
        ],
      ),

      const SizedBox(height: 20),
      const DividerWithText(),
      const SizedBox(height: 20),

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
    ];
  }
}