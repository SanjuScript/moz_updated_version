import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/firebase_options.dart';
import 'package:moz_updated_version/services/service_locator.dart';

/// Service class to handle Firebase initialization
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase with platform-specific options
  /// Call this in main() before runApp()
  Future<void> initialize({FirebaseOptions? options}) async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('Firebase is already initialized');
      }
      return;
    }

    try {
      if (options != null) {
        // Initialize with custom options
        await Firebase.initializeApp(options: options);
      } else {
        // Initialize with default options from firebase_options.dart
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _isInitialized = true;

      if (kDebugMode) {
        print('Firebase initialized successfully');
        print('Firebase App Name: ${Firebase.app().name}');
        print('Firebase Options: ${Firebase.app().options}');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase initialization failed: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during Firebase initialization: $e');
      }
      rethrow;
    }
  }

  /// Get the current Firebase app instance
  FirebaseApp get app {
    if (!_isInitialized) {
      throw StateError(
        'Firebase has not been initialized. Call initialize() first.',
      );
    }
    return Firebase.app();
  }

  /// Check if Firebase is configured for the current platform
  bool get isConfigured {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete the Firebase app instance (useful for testing)
  Future<void> delete() async {
    if (_isInitialized) {
      await Firebase.app().delete();
      _isInitialized = false;
      if (kDebugMode) {
        print('Firebase app deleted');
      }
    }
  }
}
