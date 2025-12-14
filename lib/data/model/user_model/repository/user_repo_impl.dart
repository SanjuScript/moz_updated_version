import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/data/model/user_model/user_model.dart';

class UserStorageRepository implements UserStorageAbRepo {
  final Box<UserModel> _box = Hive.box<UserModel>('mozuser');

  static const _key = 'current_user';

  @override
  String? get userID => getUser()?.uid;

  @override
  UserModel? getUser() {
    return _box.get(_key);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _box.put(_key, user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _box.put(_key, user);
  }

  @override
  Future<void> deleteUser() async {
    await _box.delete(_key);
  }

  @override
  Future<void> clearUser() async {
    await _box.clear();
  }

  @override
  bool isLoggedIn() {
    return _box.get(_key)?.isLoggedIn ?? false;
  }

  @override
  Future<void> setLoggedIn(bool value) async {
    final user = _box.get(_key);
    if (user == null) return;

    user.isLoggedIn = value;
    user.lastLoginAt = value ? DateTime.now() : user.lastLoginAt;
    await user.save();
  }
}
