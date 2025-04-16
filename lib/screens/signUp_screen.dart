import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/widgets/auth/cupertino_switch.dart';
import 'package:sous_chef/widgets/auth/password_field_signup.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/widgets/personalized_textfield.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../widgets/auth/animated_button.dart';
import '../widgets/auth/shake_widget.dart';
import '../widgets/auth/shake_widget_state.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController restaurantNameController =
      TextEditingController();

  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();
  bool _isChef = false;

  void dispose() {
    // Clean up controllers when the widget is destroyed
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    restaurantNameController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    // Cleaning errors and navigating to home
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearErrors();

    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToLogin() {
    // Cleaning errors
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearErrors();

    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final screenSize = MediaQuery.of(context).size;
            final screenWidth = screenSize.width;
            final screenHeight = screenSize.height;
            final aspectRatio = screenWidth / screenHeight;

            final isTablet = screenWidth > 600 && aspectRatio < 1.6;

            if (isTablet) {
              return _buildTabletLayout(context);
            } else {
              return _buildMobileLayout(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Icon(
              Icons.restaurant,
              size: 150,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Column(children: _buildFormFields(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.05,
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 30),
            child: Icon(
              Icons.restaurant,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
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
      PersonalizedTextField(
        controller: emailController,
        hintText: "Email",
        obscureText: false,
        hasError: authProvider.hasEmailError,
      ),
      const SizedBox(height: 20),
      PasswordFieldSignup(
        textEditingController: passwordController,
        hintText: "Password",
        hasError: authProvider.hasPasswordError,
      ),
      const SizedBox(height: 20),
      PasswordFieldSignup(
        textEditingController: confirmPasswordController,
        hintText: "Confirm Password",
        hasError: authProvider.hasConfirmPasswordError,
      ),
      const SizedBox(height: 20),
      PersonalizedTextField(
        controller: usernameController,
        hintText: "Username",
        obscureText: false,
        hasError: authProvider.hasUsernameError,
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              'Registering as a chef',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: CustomSwitch(
              initialValue: _isChef,
              onChanged: (bool value) {
                setState(() {
                  _isChef = value;
                });
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      if (_isChef)
        PersonalizedTextField(
          controller: restaurantNameController,
          hintText: "Restaurant Name",
          obscureText: false,
          hasError: authProvider.hasRestaurantnameError,
        ),

      if (authProvider.errorMessage != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Center(
            child: Text(
              authProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ),

      const SizedBox(height: 30),

      ShakeWidget(
        key: _shakeKey,
        shakeOffset: 10,
        child: AnimatedButton(
          onTap: () async {
            if (emailController.text.isEmpty ||
                passwordController.text.isEmpty ||
                confirmPasswordController.text.isEmpty ||
                (restaurantNameController.text.isEmpty && _isChef) ||
                passwordController.text != confirmPasswordController.text ||
                passwordController.text.length <= 6) {
              _shakeKey.currentState?.shake();
              authProvider.setFieldErrors(
                emptyEmail: emailController.text.isEmpty,
                emptyPassword: passwordController.text.isEmpty,
                emptyConfirmPassword: confirmPasswordController.text.isEmpty,
                emptyRestaurantname:
                    restaurantNameController.text.isEmpty && _isChef,
                emptyUsername: usernameController.text.isEmpty,
                invalidConfirmPassword:
                    passwordController.text != confirmPasswordController.text,
                invalidPassword: passwordController.text.length <= 6,
              );
            } else {
              // Calling the sign-up method from the provider
              await authProvider.signUp(
                email: emailController.text,
                password: passwordController.text,
                username: usernameController.text,
                restaurantName: _isChef ? restaurantNameController.text : null,
              );

              // Verify if the widget is still mounted before navigating
              if (mounted) {
                // Check if the sign-up was successful
                if (authProvider.errorMessage == null) {
                  _navigateToHome();
                } else {
                  _shakeKey.currentState?.shake();
                }
              }
            }
          },
          child: PersonalizedButton(
            text: "SignUp",
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
          Text("Do you already have an account?"),
          TextButton(
            onPressed: () {
              // Navigate to sign up screen
              _navigateToLogin();
            },
            child: Text("Login"),
          ),
        ],
      ),

      const SizedBox(height: 20),
    ];
  }
}
