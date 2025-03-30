import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sous_chef/services/authentication.dart';

/// Provider that manages user authentication using the Authentication service.
/// Implements ChangeNotifier to notify dependent widgets when authentication state changes.
class AuthProvider with ChangeNotifier {
  // Authentication service instance used to interact with Firebase
  final Authentication _auth = Authentication();

  // Flag indicating if an authentication operation is in progress
  bool _isLoading = false;

  // Error message from the last authentication operation
  String? _errorMessage;

  // Flags to track specific field errors
  bool _hasEmailError = false;
  bool _hasPasswordError = false;

  // Returns whether an authentication operation is currently in progress
  bool get isLoading => _isLoading;

  // Returns the latest error message, or null if no errors
  String? get errorMessage => _errorMessage;

  // Indicates if there's an email-related error
  bool get hasEmailError => _hasEmailError;

  // Indicates if there's a password-related error
  bool get hasPasswordError => _hasPasswordError;

  // Checks if the user is currently authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Manually sets error flags for specific fields
  ///
  /// Used primarily for validation when the form is submitted
  void setFieldErrors({
    bool emptyEmail = false,
    bool emptyPassword = false,
    bool invalidEmail = false,
    bool invalidPassword = false,
  }) {
    _hasEmailError = emptyEmail || invalidEmail;
    _hasPasswordError = emptyPassword || invalidPassword;

    if (emptyEmail && emptyPassword) {
      _errorMessage = 'Email and password cannot be empty';
    } else if (emptyEmail) {
      _errorMessage = 'Email cannot be empty';
    } else if (emptyPassword) {
      _errorMessage = 'Password cannot be empty';
    } else if (invalidEmail) {
      _errorMessage = 'Invalid email format';
    } else if (invalidPassword) {
      _errorMessage = 'Invalid password format';
    }

    notifyListeners();
  }

  /// Clears all error states and messages
  void clearErrors() {
    _errorMessage = null;
    _hasEmailError = false;
    _hasPasswordError = false;
    notifyListeners();
  }

  /// Attempts to sign in a user with the provided email and password.
  /// Updates loading state and error messages accordingly.
  ///
  /// @return true if login succeeds, false otherwise
  Future<bool> signIn(String email, String password) async {
    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
      return false;
    }
  }

  /// Registers a new user with the provided information.
  /// Updates loading state and error messages accordingly.
  ///
  /// @return true if registration succeeds, false otherwise
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
    required String surname,
    String? restaurantName,
    
  }) async {
    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signUp(
        email: email,
        password: password,
        username: username,
        name: name,
        surname: surname,
        restaurantName: restaurantName
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
      return false;
    }
  }

  // Signs out the current user and notifies listeners
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  /// Sets the appropriate field error flags based on the error type
  void _setErrorFieldsByErrorType(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'invalid-email':
          _hasEmailError = true;
          break;
        case 'wrong-password':
        case 'weak-password':
          _hasPasswordError = true;
          break;
        case 'email-already-in-use':
          _hasEmailError = true;
          break;
        default:
          // For unknown errors, don't highlight specific fields
          break;
      }
    }
  }

  /// Converts Firebase authentication errors into user-friendly messages.
  ///
  /// @param error The error thrown by Firebase
  /// @return A readable error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'User not found';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'Email already in use';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Invalid email format';
        default:
          return 'Error: ${error.message}';
      }
    }
    return 'An error occurred';
  }
}