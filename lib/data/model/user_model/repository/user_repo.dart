import 'package:moz_updated_version/data/model/user_model/user_model.dart';

abstract class UserStorageAbRepo {
  UserModel? getUser();

  Future<void> saveUser(UserModel user);

  Future<void> updateUser(UserModel user);

  String? get userID;

  Future<void> deleteUser();

  Future<void> clearUser();

  bool isLoggedIn();

  Future<void> setLoggedIn(bool value);
}
