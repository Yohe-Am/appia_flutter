import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:appia/models/models.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object> get props => [];
}
// class GetUser extends UserEvent{

// }

class IncomingUserUpdate extends UserEvent {
  final User user;

  const IncomingUserUpdate({required this.user}) : assert(user != null);

  @override
  List<Object> get props => [user];
}

class AccountDeleteRequested extends UserEvent {
  final User user;

  const AccountDeleteRequested({required this.user}) : assert(user != null);

  @override
  List<Object> get props => [user];
}

class AccountUpdateRequested extends UserEvent {
  final User user;
  final UserUpdateInput userUpdateInput;

  const AccountUpdateRequested(
      {required this.user, required this.userUpdateInput})
      : assert(user != null && userUpdateInput != null);

  @override
  List<Object> get props => [user, userUpdateInput];
}

class AddPictureRequested extends UserEvent {
  final User user;
  final File file;

  const AddPictureRequested({required this.user, required this.file})
      : assert(user != null && file != null);

  @override
  List<Object> get props => [user, file];
}
