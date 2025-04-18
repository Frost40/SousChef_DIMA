import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/account_settings_field.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/auth/animated_button.dart';
import '../widgets/personalized_button.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? _name;
  String? _surname;
  String? _username;
  String? _phoneNumber;
  String? _email;
  String? _password;
  String? _pageError;
  bool _modified = false;

  @override
  void initState() {
    super.initState();
    // Load user data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    });
  }

  void _clearErrors() {
    setState(() {
      _pageError = null;
    });
    //
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.clearErrors();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    var colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (_modified)
            IconButton(
              icon: const Icon(Icons.save),
              color: colorTheme.primary,
              onPressed: userProvider.isLoading ? null : _saveChanges,
            ),
        ],
      ),
      body: userProvider.isLoading || userData == null
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
            )
          : SafeArea(
              child: ListView(
                children: [


                  AccountSettingField(
                    fieldName: "Name",
                    initialValue: userData.name ?? "",
                    onValueChanged: (newValue, isModified) {
                      _clearErrors();
                      setState(() {
                        _name = newValue;
                        _modified = isModified;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  AccountSettingField(
                    fieldName: "Surname",
                    initialValue: userData.surname ?? "",
                    onValueChanged: (newValue, isModified) {
                      _clearErrors();
                      setState(() {
                        _surname = newValue;
                        _modified = isModified;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  AccountSettingField(
                    fieldName: "Username",
                    initialValue: userData.username ?? "",
                    asyncValidator: _validateUsername,
                    onValueChanged: (newValue, isModified) {
                      _clearErrors();
                      setState(() {
                        _username = newValue;
                        _modified = isModified;
                      });
                    },
                    onValidationError: (error) {
                      if (error != null) {
                        setState(() {
                          _pageError = error;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  AccountSettingField(
                    fieldName: "Phone Number",
                    initialValue: userData.phone ?? "",
                    asyncValidator: _validatePhoneNumber,
                    onValueChanged: (newValue, isModified) {
                      _clearErrors();
                      setState(() {
                        _phoneNumber = newValue;
                        _modified = isModified;
                      });
                    },
                    onValidationError: (error) {
                      if (error != null) {
                        setState(() {
                          _pageError = error;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  AccountSettingField(
                    fieldName: "Email",
                    initialValue: userData.email,
                    onValueChanged: (newValue, isModified) {
                      setState(() {
                        _email = newValue;
                        _modified = isModified;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  AccountSettingField(
                    fieldName: "Password",
                    initialValue: "••••••••",
                    isPassword: true,
                    onValueChanged: (newValue, isModified) {
                      setState(() {
                        _password = newValue;
                        _modified = isModified;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  if (_pageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: Text(
                          _pageError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
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
            ),
    );
  }

  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Update profile fields
    if (_name != null || _surname != null || _username != null || _phoneNumber != null) {
      await userProvider.updateUserProfile(
        username: _username,
        name: _name,
        surname: _surname,
        phone: _phoneNumber,
      );
    }

    if (userProvider.errorMessage == null) {
      setState(() {
        _modified = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    }
  }

  Future<String?> _validateUsername(String value) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // If the username is the same as the current one, no need to validate
    if (value == userProvider.userData?.username) {
      return null;
    }

    // Control for emptiness
    if (value.isEmpty) {
      return "The username cannot be empty";
    }

    // Check for character types
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return "The username can only contain letters, numbers, and underscores";
    }

    // Verify uniqueness - senza notificare i listener
    final isTaken = await userProvider.isUsernameTaken(value, notify: false);
    if (isTaken) {
      return userProvider.errorMessage ?? "Username taken";
    }

    return null;
  }

  Future<String?> _validatePhoneNumber(String value) async {
    // Phone number is optional
    if (value.isEmpty) return null;

    // Verify format (Italian number)
    if (!RegExp(r'^(\+39)?\s?\d{10}$').hasMatch(value)) {
      return "Please enter a valid phone number (Italian format)";
    }

    return null;
  }

}