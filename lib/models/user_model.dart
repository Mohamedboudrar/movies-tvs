import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int count;
  final int avatar;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.count,
    this.avatar = 1,
  });

  // Créer un UserModel depuis Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      count: data['count'] ?? 0,
      avatar: data['avatar'] ?? 1
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'count': count,
      'avatar': avatar
    };
  }

  // Copier avec modifications
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? count,
    int? avatar
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      count: count ?? this.count,
      avatar: avatar ?? this.avatar
    );
  }
}
