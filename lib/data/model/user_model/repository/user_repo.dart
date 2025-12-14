import 'package:moz_updated_version/data/model/user_model/user_model.dart';

abstract class UserStorageAbRepo {
  UserModel? getUser(String uid);

  Future<void> saveUser(UserModel user);

  Future<void> updateUser(UserModel user);

  Future<void> deleteUser(String uid);

  Future<void> clearUser();

  bool isLoggedIn();

  Future<void> setLoggedIn(bool value);
}
