import 'package:equatable/equatable.dart';

class UserInput extends Equatable {
  final String password;
  final String email;
  final String username;
  UserInput(
      {required this.email, required this.password, required this.username});
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'CreateUserInput[email=$email, password=$password, username=$username]';
  }

  @override
  List<Object> get props => [password, email];
}
