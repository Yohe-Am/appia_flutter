import 'dart:async';

import 'package:appia/AppiaData.dart';
import 'package:appia/models/room.dart';
import 'package:appia/models/text_message.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc() : super(RoomsLoading());

  @override
  Stream<RoomState> mapEventToState(
    RoomEvent event,
  ) async* {
    if (event is AddRoom) {
      // get this from the data provider or the services later
      AppiaData.chatRoom.add(event.room);

      yield RoomAddSuccess(event.room);

      //yield RoomAddFailure();
    } else if (event is LoadRooms) {
      List<Room> rooms = AppiaData.chatRoom;
      yield RoomsLoadSuccess(rooms);
      //yield RoomLoadFailure();
    }
  }
}
