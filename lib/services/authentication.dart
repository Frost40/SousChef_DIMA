import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sous_chef/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';


class Authentication {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get currently authenticated Firebase user
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  // Stream of authentication state changes
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get complete user data including Firestore information
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    return User.fromFirestore(doc);
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Sign in with email and password and return user data
  Future<User> signIn(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );

    final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    return User.fromFirestore(doc);
  }

  // Register a new user and return user data
  Future<User> signUp({
    required String email,
    required String password,
    required String username,
    String? restaurantName,
  }) async {
    // Create user in Firebase Authentication
    firebase_auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );

    // Create user entry in Firestore
    final userData = {
      'email': email,
      'username': username,
      if (restaurantName == null) 'restaurantId': null, // Placeholder for future restaurant ID
    };

    await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);

    // Return new user data
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    return User.fromFirestore(userDoc);
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    if (googleSignInAccount == null) {
      throw Exception('Google sign in aborted');
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final firebase_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    return User.fromFirestore(doc);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}