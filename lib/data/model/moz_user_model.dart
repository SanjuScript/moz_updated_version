// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:moz_updated_version/data/model/user_model/user_model.dart';

class MozUserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String photoUrl;

  MozUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  UserModel toUserModel() {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: createdAt,
      lastLoginAt: createdAt,
      isLoggedIn: true,
    );
  }

  factory MozUserModel.fromMap(Map<String, dynamic> map) {
    return MozUserModel(
      uid: map['uid'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      email: map['email'],
      createdAt: DateTime.parse(map['createdAt']),
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
