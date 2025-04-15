import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:sous_chef/services/database/authentication.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/services/database/firestore_services.dart';

/// Provider that manages user authentication using the Authentication service.
/// Implements ChangeNotifier to notify dependent widgets when authentication state changes.
class AuthProvider with ChangeNotifier {
  // Authentication service instance used to interact with Firebase
  final Authentication _auth = Authentication();

  final FirestoreServices _firestore = FirestoreServices();

  // Current authenticated user
  User? _user;

  // Flag indicating if an authentication operation is in progress
  bool _isLoading = false;

  // Error message from the last authentication operation
  String? _errorMessage;

  // Flags to track specific field errors
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  bool _hasUsernameError = false;
  bool _hasRestaurantnameError = false;
  bool _hasConfirmPasswordError = false;

  // Returns whether an authentication operation is currently in progress
  bool get isLoading => _isLoading;

  // Returns the latest error message, or null if no errors
  String? get errorMessage => _errorMessage;

  // Indicates if there's an email-related error
  bool get hasEmailError => _hasEmailError;

  // Indicates if there's a password-related error
  bool get hasPasswordError => _hasPasswordError;

  // Indicates if there's a password-related error
  bool get hasConfirmPasswordError => _hasConfirmPasswordError;

  // Indicates if there's an username-related error
  bool get hasUsernameError => _hasUsernameError;

  // Indicates if there's a restaurant name-related error
  bool get hasRestaurantnameError => _hasRestaurantnameError;

  // Returns the current authenticated user
  User? get user => _user;

  // Checks if the user is currently authenticated
  bool get isAuthenticated => _user != null;

  // Initialize provider by loading current user (call in app initialization)
  Future<void> init() async {
    _user = await _auth.getCurrentUser();
    notifyListeners();
  }

  /// Manually sets error flags for specific fields
  ///
  /// Used primarily for validation when the form is submitted
  void setFieldErrors({
    bool emptyEmail = false,
    bool emptyPassword = false,
    bool invalidEmail = false,
    bool invalidPassword = false,
    bool invalidConfirmPassword = false,
    bool emptyConfirmPassword = false,
    bool emptyUsername = false,
    bool emptyRestaurantname = false,
  }) {
    _hasEmailError = emptyEmail || invalidEmail;
    _hasPasswordError = emptyPassword || invalidPassword;
    _hasConfirmPasswordError = emptyConfirmPassword || invalidConfirmPassword;
    _hasRestaurantnameError = emptyRestaurantname;
    _hasUsernameError = emptyUsername;

    if (emptyEmail &&
        emptyPassword &&
        (emptyConfirmPassword || emptyRestaurantname || emptyUsername)) {
      _errorMessage = 'Fields cannot be empty';
    } else if (emptyEmail && emptyPassword) {
      _errorMessage = 'Email and password cannot be empty';
    } else if (emptyEmail) {
      _errorMessage = 'Email cannot be empty';
    } else if (emptyPassword) {
      _errorMessage = 'Password cannot be empty';
    } else if (invalidEmail) {
      _errorMessage = 'Invalid email format';
    } else if (invalidPassword) {
      _errorMessage = 'password must have at least 6 characters';
    } else if (invalidConfirmPassword) {
      _errorMessage = 'Confirm Password is different from the password chosen';
    } else if (emptyConfirmPassword) {
      _errorMessage = 'Confirm Password cannot be empty';
    } else if (emptyUsername) {
      _errorMessage = 'Username cannot be empty';
    } else if (emptyRestaurantname) {
      _errorMessage = 'Restaurant name cannot be empty';
    }

    notifyListeners();
  }

  /// Clears all error states and messages
  void clearErrors() {
    _errorMessage = null;
    _hasEmailError = false;
    _hasPasswordError = false;
    _hasConfirmPasswordError = false;
    _hasRestaurantnameError = false;
    _hasUsernameError = false;
    notifyListeners();
  }

  /// Attempts to sign in a user with the provided email and password.
  /// Updates loading state and error messages accordingly.
  Future<void> signIn(String email, String password) async {
    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _auth.signIn(email, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
    }
  }

  /// Registers a new user with the provided information.
  /// Updates loading state and error messages accordingly.
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? restaurantName,
  }) async {
    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      final usernameTaken = await _firestore.isUsernameTaken(username);
      final restaurantTaken =
          restaurantName != null
              ? await _firestore.isRestaurantNameTaken(restaurantName)
              : false;

      if (usernameTaken || restaurantTaken) {
        if (usernameTaken) {
          _hasUsernameError = true;
          _errorMessage = 'Username is already taken';
        }
        if (restaurantTaken) {
          _hasRestaurantnameError = true;
          _errorMessage =
              restaurantTaken && usernameTaken
                  ? 'Username and restaurant name already taken'
                  : 'Restaurant name is already taken';
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      _user = await _auth.signUp(
        email: email,
        password: password,
        username: username,
        restaurantName: restaurantName,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
    }
  }

  // Signs out the current user and notifies listeners
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    clearErrors();

    try {
      _user = await _auth.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    clearErrors();

    try {
      await _auth.resetPassword(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
    }
  }

  /// Sets the appropriate field error flags based on the error type
  void _setErrorFieldsByErrorType(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
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
    if (error is firebase_auth.FirebaseAuthException) {
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
        case 'invalid-credential':
          return 'Invalid credentials';
        default:
          return 'Error: ${error.message}';
      }
    }
    return 'An error occurred';
  }
}
