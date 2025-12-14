import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/data/model/user_model/user_model.dart';

class UserStorageRepository implements UserStorageAbRepo {
  final Box<UserModel> _box = Hive.box<UserModel>('mozuser');

  @override
  UserModel? getUser(String uid) {
    return _box.get(uid);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _box.put(user.uid, user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    if (_box.containsKey(user.uid)) {
      await user.save();
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _box.delete(uid);
  }

  @override
  Future<void> clearUser() async {
    await _box.clear();
  }

  @override
  bool isLoggedIn() {
    final users = _box.values;
    if (users.isEmpty) return false;
    return users.first.isLoggedIn;
  }

  @override
  Future<void> setLoggedIn(bool value) async {
    if (_box.isEmpty) return;

    final user = _box.values.first;
    user.isLoggedIn = value;
    user.lastLoginAt = value ? DateTime.now() : user.lastLoginAt;
    await user.save();
  }
}
