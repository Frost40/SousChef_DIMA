import 'package:flutter/material.dart';
import 'package:sous_chef/widgets/cupertino_switch.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/widgets/personalized_textfield.dart';

class SignUpScreen extends StatelessWidget {
  static const String routeName = '/signup';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  SignUpScreen({super.key});

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

            const SizedBox(height: 20), // Add space after field

            // email field
            PersonalizedTextField(controller: emailController, hintText: "Email", obscureText: false),

            const SizedBox(height: 20), // Add space after field

            // password field
            PersonalizedTextField(controller: passwordController, hintText: "Password", obscureText: true),

            const SizedBox(height: 20), // Add space after field

            //confirm password field
            PersonalizedTextField(controller: confirmPasswordController, hintText: "Confirm Password", obscureText: true),

            const SizedBox(height: 20), // Add space after field

            // Name field
            PersonalizedTextField(controller: nameController, hintText: "Name", obscureText: false),

            const SizedBox(height: 20), // Add space after field

            // Surname field
            PersonalizedTextField(controller: surnameController, hintText: "Surname", obscureText: true),

            const SizedBox(height: 20), // Add space after field

            // Username field
            PersonalizedTextField(controller: usernameController, hintText: "Username", obscureText: false),

            const SizedBox(height: 20), // Add space after field

            //Switch
            CustomSwitch(),

            // login button
            PersonalizedButton(text: "Sign Up", onPressed: (){})
          ]

      ),
    );
  }
}