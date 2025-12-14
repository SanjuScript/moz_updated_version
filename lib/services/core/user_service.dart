import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moz_updated_version/data/model/moz_user_model.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  Future<void> createUser(MozUserModel user) async {
    final docRef = _users.doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await _users.doc(user.uid).set(user.toMap());
      sl<UserStorageAbRepo>().saveUser(user.toUserModel());
    } else {
      await docRef.update({
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl,
        "lastLogin": DateTime.now(),
      });
      sl<UserStorageAbRepo>().saveUser(
        user
            .copyWith(
              name: user.name,
              email: user.email,
              photoUrl: user.photoUrl,
            )
            .toUserModel()
            .copyWith(lastLoginAt: DateTime.now()),
      );
    }
  }

  Future<MozUserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists) return null;

    return MozUserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> updateUser(MozUserModel user) async {
    await _users.doc(user.uid).update(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }
}
