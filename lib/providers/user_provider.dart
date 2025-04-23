import 'package:flutter/material.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/services/database/user_firestore.dart';
import 'package:sous_chef/services/database/authentication.dart'; // Add this import

/// Provider that manages user data operations using the UserFirestore service.
/// Implements ChangeNotifier to notify dependent widgets when user data changes.
class UserProvider with ChangeNotifier {
  // UserFirestore service instance used to interact with Firestore
  final UserFirestore _userFirestore = UserFirestore();
  // Authentication service instance
  final Authentication _authentication = Authentication();

  // Current user data
  User? _userData;

  // Flag indicating if a data operation is in progress
  bool _isLoading = false;

  // Error message from the last operation
  String? _errorMessage;

  // Flags to track specific field errors
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  bool _hasUsernameError = false;
  bool _hasPhoneError = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get userData => _userData;
  bool get hasEmailError => _hasEmailError;
  bool get hasPasswordError => _hasPasswordError;
  bool get hasUsernameError => _hasUsernameError;
  bool get hasPhoneError => _hasPhoneError;

  /// Initialize the provider by loading current user data
  Future<void> init() async {
    _userData = await _userFirestore.getFullUserData();
    notifyListeners();
  }

  /// Manually sets error flags for specific fields
  ///
  /// Used primarily for validation when form data is submitted
  void setFieldErrors({
    bool emptyEmail = false,
    bool invalidEmail = false,
    bool emptyPassword = false,
    bool weakPassword = false,
    bool emptyUsername = false,
    bool emptyPhone = false,
    bool invalidPhone = false,
  }) {
    _hasEmailError = emptyEmail || invalidEmail;
    _hasPasswordError = emptyPassword || weakPassword;
    _hasUsernameError = emptyUsername;
    _hasPhoneError = emptyPhone || invalidPhone;

    List<String> errors = [];
    List<String> emptyFields = [];

    if (emptyEmail) emptyFields.add('Email');
    if (emptyPassword) emptyFields.add('Password');
    if (emptyUsername) emptyFields.add('Username');
    if (emptyPhone) emptyFields.add('Phone');

    // Add error for empty fields, if any
    if (emptyFields.isNotEmpty) {
      errors.add('${emptyFields.join(', ')} cannot be empty');
    }

    // Add other errors not related to empty fields
    if (invalidEmail) errors.add('Invalid email format');
    if (weakPassword) errors.add('Password must have at least 6 characters');
    if (invalidPhone) errors.add('Invalid phone number format');

    _errorMessage = errors.isNotEmpty ? errors.join('\n') : null;

    notifyListeners();
  }

  /// Clears all error states and messages
  void clearErrors() {
    _errorMessage = null;
    _hasEmailError = false;
    _hasPasswordError = false;
    _hasUsernameError = false;
    _hasPhoneError = false;
    notifyListeners();
  }

  /// Updates user profile with the provided fields
  Future<void> updateUserProfile({
    String? username,
    String? name,
    String? surname,
    String? phone,
  }) async {
    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      await _userFirestore.updateUserProfile(
        username: username,
        name: name,
        surname: surname,
        phone: phone,
      );

      // Update in-memory data
      _userData = await _userFirestore.getFullUserData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
    }
  }

  /// Updates the user's email
  Future<void> updateUserEmail(String newEmail) async {
    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      await _userFirestore.updateUserEmail(newEmail);
      
      // Instead of fetching all user data, just update the email field
      // This assumes the email verification happens immediately (synchronously)
      // which it doesn't - see the notification system below
      
      // Set up a listener to wait for the email update to complete
      _setupEmailUpdateListener(newEmail);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _hasEmailError = true;
      notifyListeners();
    }
  }
  
  /// Sets up a listener to detect when the email update completes
  void _setupEmailUpdateListener(String newEmail) {
    // Create a subscription that we can cancel later
    late final subscription;
    subscription = 
        Stream.periodic(const Duration(seconds: 2), (_) => _authentication.getCurrentUserEmail())
        .listen((currentEmail) {
          if (currentEmail == newEmail) {
            // Email has been updated successfully
            if (_userData != null) {
              _userData = _userData!.copyWith(email: newEmail);
              notifyListeners();
            }
            subscription.cancel(); // Stop listening once we detect the change
          }
        });
    
    // Cancel the subscription after a reasonable timeout (e.g., 2 minutes)
    Future.delayed(const Duration(minutes: 2), () {
      subscription.cancel();
    });
  }

  /// Updates the user's password
  Future<void> updateUserPassword(String newPassword) async {
    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      await _userFirestore.updateUserPassword(newPassword);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _hasPasswordError = true;
      notifyListeners();
    }
  }

  /// Fetches the user's account data
  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userData = await _userFirestore.getFullUserData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<bool> isUsernameTaken(String username, {bool notify = false}) async {
    _isLoading = true;
    if (notify) notifyListeners();

    try {
      final isTaken = await _userFirestore.isUsernameTaken(username);
      _isLoading = false;

      if (isTaken) {
        _hasUsernameError = true;
        _errorMessage = 'Username already taken';
      }

      if (notify) notifyListeners();
      return isTaken;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      if (notify) notifyListeners();
      return false;
    }
  }

  /// Sets the appropriate field error flags based on the error type
  void _setErrorFieldsByErrorType(dynamic error) {
    final errorMsg = error.toString().toLowerCase();

    if (errorMsg.contains('email')) {
      _hasEmailError = true;
    } else if (errorMsg.contains('password')) {
      _hasPasswordError = true;
    } else if (errorMsg.contains('username')) {
      _hasUsernameError = true;
    } else if (errorMsg.contains('phone')) {
      _hasPhoneError = true;
    }
  }

  /// Converts errors into user-friendly messages
  String _getErrorMessage(dynamic error) {
    String errorMessage = error.toString();

    if (errorMessage.contains('email-already-in-use')) {
      return 'Email already in use';
    } else if (errorMessage.contains('invalid-email')) {
      return 'Invalid email format';
    } else if (errorMessage.contains('weak-password')) {
      return 'Password is too weak';
    } else if (errorMessage.contains('requires-recent-login')) {
      return 'This operation requires a recent login. Please sign out and sign in again.';
    } else if (errorMessage.contains('No authenticated user')) {
      return 'No authenticated user';
    } else if (errorMessage.contains('User not found')) {
      return 'User not found';
    }

    return 'An error occurred: $errorMessage';
  }
}