import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/account_settings_field.dart';
import 'package:sous_chef/widgets/custom_alert_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/personalized_button.dart';
import '../services/orientation_manager.dart';

enum LayoutType { mobile, tabletVertical, tabletHorizontal }

class AccountSettingsScreen extends StatefulWidget {
  final bool isEmbedded;

  const AccountSettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? _name;
  String? _surname;
  String? _username;
  String? _phoneNumber;
  String? _email;
  String? _pageError;

  // Track modifications for each field separately
  bool _nameModified = false;
  bool _surnameModified = false;
  bool _usernameModified = false;
  bool _phoneNumberModified = false;
  bool _emailModified = false;

  bool _hasUsernameError = false;
  bool _hasPhoneNumberError = false;
  bool _hasEmailError = false;

  // Helper to check if any field is modified
  bool get _isAnyFieldModified =>
      _nameModified ||
      _surnameModified ||
      _usernameModified ||
      _phoneNumberModified ||
      _emailModified;

  LayoutType _getLayoutType(BuildContext context) {
    final orientationManager = OrientationManager();
    final isTablet = orientationManager.isTablet(context);
    if (!isTablet) return LayoutType.mobile;

    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? LayoutType.tabletVertical
        : LayoutType.tabletHorizontal;
  }

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

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.clearErrors(notify: false);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearErrors();
  }

  // Add this new method to clear page error without triggering a full page rebuild
  void _clearPageError() {
    if (_pageError != null) {
      setState(() {
        _pageError = null;
      });
    }
  }

  void _navigateToLogin() {
    // Cleaning errors
    _clearErrors();

    // Navigate to login screen
    Navigator.of(context, rootNavigator: true).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    var colorTheme = Theme.of(context).colorScheme;
    final layoutType = _getLayoutType(context);

    return Scaffold(
      appBar:
          widget.isEmbedded
              ? null
              : AppBar(
                title: const Text('Account Settings'),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  if (_isAnyFieldModified &&
                      !_hasUsernameError &&
                      !_hasPhoneNumberError &&
                      !_hasEmailError)
                    IconButton(
                      icon: const Icon(Icons.save),
                      color: colorTheme.primary,
                      onPressed: userProvider.isLoading ? null : _saveChanges,
                    ),
                ],
              ),
      body:
          userProvider.isLoading || userData == null
              ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              )
              : SafeArea(
                child:
                    layoutType == LayoutType.tabletHorizontal
                        ? Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 900,
                            child: ListView(
                              children: [
                                AccountSettingField(
                                  fieldName: "Name",
                                  initialValue: userData.name ?? "",
                                  onValueChanged: (newValue, isModified) {
                                    setState(() {
                                      _name = newValue;
                                      _nameModified = isModified;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),

                                AccountSettingField(
                                  fieldName: "Surname",
                                  initialValue: userData.surname ?? "",
                                  onValueChanged: (newValue, isModified) {
                                    setState(() {
                                      _pageError = null;
                                      _surname = newValue;
                                      _surnameModified = isModified;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),

                                AccountSettingField(
                                  fieldName: "Username",
                                  initialValue: userData.username ?? "",
                                  asyncValidator: _validateUsername,
                                  onValueChanged: (newValue, isModified) {
                                    setState(() {
                                      _username = newValue;
                                      _usernameModified = isModified;
                                    });
                                  },
                                  onTextChanged: _clearPageError,
                                  onValidationError: (error) {
                                    if (error != null) {
                                      setState(() {
                                        _pageError = error;
                                        _hasUsernameError = true;
                                      });
                                    } else {
                                      setState(() {
                                        _hasUsernameError = false;
                                      });
                                      _clearPageError();
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),

                                AccountSettingField(
                                  fieldName: "Phone Number",
                                  initialValue: userData.phone ?? "",
                                  asyncValidator: _validatePhoneNumber,
                                  onValueChanged: (newValue, isModified) {
                                    setState(() {
                                      _phoneNumber = newValue;
                                      _phoneNumberModified = isModified;
                                    });
                                  },
                                  onTextChanged: _clearPageError,
                                  onValidationError: (error) {
                                    if (error != null) {
                                      setState(() {
                                        _pageError = error;
                                        _hasPhoneNumberError = true;
                                      });
                                    } else {
                                      _hasPhoneNumberError = false;
                                      _clearPageError();
                                    }
                                  },
                                ),
                                const SizedBox(height: 40),

                                // Email section with info tooltip
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0,
                                      ),
                                      child: Text(
                                        "Email Settings",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colorTheme.onSurface,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0,
                                      ),
                                      child: Divider(
                                        color: colorTheme.onSurface,
                                        thickness: 0.5,
                                      ),
                                    ),

                                    const SizedBox(height: 10),
                                    AccountSettingField(
                                      fieldName: "Email",
                                      initialValue: userData.email,
                                      asyncValidator: _validateEmail,
                                      onValueChanged: (newValue, isModified) {
                                        setState(() {
                                          _email = newValue;
                                          _emailModified = isModified;
                                        });
                                      },
                                      onTextChanged: _clearPageError,
                                      onValidationError: (error) {
                                        if (error != null) {
                                          setState(() {
                                            _pageError = error;
                                            _hasEmailError = true;
                                          });
                                        } else {
                                          _hasEmailError = false;
                                          _clearPageError();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: colorTheme.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              "Changing your email will require you to log in again to apply the changes.",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    colorTheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                if (_pageError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Center(
                                      child: Text(
                                        _pageError!,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 40),

                                AnimatedButton(
                                  onTap: () async {
                                    // Show confirmation dialog
                                    final bool confirmDelete =
                                        await CustomAlertDialog.showConfirmationDialog(
                                          context: context,
                                          title: "Delete Account",
                                          message:
                                              "Are you sure you want to delete your account? This action cannot be undone.",
                                          confirmText: "Delete",
                                          cancelText: "Cancel",
                                          icon: Icon(
                                            Icons.warning_amber_rounded,
                                            color: colorTheme.primary,
                                          ),
                                        );

                                    if (confirmDelete && context.mounted) {
                                      try {
                                        final userProvider =
                                            Provider.of<UserProvider>(
                                              context,
                                              listen: false,
                                            );
                                        final authProvider =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            );

                                        debugPrint(
                                          "Starting account deletion process...",
                                        );

                                        if (!await authProvider
                                            .hasRecentLogin()) {
                                          debugPrint("Not recently logged in");
                                          throw ("For security reasons, please log in again to delete your account.");
                                        }

                                        // Step 1: Delete all user data from Firestore
                                        debugPrint(
                                          "Step 1: Deleting user data from Firestore...",
                                        );
                                        await userProvider.deleteUserData();
                                        if (userProvider.errorMessage != null) {
                                          debugPrint(
                                            "Error in Step 1: ${userProvider.errorMessage}",
                                          );
                                          throw Exception(
                                            userProvider.errorMessage,
                                          );
                                        }
                                        debugPrint(
                                          "Step 1 completed successfully",
                                        );

                                        // Step 2: Delete user account from Firebase Auth
                                        debugPrint(
                                          "Step 2: Deleting user account from Firebase Auth...",
                                        );
                                        await authProvider.deleteUserAccount();
                                        if (authProvider.errorMessage != null) {
                                          debugPrint(
                                            "Error in Step 2: ${authProvider.errorMessage}",
                                          );
                                          throw Exception(
                                            authProvider.errorMessage,
                                          );
                                        }
                                        debugPrint(
                                          "Step 2 completed successfully",
                                        );

                                        // Step 3: Sign out the user and clear chat data
                                        debugPrint(
                                          "Step 3: Signing out user...",
                                        );
                                        final chatProvider =
                                            Provider.of<ChatProvider>(
                                              context,
                                              listen: false,
                                            );
                                        await authProvider.signOut(
                                          onSignOut: () {
                                            chatProvider.clearAllChats();
                                            userProvider.clearUserData();
                                          },
                                        );
                                        debugPrint(
                                          "Account deletion completed successfully",
                                        );

                                        // Step 4: Navigate to login screen
                                        _navigateToLogin();
                                      } catch (e) {
                                        debugPrint(
                                          "Account deletion failed with error: $e",
                                        );
                                        // Show specific error message
                                        if (context.mounted) {
                                          CustomAlertDialog.showInfoDialog(
                                            context: context,
                                            title: "Account Deletion Failed",
                                            message: e.toString(),
                                            icon: Icon(
                                              Icons.error_outline,
                                              color: colorTheme.error,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: PersonalizedButton(
                                    text: "Delete Account",
                                    onPressed: null,
                                    centralWidget:
                                        authProvider.isLoading ||
                                                userProvider.isLoading
                                            ? LoadingAnimationWidget.staggeredDotsWave(
                                              color: colorTheme.onPrimary,
                                              size: 30,
                                            )
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : ListView(
                          children: [
                            AccountSettingField(
                              fieldName: "Name",
                              initialValue: userData.name ?? "",
                              onValueChanged: (newValue, isModified) {
                                setState(() {
                                  _name = newValue;
                                  _nameModified = isModified;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            AccountSettingField(
                              fieldName: "Surname",
                              initialValue: userData.surname ?? "",
                              onValueChanged: (newValue, isModified) {
                                setState(() {
                                  _pageError = null;
                                  _surname = newValue;
                                  _surnameModified = isModified;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            AccountSettingField(
                              fieldName: "Username",
                              initialValue: userData.username ?? "",
                              asyncValidator: _validateUsername,
                              onValueChanged: (newValue, isModified) {
                                setState(() {
                                  _username = newValue;
                                  _usernameModified = isModified;
                                });
                              },
                              onTextChanged: _clearPageError,
                              onValidationError: (error) {
                                if (error != null) {
                                  setState(() {
                                    _pageError = error;
                                    _hasUsernameError = true;
                                  });
                                } else {
                                  setState(() {
                                    _hasUsernameError = false;
                                  });
                                  _clearPageError();
                                }
                              },
                            ),
                            const SizedBox(height: 20),

                            AccountSettingField(
                              fieldName: "Phone Number",
                              initialValue: userData.phone ?? "",
                              asyncValidator: _validatePhoneNumber,
                              onValueChanged: (newValue, isModified) {
                                setState(() {
                                  _phoneNumber = newValue;
                                  _phoneNumberModified = isModified;
                                });
                              },
                              onTextChanged: _clearPageError,
                              onValidationError: (error) {
                                if (error != null) {
                                  setState(() {
                                    _pageError = error;
                                    _hasPhoneNumberError = true;
                                  });
                                } else {
                                  _hasPhoneNumberError = false;
                                  _clearPageError();
                                }
                              },
                            ),
                            const SizedBox(height: 40),

                            // Email section with info tooltip
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0,
                                  ),
                                  child: Text(
                                    "Email Settings",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorTheme.onSurface,
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0,
                                  ),
                                  child: Divider(
                                    color: colorTheme.onSurface,
                                    thickness: 0.5,
                                  ),
                                ),

                                const SizedBox(height: 10),
                                AccountSettingField(
                                  fieldName: "Email",
                                  initialValue: userData.email,
                                  asyncValidator: _validateEmail,
                                  onValueChanged: (newValue, isModified) {
                                    setState(() {
                                      _email = newValue;
                                      _emailModified = isModified;
                                    });
                                  },
                                  onTextChanged: _clearPageError,
                                  onValidationError: (error) {
                                    if (error != null) {
                                      setState(() {
                                        _pageError = error;
                                        _hasEmailError = true;
                                      });
                                    } else {
                                      _hasEmailError = false;
                                      _clearPageError();
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: colorTheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Changing your email will require you to log in again to apply the changes.",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorTheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            if (_pageError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Center(
                                  child: Text(
                                    _pageError!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 40),

                            AnimatedButton(
                              onTap: () async {
                                // Show confirmation dialog
                                final bool confirmDelete =
                                    await CustomAlertDialog.showConfirmationDialog(
                                      context: context,
                                      title: "Delete Account",
                                      message:
                                          "Are you sure you want to delete your account? This action cannot be undone.",
                                      confirmText: "Delete",
                                      cancelText: "Cancel",
                                      icon: Icon(
                                        Icons.warning_amber_rounded,
                                        color: colorTheme.primary,
                                      ),
                                    );

                                if (confirmDelete && context.mounted) {
                                  try {
                                    final userProvider =
                                        Provider.of<UserProvider>(
                                          context,
                                          listen: false,
                                        );
                                    final authProvider =
                                        Provider.of<AuthProvider>(
                                          context,
                                          listen: false,
                                        );

                                    debugPrint(
                                      "Starting account deletion process...",
                                    );

                                    if (!await authProvider.hasRecentLogin()) {
                                      debugPrint("Not recently logged in");
                                      throw ("For security reasons, please log in again to delete your account.");
                                    }

                                    // Step 1: Delete all user data from Firestore
                                    debugPrint(
                                      "Step 1: Deleting user data from Firestore...",
                                    );
                                    await userProvider.deleteUserData();
                                    if (userProvider.errorMessage != null) {
                                      debugPrint(
                                        "Error in Step 1: ${userProvider.errorMessage}",
                                      );
                                      throw Exception(
                                        userProvider.errorMessage,
                                      );
                                    }
                                    debugPrint("Step 1 completed successfully");

                                    // Step 2: Delete user account from Firebase Auth
                                    debugPrint(
                                      "Step 2: Deleting user account from Firebase Auth...",
                                    );
                                    await authProvider.deleteUserAccount();
                                    if (authProvider.errorMessage != null) {
                                      debugPrint(
                                        "Error in Step 2: ${authProvider.errorMessage}",
                                      );
                                      throw Exception(
                                        authProvider.errorMessage,
                                      );
                                    }
                                    debugPrint("Step 2 completed successfully");

                                    // Step 3: Sign out the user and clear chat data
                                    debugPrint("Step 3: Signing out user...");
                                    final chatProvider =
                                        Provider.of<ChatProvider>(
                                          context,
                                          listen: false,
                                        );
                                    await authProvider.signOut(
                                      onSignOut: () {
                                        chatProvider.clearAllChats();
                                        userProvider.clearUserData();
                                      },
                                    );
                                    debugPrint(
                                      "Account deletion completed successfully",
                                    );

                                    // Step 4: Navigate to login screen
                                    _navigateToLogin();
                                  } catch (e) {
                                    debugPrint(
                                      "Account deletion failed with error: $e",
                                    );
                                    // Show specific error message
                                    if (context.mounted) {
                                      CustomAlertDialog.showInfoDialog(
                                        context: context,
                                        title: "Account Deletion Failed",
                                        message: e.toString(),
                                        icon: Icon(
                                          Icons.error_outline,
                                          color: colorTheme.error,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: PersonalizedButton(
                                text: "Delete Account",
                                onPressed: null,
                                centralWidget:
                                    authProvider.isLoading ||
                                            userProvider.isLoading
                                        ? LoadingAnimationWidget.staggeredDotsWave(
                                          color: colorTheme.onPrimary,
                                          size: 30,
                                        )
                                        : null,
                              ),
                            ),
                          ],
                        ),
              ),
    );
  }

  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Update profile fields
    if (_name != null ||
        _surname != null ||
        _username != null ||
        _phoneNumber != null) {
      await userProvider.updateUserProfile(
        username: _username,
        name: _name,
        surname: _surname,
        phone: _phoneNumber,
      );
    }

    if (_email != null) {
      await userProvider.updateUserEmail(_email!);
      // Check if there was an email-specific error
      if (userProvider.hasEmailError && userProvider.errorMessage != null) {
        setState(() {
          _pageError = userProvider.errorMessage;
        });
        return; // Return early to prevent the success message
      }
    }

    if (userProvider.errorMessage == null) {
      setState(() {
        _nameModified = false;
        _surnameModified = false;
        _usernameModified = false;
        _phoneNumberModified = false;
        _emailModified = false;
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

    // Verify uniqueness
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

  Future<String?> _validateEmail(String value) async {
    // Email is required
    if (value.isEmpty) {
      return "Email address is required";
    }

    // Check for valid email format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email address";
    }

    // Check if the email is already in use
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isInUse = await authProvider.isEmailInUse(value);

    if (isInUse) {
      // Simply return error message - onValidationError will handle updating _pageError
      return "This email is already registered with another account";
    }

    return null;
  }
}
