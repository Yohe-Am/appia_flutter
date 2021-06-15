part of 'room_bloc.dart';

abstract class RoomState {
  const RoomState();
}

class RoomsLoading extends RoomState {}

class RoomsLoadSuccess extends RoomState {
  final List<Room> rooms;

  RoomsLoadSuccess([this.rooms = const []]);
}

class RoomsLoadFailure extends RoomState {}

class RoomAddSuccess extends RoomState {
  final Room room;
  RoomAddSuccess(this.room);
}

class RoomAddFail extends RoomState {}
