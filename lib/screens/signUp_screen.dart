import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/widgets/auth/cupertino_switch.dart';
import 'package:sous_chef/widgets/auth/password_field_signup.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/widgets/personalized_textfield.dart';

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
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController restaurantNameController = TextEditingController();

  bool _isPasswordSixCharacters = false;
  bool _isEmailWellFormatted = false;

  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();
  bool _isChef = false;

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

            final isTablet = screenWidth > 600 && aspectRatio < 1.6; // Regola il valore di aspectRatio se necessario

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
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.05, horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              children: _buildFormFields(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.05),
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
      ),
      const SizedBox(height: 20),
      PasswordFieldSignup(
        textEditingController: passwordController,
        hintText: "Password",
      ),
      const SizedBox(height: 20),
      PasswordFieldSignup(
        textEditingController: confirmPasswordController,
        hintText: "Confirm Password",
      ),
      const SizedBox(height: 20),
      PersonalizedTextField(
        controller: usernameController,
        hintText: "Username",
        obscureText: false,
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
        ),
      const SizedBox(height: 30),
      ShakeWidget(
        key: _shakeKey,
        shakeOffset: 10,
        child: AnimatedButton(
          onTap: () {
            if (emailController.text.isEmpty || passwordController.text.isEmpty) {
              _shakeKey.currentState?.shake();
            } else {
              // Procedi con la logica di registrazione
              authProvider.signUp(
                email: emailController.text,
                password: passwordController.text,
                name: nameController.text,
                surname: surnameController.text,
                username: usernameController.text,
                restaurantName: restaurantNameController.text,
              ).then((isSuccessful) {
                if (isSuccessful) {
                  // Registration successful
                  Navigator.of(context).pushReplacementNamed('/login');
                } else {
                  // Registration failed, show error message or shake the form
                  final errorMessage = authProvider.errorMessage ?? 'Registration failed. Please try again.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                  _shakeKey.currentState?.shake();
                }
              });
            }
          },
          child: PersonalizedButton(
            text: "SignUp",
            onPressed: null,
          ),
        ),
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don you already have an account?"),
          TextButton(
            onPressed: () {
              // Navigate to sign up screen
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text("Login"),
          ),
        ],
      ),

      const SizedBox(height: 20),

    ];
  }

}