import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:appia/models/models.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object> get props => [];
}

class GetAllUsers extends UserEvent {}

class SearchUserRequested extends UserEvent {
  final String username;

  SearchUserRequested(this.username);
  @override
  List<Object> get props => [username];
}
