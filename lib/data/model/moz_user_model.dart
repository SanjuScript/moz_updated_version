import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moz_updated_version/data/model/user_model/user_model.dart';

class MozUserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime? createdAt;

  MozUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.createdAt,
  });
  final val = FieldValue.serverTimestamp();
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': val,
      'photoUrl': photoUrl,
    };
  }

  UserModel toUserModel() {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isLoggedIn: true,
    );
  }

  factory MozUserModel.fromMap(Map<String, dynamic> map) {
    return MozUserModel(
      uid: map['uid'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      email: map['email'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  String toString() {
    return 'MozUserModel(uid: $uid, name: $name, email: $email, createdAt: $createdAt, photoUrl: $photoUrl)';
  }

  MozUserModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
    String? photoUrl,
  }) {
    return MozUserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
