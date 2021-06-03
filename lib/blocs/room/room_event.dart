part of 'room_bloc.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object> get props => [];
}

// TODO: Add it's own Bloc, ChatBloc
class LoadRooms extends RoomEvent {
  const LoadRooms();

  @override
  List<Object> get props => [];
}

class AddRoom extends RoomEvent {
  final Room room;
  AddRoom(this.room);

  @override
  List<Object> get props => [room];

  @override
  toString() => 'Message sent {message: $room}';  
}
