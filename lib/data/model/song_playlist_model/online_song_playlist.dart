import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModelOnline {
  final String id;
  final String name;

  PlaylistModelOnline({required this.id, required this.name});

  factory PlaylistModelOnline.fromDoc(DocumentSnapshot doc) {
    return PlaylistModelOnline(id: doc.id, name: doc['name'] as String);
  }
}
