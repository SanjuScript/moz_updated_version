import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class FavoritesRepository {
  FavoritesRepository._internal();

  static final FavoritesRepository instance = FavoritesRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? get _userID => sl<UserStorageAbRepo>().userID;

  CollectionReference<Map<String, dynamic>> _favRef() {
    log(_userID.toString(), name: "USER ID**********");
    final uid = _userID;
    if (uid == null) {}
    return _firestore.collection("users").doc(_userID).collection("favorites");
  }

  Future<void> addFavorite({required String songId}) async {
    await _favRef().doc(songId).set({"addedAt": FieldValue.serverTimestamp()});
  }

  Future<void> removeFavorite({required String songId}) async {
    await _favRef().doc(songId).delete();
  }

  Stream<Set<String>> favoritesStream() {
    return _favRef().snapshots().map(
      (snap) => snap.docs.map((d) => d.id).toSet(),
    );
  }
}
