import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String age;
  final String phone;
  final String profileImageUrl;
  final String bio;
  final bool isPrivate;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.age,
    required this.phone,
    this.isPrivate = false,
    required this.profileImageUrl,
    required this.bio,
  });

  static const empty = User(
    id: '',
    username: '',
    displayName: '',
    age: '',
    phone: '',
    profileImageUrl: '',
    bio: '',
  );

  @override
  List<Object?> get props => [
        id,
        username,
        displayName,
        isPrivate,
        age,
        phone,
        profileImageUrl,
        bio,
      ];

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? age,
    String? phone,
    String? profileImageUrl,
    bool? isPrivate,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      isPrivate: isPrivate ?? this.isPrivate,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'username': username,
      'username_lower': username.toLowerCase(),
      'displayName': displayName,
      'age': age,
      'phone': phone,
      'isPrivate': isPrivate,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
    };
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      age: data['age'] ?? '',
      phone: data['phone'] ?? '',
      isPrivate: data["isPrivate"] ?? false,
      profileImageUrl: data['profileImageUrl'] ?? '',
      bio: data['bio'] ?? '',
    );
  }
}
