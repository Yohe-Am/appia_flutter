// ignore: import_of_legacy_library_into_null_safe
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String email;
  final String pictureURL;
  final List<String> roomHistory;
  final String token;

  User(
      {required this.username,
      required this.createdAt,
      required this.updatedAt,
      required this.email,
      required this.pictureURL,
      required this.roomHistory,
      required this.token});
  User.some(this.createdAt, this.updatedAt, this.pictureURL, this.roomHistory,
      {required this.username, required this.email, required this.token});

  @override
  List<Object> get props =>
      [username, createdAt, updatedAt, email, pictureURL, roomHistory, token];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      email: json['email'],
      pictureURL: json['pictureURL'] == null ? null : json['pictureURL'],
      roomHistory:
          (json['roomHistory'] as List).map((item) => item as String).toList(),
      token: '',
    );
  }

  @override
  String toString() {
    return 'User[username=$username, createdAt=$createdAt, updatedAt=$updatedAt, email=$email, pictureURL=$pictureURL, roomHistory=$roomHistory, token=$token ]';
  }
}
