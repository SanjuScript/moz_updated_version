import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/core/utils/repository/user_repository/user_repo.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/data/model/moz_user_model.dart';
import 'package:moz_updated_version/services/navigation_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class AuthService {
  // GoogleSignIn is now a singleton
  final _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  AuthService() {
    _initializeGoogleSignIn();
    _googleSignIn.authenticationEvents.listen((event) {});
  }

  // Must call initialize() exactly once before using any other methods
  Future<void> _initializeGoogleSignIn() async {
    if (_isInitialized) return;

    try {
      await _googleSignIn.initialize(
        serverClientId:
            "908189132240-kqtun79469ds54e3i8ur7v1phjo1ocl8.apps.googleusercontent.com",
      );
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize Google Sign-In: $e');
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureInitialized();

    try {
      // Check if authenticate is supported on this platform
      if (!await _googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError(
          'authenticate() is not supported on this platform. '
          'Use platform-specific sign-in methods instead.',
        );
      }

      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // authentication is now a synchronous getter (no await)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      log(credential.asMap().toString());
      // Update current user
      _currentUser = googleUser;

      final user = MozUserModel(
        uid: _currentUser!.id,
        name: _currentUser!.displayName!,
        email: _currentUser!.email,
        createdAt: DateTime.now(),
        photoUrl: _currentUser!.photoUrl!,
      );

      sl<UserRepository>().saveUser(user);

      final context =
          sl<NavigationService>().navigatorKey.currentState!.context;

      sl<NavigationService>().goBack();
      Future.delayed(Durations.extralong3, () {
        AppSnackBar.success(context, "Login Sucess");
      });
      // context.read<OnlineFavoritesCubit>().onUserLoggedIn();
      log(user.toString());

      // Sign in to Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      log('Google Sign-In failed: ${e.code.name} - ${e.description}');
      rethrow;
    } catch (e) {
      log('Unexpected error during sign-in: $e');
      rethrow;
    }
  }

  // Replaced signInSilently with attemptLightweightAuthentication
  Future<GoogleSignInAccount?> attemptSilentSignIn() async {
    await _ensureInitialized();

    try {
      // This may return Future or immediate result
      final result = _googleSignIn.attemptLightweightAuthentication();

      if (result is Future<GoogleSignInAccount?>) {
        final account = await result;
        _currentUser = account;

        return account;
      } else {
        _currentUser = result as GoogleSignInAccount?;
        return _currentUser;
      }
    } catch (e) {
      print('Silent sign-in failed: $e');
      return null;
    }
  }

  GoogleSignInAuthentication getAuthTokens(GoogleSignInAccount account) {
    // authentication is now synchronous (no await)
    return account.authentication;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
  }
}
