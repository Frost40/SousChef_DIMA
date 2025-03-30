import 'package:flutter/material.dart';
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

  /*onPasswordChanged(String password) {
    setState(() {
      _isPasswordSixCharacters = false;
      if (password.length >= 6) _isPasswordSixCharacters = true;
    });
  }

  onEmailChange(String email) {
    final emailRegex = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');

    setState(() {
      _isEmailWellFormatted = false;
      if (emailRegex.hasMatch(email)) _isEmailWellFormatted = true;
    });
  }*/

  bool _isChef = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 20),

            PersonalizedTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false
            ),

            const SizedBox(height: 20),

            PasswordFieldSignup(
                textEditingController: passwordController,
                hintText: "Password",
            ),

            const SizedBox(height: 20),

            PersonalizedTextField(
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                obscureText: true
            ),

            const SizedBox(height: 20),

            PersonalizedTextField(
                controller: usernameController,
                hintText: "Username",
                obscureText: false
            ),

            const SizedBox(height: 20),

            Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text(
                        'Registering as a chef',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16, // Puoi regolare questo valore
                            fontWeight: FontWeight.w400 // Opzionale, per renderlo leggermente più grassetto
                        ))
                  ),
                  const Expanded(child: SizedBox()), // Spinge lo switch a destra
                  Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: CustomSwitch(
                        initialValue: _isChef,
                        onChanged: (bool value) {
                          setState(() {
                            _isChef = value;
                          });
                        },
                      )
                  )
                ]
            ),

            const SizedBox(height: 20),

            // Conditional TextField for restaurant name
            if (_isChef)
              PersonalizedTextField(
                  controller: restaurantNameController,
                  hintText: "Restaurant Name",
                  obscureText: false
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
                    // Proceed with signup logic
                    // Add signup implementation here
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
                child: PersonalizedButton(
                  text: "SignUp",
                  onPressed: null, // We're handling the tap in AnimatedButton
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Text(
                    'Registering as a chef',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16, // Puoi regolare questo valore
                        fontWeight: FontWeight.w400 // Opzionale, per renderlo leggermente più grassetto
                    ))
            )
          ]
      ),
    );
  }
}