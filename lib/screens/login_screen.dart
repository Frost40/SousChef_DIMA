import 'package:flutter/material.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/widgets/personalized_textfield.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

          const SizedBox(height: 20), // Add space after logo

          // email field
          PersonalizedTextField(controller: emailController, hintText: "Email", obscureText: false),

          const SizedBox(height: 20), // Add space after logo

          // password field
          PersonalizedTextField(controller: passwordController, hintText: "Password", obscureText: true),

          const SizedBox(height: 20), // Add space after logo

          // login button
          PersonalizedButton(text: "Login", onPressed: (){})
        ]

      ),
    );
  }
}