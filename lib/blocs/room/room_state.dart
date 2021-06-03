part of 'room_bloc.dart';

abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object> get props => [];
}

class RoomsLoading extends RoomState {}

class RoomsLoadSuccess extends RoomState {
  final List<Room> rooms;

  RoomsLoadSuccess([this.rooms = const []]);

  @override
  List<Object> get props => [rooms];
}

class RoomsLoadFailure extends RoomState {}

class RoomAddSuccess extends RoomState {
  final Room room;
  RoomAddSuccess(this.room);

  @override
  List<Object> get props => [room];
}

class RoomAddFail extends RoomState {}
