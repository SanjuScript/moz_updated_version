// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? phone;

  @HiveField(4)
  String? photoUrl;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? lastLoginAt;

  @HiveField(7)
  bool isLoggedIn;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isLoggedIn = false,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isLoggedIn,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, phone: $phone, photoUrl: $photoUrl, createdAt: $createdAt, lastLoginAt: $lastLoginAt, isLoggedIn: $isLoggedIn)';
  }
}
