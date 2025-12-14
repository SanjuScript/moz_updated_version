import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/utils/repository/user_repository/user_repo.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/screens/ONLINE/auth/presentation/ui/google_sign_in_screen.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class AuthGuard {
  static Future<bool> ensureLoggedIn(BuildContext context) async {
    final userRepo = sl<UserStorageAbRepo>();

    if (userRepo.isLoggedIn()) {
      return true;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GoogleSignInScreen()));

    return userRepo.isLoggedIn();
  }
}
