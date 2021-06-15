part of 'room_bloc.dart';

abstract class RoomEvent {
  const RoomEvent();
}

// TODO: Add it's own Bloc, ChatBloc
class LoadRooms extends RoomEvent {
  const LoadRooms();
}

class AddRoom extends RoomEvent {
  final Room room;
  AddRoom(this.room);

  @override
  toString() => 'Message sent {message: $room}';
}
