import 'dart:collection';
import 'dart:async';

import 'package:namester/namester.dart';

import 'namester_client.dart';
import 'transports/transports.dart';

/// This is the connection after the handshake
///
/// DON'T add any `Stream` interfaces onto this
/// like close or streams
/// Users should access the inner connection, like wrapping it
/// in an [`EventedConnection`] the way [`ConnectionBloc`] does
/// Use it to only attach metadata
class AppiaConnection {
  final String id;
  final AbstractConnection connection;
  AppiaConnection(this.id, this.connection);
  // AppiaConnection.fromRaw(this.id, AbstractConnection rawConn): connection = EventedConnection(rawConn);
}

/// TODO: break it apart into multiple classes
///
/// Identified responsiblities:
/// - store/manage ongoing connections, listeners
/// - an interface for interacting with all connections at once?
class P2PNode {
  final Map<TransportType, AbstractTransport> transports = new HashMap();
  final Map<ListeningAddress, AbstractListener> listeners = new HashMap();
  final Map<String, AppiaConnection> peerConnections = new HashMap();

  late StreamController<AppiaConnection> _incomingConnectionsController;

  /// Listen on this to get a stream of connections combind from all registered
  /// AbstractListeners
  late final Stream<AppiaConnection> incomingConnections;

  // TODO: support multiple namesters
  AbstractNamester namester;

  P2PNode(
    this.namester, {
    Iterable<AbstractTransport>? tports,
    Iterable<AbstractListener>? listeners,
  }) {
    tports?.forEach(
      (tport) {
        this.transports[tport.type] = tport;
      },
    );

    this._incomingConnectionsController = StreamController.broadcast();
    this.incomingConnections = this._incomingConnectionsController.stream;
    // .map((connection) => EventedConnection(connection));
  }

  void addListener(AbstractListener listener) {
    this.listeners[listener.listeningAddress] = listener;

    listener.incomingConnections.listen((conn) {
      // FIXME: so I guess no handshake goes down if we don't have listeners
      // but that's never going to occur I imagine
      if (this._incomingConnectionsController.hasListener) {
        this
            ._doHandshake(conn)
            .then((conn) => _incomingConnectionsController.add(conn));
      } else {
        throw new Exception("Incoming connection but no one's listening wtf");
      }
    }, onError: (e) {
      print("error listening $e");
    }, onDone: () {
      this.listeners.remove(listener.listeningAddress);
    });
  }

  AppiaConnection addConnection(String peerId, AbstractConnection connection) {
    final appiaConn = AppiaConnection(peerId, connection);
    this.peerConnections[peerId] = appiaConn;

    // don't store finished connections
    connection.stream.listen(
      null,
      // TODO: test if onDone is emitted when connection goes down erroneously
      onDone: () {
        this.peerConnections.remove(peerId);
      },
    );

    return appiaConn;
  }

  Future<AppiaConnection> _doHandshake(AbstractConnection connection) async {
    // TODO: implement hanshake
    return this.addConnection((P2PNode._lastAppiaId++).toString(), connection);
  }

  static int _lastAppiaId = 1;
  Future<AppiaConnection> connectTo(String id) async {
    if (peerConnections.containsKey(id))
      throw Exception("already connected to peer with id $id");

    final addr = await this.namester.getAddressForId(id);
    if (addr == null) throw NoNodeFoundForIdException(id);

    final tport = this.transports[addr.transportType];
    if (tport == null)
      throw PeerTransportUnsupportedException(addr.transportType);

    try {
      final connection = await tport.dial(addr);
      return this._doHandshake(connection);
    } catch (e) {
      throw NetworkException(
          "unable to connect to user (${id.toString()}) at addr (${addr.toString()}): e.print");
    }
  }

  Future<void> close() async {
    for (var listener in this.listeners.values) {
      listener.close();
    }
    for (var conn in this.peerConnections.values) {
      // TODO: more close reasons specific to appia?
      await conn.connection.close(
        const CloseReason(
            code: CloseCode.GoingAway,
            message: "app's shutting down or something"),
      );
    }
    this._incomingConnectionsController.close();
  }
}

abstract class AppiaException {
  final dynamic message;

  AppiaException([this.message]);

  String toString() {
    Object? message = this.message;
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}

class NoNodeFoundForIdException extends AppiaException {
  NoNodeFoundForIdException(dynamic id)
      : super("unable to find address for id: $id");
}

class PeerTransportUnsupportedException extends AppiaException {
  PeerTransportUnsupportedException(TransportType type)
      : super("peer transport (${type.toString()}) not supported");
}

class NetworkException extends AppiaException {
  NetworkException([dynamic message]) : super(message);
}
