import 'package:appia/blocs/p2p/p2p.dart';
import 'package:appia/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -- EVENTS

abstract class RoomScreenEvent {
  const RoomScreenEvent();
}

class CheckForConnection extends RoomScreenEvent {}

class SendMessage extends RoomScreenEvent {}

// class CancelSearch extends SearchScreenEvent {}

// -- STATE

abstract class RoomScreenState {
  const RoomScreenState();
}

class HasConnection extends RoomScreenState {
  final ConnectionBloc conn;

  HasConnection(this.conn);
}

class NoConnection extends RoomScreenState {}

// -- BLOC

class RoomScreenBloc extends Bloc<RoomScreenEvent, RoomScreenState> {
  P2PBloc p2pBloc;
  Room room;
  RoomScreenBloc(this.room, this.p2pBloc) : super(NoConnection());

  @override
  Stream<RoomScreenState> mapEventToState(RoomScreenEvent event) async* {
    if (event is CheckForConnection) {
      final conn = p2pBloc.state.connections[room.id];
      if (conn != null) {
        yield HasConnection(conn);
        return;
      }
      yield NoConnection();
    }
  }
}
