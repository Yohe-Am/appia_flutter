import 'package:equatable/equatable.dart';

class UserUpdateInput extends Equatable {
  final String password;
  final String email;
  final String pictureURL;
  UserUpdateInput(this.pictureURL,
      {required this.email, required this.password});
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'email': email,
      'pictureURL': pictureURL,
    };
  }

  @override
  String toString() {
    return 'CreateUserInput[email=$email, password=$password, picture URL=$pictureURL ]';
  }

  @override
  List<Object> get props => [password, email, pictureURL];
}
