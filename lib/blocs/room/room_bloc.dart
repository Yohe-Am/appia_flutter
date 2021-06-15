import 'dart:async';

import 'package:appia/models/models.dart';
import 'package:appia/repository/room_reporistory.dart';
import 'package:bloc/bloc.dart';

// EVENTS

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

// STATE

abstract class RoomState {
  const RoomState();
}

class RoomsLoading extends RoomState {}

class RoomsLoadSuccess extends RoomState {
  final List<Room> rooms;

  RoomsLoadSuccess([this.rooms = const []]);
}

// BLOC

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomRepository repo;
  RoomBloc(this.repo) : super(RoomsLoading());

  @override
  Stream<RoomState> mapEventToState(
    RoomEvent event,
  ) async* {
    if (event is AddRoom) {
      repo.setRoom(event.room.id, event.room);
      if (state is RoomsLoadSuccess) {
        yield RoomsLoadSuccess(
            (state as RoomsLoadSuccess).rooms..add(event.room));
      } else {
        yield RoomsLoadSuccess([event.room]);
      }
    } else if (event is LoadRooms) {
      // TODO:  load from fs
      yield RoomsLoadSuccess([]);
    }
  }
}
