import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:sous_chef/services/authentication.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/services/database/user_firestore.dart';

import '../services/database/restaurant_firestore.dart';

/// Provider that manages user authentication using the Authentication service.
/// Implements ChangeNotifier to notify dependent widgets when authentication state changes.
class AuthProvider with ChangeNotifier {
  // Authentication service instance used to interact with Firebase
  final Authentication _auth = Authentication();

  final UserFirestore _firestore = UserFirestore();

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

  StreamSubscription<firebase_auth.User?>? _authSubscription;

  // Modifica il costruttore per inizializzare automaticamente
  AuthProvider() {
    _initializeCurrentUser();

    // Sottoscrizione ai cambiamenti di autenticazione
    _authSubscription = _auth.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _initializeCurrentUser() async {
    _user = await _auth.getCurrentUser();
    notifyListeners();
  }

  void _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser != null) {
      _user = await _auth.getCurrentUser();
    } else {
      _user = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    //_authSubscription?.cancel();
    super.dispose();
  }

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

    List<String> errors = [];
    List<String> emptyFields = [];

    if (emptyEmail) emptyFields.add('Email');
    if (emptyPassword) emptyFields.add('Password');
    if (emptyConfirmPassword) emptyFields.add('Confirm Password');
    if (emptyUsername) emptyFields.add('Username');
    if (emptyRestaurantname) emptyFields.add('Restaurant name');

    // Aggiungi errore per campi vuoti, se ce ne sono
    if (emptyFields.isNotEmpty) {
      errors.add('${emptyFields.join(', ')} cannot be empty');
    }

    // Aggiungi altri errori non legati al fatto che siano vuoti
    if (invalidEmail) errors.add('Invalid email format');
    if (invalidPassword) errors.add('Password must have at least 7 characters');
    if (invalidConfirmPassword) {
      errors.add('Confirm Password is different from the password chosen');
    }

    _errorMessage = errors.isNotEmpty ? errors.join('\n') : null;

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
  /// Creates user and restaurant in an atomic way: if one fails, both operations are rolled back.
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

      // Check if the username is already taken
      if (usernameTaken) {
        _hasUsernameError = true;
        _errorMessage = 'Username is already taken';

        _isLoading = false;
        notifyListeners();
        return;
      }

      // In case a name is provided for the restaurant, we create entries for both user and restaurant
      if (restaurantName != null) {
        // First create the user without notifying the caller
        User? tempUser = await _auth.signUp(
          email: email,
          password: password,
          username: username,
          restaurantId: null, // At the beginning the restaurant ID is not associated
        );

        debugPrint("Temp user created: ${tempUser.id}");
        try {
          // Try to create the restaurant
          final RestaurantFirestore restaurantFirestore = RestaurantFirestore();
          final String restaurantId = await restaurantFirestore.createRestaurant(
            restaurantName: restaurantName,
            ownerId: tempUser.id,
          );

          // In case of success, update the user with the restaurant ID
          await _firestore.updateUserRestaurant(restaurantId);

          // If everything is successful, set the user
          _user = tempUser;
        } catch (e) {
          // In case of failure, delete the user account
          await _auth.deleteUserAccount();
          rethrow;
        }
      } else {
        // User creation without restaurant
        _user = await _auth.signUp(
          email: email,
          password: password,
          username: username,
          restaurantId: null,
        );
      }

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

  /// Checks if an email is already registered/in use
  /// Returns true if the email is already in use, false otherwise
  Future<bool> isEmailInUse(String email) async {
    _isLoading = true;
    clearErrors();

    try {
      _isLoading = false;
      return await _auth.isEmailInUse(email);

    } catch (e) {
      _errorMessage = "Error checking email availability";
      notifyListeners();
      return false;
    }
  }

  /// Completely deletes the user account including Firebase Authentication and all Firestore data
  Future<void> deleteUserAccount() async {
    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      // Then delete the user from Firebase Authentication
      await _auth.deleteUserAccount();

      // Clear local user data
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Checks if the user has logged in recently
  /// It is used before performing sensitive operations
  Future<bool> hasRecentLogin() async {
    _isLoading = true;
    clearErrors();

    try{
      _isLoading = false;
      return await _auth.hasRecentLogin();

    } catch (e){
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
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
        case'requires-recent-login':
          return 'This operation requires a recent login. Please sign out and sign in again.';
        default:
          return 'Error: ${error.message}';
      }
    }
    return 'An error occurred';
  }
}
