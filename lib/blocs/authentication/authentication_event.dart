import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:appia/models/models.dart';

abstract class UserAuthenticationEvent extends Equatable {
  const UserAuthenticationEvent();
  @override
  List<Object> get props => [];
}

class IsLoggedIn extends UserAuthenticationEvent {}

class SignUpRequested extends UserAuthenticationEvent {
  final UserInput userInput;

  const SignUpRequested({required this.userInput}) : assert(userInput != null);

  @override
  List<Object> get props => [userInput];
}

class LoginRequested extends UserAuthenticationEvent {
  final UserInput userInput;

  const LoginRequested({required this.userInput}) : assert(userInput != null);

  @override
  List<Object> get props => [userInput];
}

class LogoutRequested extends UserAuthenticationEvent {}
