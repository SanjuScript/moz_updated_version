import 'package:moz_updated_version/data/model/moz_user_model.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/core/user_service.dart';

import '../../../../services/core/app_services.dart';

class UserRepository {
  final UserService _userService = UserService();

  Future<void> saveUser(MozUserModel user) {
    return _userService.createUser(user);
  }

  Future<MozUserModel?> fetchUser(String uid) {
    return _userService.getUser(uid);
  }

  Future<void> updateUser(MozUserModel user) {
    return _userService.updateUser(user);
  }

  Future<void> removeUser(String uid) {
    return _userService.deleteUser(uid);
  }
}
