import 'package:appia/p2p/p2p.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appia/p2p/transports/transports.dart';

// -- EVENTS

abstract class ConnectionEvent {}

class Reconnect extends ConnectionEvent {}

// class Connect extends ConnectionEvent {}

class StopConnection extends ConnectionEvent {
  final CloseReason reason;
  StopConnection(this.reason);
}

class Disconnected extends ConnectionEvent {
  final CloseReason reason;
  Disconnected(this.reason);
}

class ConnectionError extends ConnectionEvent {
  final Object error;
  ConnectionError(this.error);
}

// -- STATE

enum ConnectionState { Connected, Connecting, NotConnected }

// -- BLOC

/// This guy's responsible for reconnection when connection goes down.
///   "...ya can call me TCP"
///
/// TODO: find a way to make this get this started without needing a pre-existing
/// connection.
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  // TODO(Yohe): figure out where to start using EventedConnection
  // right now it's here but I can't say if it's the right place

  /// ConnectioinBloc doesn't make use of `EventedConnection` `onMessage`
  /// slot. Listen for ConnectionError
  late final EventedConnection eventedConnection;
  bool reconnect;

  /// The dialer is responsible for reconnection.
  /// You can still add a Reconnect event from elsewhere to
  /// override this and enable auto reconnection.
  ConnectionBloc(
    AbstractConnection connection, {
    this.reconnect = false,
  }) : super(ConnectionState.Connected) {
    // TODO: figure out a sensible hierarchy of connections
    this.eventedConnection = new EventedConnection(
      connection,
      onError: this._onErrorHandler,
      onFinish: this._onFinishHandler,
    );
  }
  // factory ConnectionBloc.connect() => ConnectionBloc()..add(Connect());

  void _onErrorHandler(EventedConnection socket, Object err) {
    this.add(ConnectionError(err));
  }

  void _onFinishHandler(EventedConnection socket, CloseReason reason) {
    this.add(Disconnected(reason));
  }

  @override
  Stream<ConnectionState> mapEventToState(ConnectionEvent event) async* {
    print("got event: ${event.toString()}");
    print("reconnect?: ${this.reconnect}");
    if (event is ConnectionError || event is Disconnected) {
      yield ConnectionState.Connecting;
      await Future.delayed(const Duration(seconds: 1));
      if (this.reconnect) {
        this.add(Reconnect());
      } else {
        yield ConnectionState.NotConnected;
      }
    } else if (event is StopConnection) {
      this.reconnect = false;
      this.eventedConnection.close(event.reason);
      yield ConnectionState.NotConnected;
    } else if (event is Reconnect) {
      this.reconnect = true;
      yield ConnectionState.Connecting;
      await this.eventedConnection.reconnect();
      yield ConnectionState.Connected;
    }
  }

  @override
  Future<void> close([
    CloseReason reason = const CloseReason(
        code: CloseCode.GoingAway, message: "discarding connection bloc"),
  ]) async {
    this.eventedConnection.close(reason);
    await super.close();
  }
}
