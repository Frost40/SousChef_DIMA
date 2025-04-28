import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../widgets/auth/animated_button.dart';
import '../widgets/auth/custom_social_button.dart';
import '../widgets/auth/or_divider.dart';
import '../widgets/auth/auth_input_field.dart';
import '../widgets/auth/shake_widget.dart';
import '../widgets/auth/shake_widget_state.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void dispose() {
    // Clean up controllers when the widget is destroyed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    // Cleaning errors
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearErrors();

    // Navigate to home screen
    Navigator.of(context, rootNavigator: true).pushReplacementNamed('/main');
  }

  void _navigateToSignUp() {
    // Cleaning errors
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearErrors();

    // Navigate to sign up screen
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final screenSize = MediaQuery.of(context).size;
              final screenWidth = screenSize.width;
              final screenHeight = screenSize.height;
              final aspectRatio = screenWidth / screenHeight;

              final isTablet =
                  screenWidth > 600 &&
                  aspectRatio < 1.6; 

              if (isTablet) {
                return _buildTabletLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          ),
        ),
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
    // Access authentication provider
    final authProvider = Provider.of<AuthProvider>(context);

    return [
      const SizedBox(height: 20),
      AuthInputField(
        textEditingController: emailController,
        hintText: "Email",
        leftIcon: Icons.email_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        // Highlight field with error border if there's an email-related error
        hasError: authProvider.hasEmailError,
      ),

      const SizedBox(height: 20),

      AuthInputField(
        textEditingController: passwordController,
        hintText: "Password",
        isPassword: true,
        leftIcon: Icons.key_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        // Highlight field with error border if there's a password-related error
        hasError: authProvider.hasPasswordError,
      ),

      // Display error messages from the provider
      if (authProvider.errorMessage != null)
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Center(
            child: Text(
              authProvider.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ),

      const SizedBox(height: 20),

      ShakeWidget(
        key: _shakeKey,
        shakeOffset: 10,
        child: AnimatedButton(
          onTap: () async {
            if (emailController.text.isEmpty ||
                passwordController.text.isEmpty) {
              _shakeKey.currentState?.shake();
              authProvider.setFieldErrors(
                emptyEmail: emailController.text.isEmpty,
                emptyPassword: passwordController.text.isEmpty,
              );
            } else {
              // Authentication process via provider
              await authProvider.signIn(
                emailController.text.trim(),
                passwordController.text,
              );

              if (mounted) {
                if (authProvider.isAuthenticated) {
                  _navigateToHome();
                } else {
                  // Optic feedback if login fails
                  _shakeKey.currentState?.shake();
                }
              }
            }
          },
          child: PersonalizedButton(
            text: "Login",
            onPressed: null,
            centralWidget:
                authProvider.isLoading
                    ? LoadingAnimationWidget.staggeredDotsWave(
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 30,
                    )
                    : null,
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
              _navigateToSignUp();
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
        onTap: () async {
          // Authentication process via provider
          await authProvider.signInWithGoogle();

          if (mounted) {
            if (authProvider.isAuthenticated) {
              _navigateToHome();
            }
          }
        },
        icon: 'assets/google.svg',
        text: 'Join using Google',
        margin: 0,
      ),
    ];
  }
}
