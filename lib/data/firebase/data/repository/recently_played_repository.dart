import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo_impl.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class OnlineRecentlyPlayedRepository {
  static const int maxItems = 20;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserStorageAbRepo get _userRepo => sl<UserStorageAbRepo>();

  String get _uid => _userRepo.userID ?? '';

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('recently_played');
  }

  Future<void> add(String songId) async {
    final uid = _uid;
    if (uid.isEmpty) return;

    final col = _collection(uid);
    final playedAt = DateTime.now().millisecondsSinceEpoch;

    final batch = _firestore.batch();

    batch.set(col.doc(songId), {"playedAt": playedAt}, SetOptions(merge: true));

    final snap = await col
        .orderBy("playedAt", descending: false)
        .limit(maxItems + 1)
        .get();

    if (snap.docs.length > maxItems) {
      batch.delete(snap.docs.first.reference);
    }

    await batch.commit();
  }

  Future<List<String>> fetchSongIds() async {
    final uid = _uid;
    if (uid.isEmpty) return [];

    final snap = await _collection(
      uid,
    ).orderBy("playedAt", descending: true).limit(maxItems).get();

    return snap.docs.map((d) => d.id).toList();
  }

  Stream<List<String>> watchSongIds() {
    final uid = _uid;
    if (uid.isEmpty) return const Stream.empty();

    return _collection(uid)
        .orderBy("playedAt", descending: true)
        .limit(maxItems)
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }

  Future<void> clear() async {
    final uid = _uid;
    if (uid.isEmpty) return;

    final snap = await _collection(uid).get();
    final batch = _firestore.batch();

    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
