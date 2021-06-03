// ignore: import_of_legacy_library_into_null_safe
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String username;
  

  User(
      {required this.username,
      });

  @override
  List<Object> get props =>
      [username];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
    );
  }

  @override
  String toString() {
    return 'User[username=$username ]';
  }
}
