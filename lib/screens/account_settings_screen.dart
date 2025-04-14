import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/account_settings_field.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth/animated_button.dart';
import '../widgets/personalized_button.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AccountSettingField(fieldName: "Name", initialValue: "Mario", onValueChanged: (newValue) {}),

            const SizedBox(height: 20),

            AccountSettingField(fieldName: "Surname", initialValue: "Rossi", onValueChanged: (newValue) {}),

            const SizedBox(height: 20),


            AccountSettingField(fieldName: "Username", initialValue: "Frost40", onValueChanged: (newValue) {}),

            const SizedBox(height: 20),

            AccountSettingField(fieldName: "Phone Number", initialValue: "6786786766876", onValueChanged: (newValue) {}),

            const SizedBox(height: 20),

            AccountSettingField(fieldName: "Email", initialValue: "sdfghjklertyu@dfghjk.com", onValueChanged: (newValue) {}),

            const SizedBox(height: 20),

            AccountSettingField(fieldName: "Password", initialValue: "prova", isPassword: true, onValueChanged: (newValue) {}),

            const SizedBox(height: 40),

            AnimatedButton(
            onTap: () async {
              // Sign out the user through auth provider
              await authProvider.signOut();
              // Navigate to login screen after successful logout
              if (context.mounted) {
              Navigator.of(context, rootNavigator: true)
                  .pushReplacementNamed('/login');
              }
              },
                child: PersonalizedButton(
                    text: "Delete Account",
                    onPressed: null,
                    centralWidget:
                    authProvider.isLoading
                        ? LoadingAnimationWidget.staggeredDotsWave(
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 30,
                    )
                        : null,
                ),
              )
          ],
        )
        // Logout button with animation

      ),
    );
  }
}