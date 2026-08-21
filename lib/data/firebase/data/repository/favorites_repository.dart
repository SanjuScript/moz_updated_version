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
    final uid = _userID;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    log(uid, name: "USER ID =====");
    return _firestore.collection("users").doc(uid).collection("favorites");
  }

  Future<void> addFavorite({required String songId}) async {
    await _favRef().doc(songId).set({"addedAt": FieldValue.serverTimestamp()});
  }

  Future<void> removeFavorite({required String songId}) async {
    await _favRef().doc(songId).delete();
  }

  Stream<Set<String>> favoritesStream() {
    return _favRef().snapshots().map((snap) {
      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final tA = a.data()['addedAt'] as Timestamp?;
        final tB = b.data()['addedAt'] as Timestamp?;
        if (tA == null && tB == null) return 0;
        if (tA == null) return 1; 
        if (tB == null) return -1;
        return tB.compareTo(tA);
      });
      return docs.map((d) => d.id).toSet();
    });
  }
}
