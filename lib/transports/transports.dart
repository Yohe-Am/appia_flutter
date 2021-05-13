import 'dart:convert';

import 'dart:io';

abstract class AbstractTransport<L extends AbstractListener<C>,
    C extends AbstractConnection> {
  Future<C> dial(Uri address);
  Future<L> listen(InternetAddress listeningAddress, int listeningPort,
      {String path = "/"});
}

abstract class AbstractListener<C extends AbstractConnection> {
  Stream<C> get incomingConnections;
}

abstract class AbstractConnection {
  bool get isConnected;
  Uri get peerAddress;

  /* Get a new instance of the incoming message stream. */
  Stream<dynamic> get messageStream;
  /*  Get a reference to the message sink. */
  Sink<dynamic> get messageSink;
  Future<void> close(CloseReason reason);

  /// Use this to reconnect when connection fails.
  ///
  /// This closes the connection if not closed with a [CloseCode.NormalClosure]
  Future<void> reconnect();
  /* This will be null if it's not closed */
  CloseReason? get closeReason;
}

class AppiaMessage<T> {
  final String event;
  final T data;
  AppiaMessage(this.event, this.data);
  factory AppiaMessage.fromJson(Map<String, dynamic> json) =>
      AppiaMessage(json["event"], json["data"]);

  String toJson() => '{ "event": "$event", "data": ${jsonEncode(data)}}';
}

class NotConnectedException implements Exception {}

enum CloseCode {
  /// The purpose for which the connection was established has been fulfilled.
  NormalClosure,

  /// An endpoint is "going away", such as a server going down or a browser having
  /// navigated away from a page.
  GoingAway,

  /// An endpoint is terminating the connection due to a protocol error.
  ProtocolError,

  /// An endpoint is terminating the connection because it has received a type of
  /// data it cannot accept.
  ///
  /// For example, an endpoint that understands only text data MAY send this if it
  /// receives a binary message).
  UnsupportedData,

  /// No status code was present.
  ///
  /// This **must not** be set explicitly by an endpoint.
  NoStatusReceived,

  /// The connection was closed abnormally.
  ///
  /// For example, this is used if the connection was closed without sending or
  /// receiving a Close control frame.
  ///
  /// This **must not** be set explicitly by an endpoint.
  AbnormalClosure,

  /// An endpoint is terminating the connection because it has received data
  /// within a message that was not consistent with the type of the message.
  ///
  /// For example, the endpoint may have receieved non-UTF-8 data within a text
  /// message.
  InvalidFramePayloadData,

  /// An endpoint is terminating the connection because it has received a message
  /// that violates its policy.
  ///
  /// This is a generic status code that can be returned when there is no other
  /// more suitable status code (such as [unsupportedData] or [messageTooBig]), or
  /// if there is a need to hide specific details about the policy.
  PolicyViolation,

  /// An endpoint is terminating the connection because it has received a message
  /// that is too big for it to process.
  MessageTooBig,

  /// The client is terminating the connection because it expected the server to
  /// negotiate one or more extensions, but the server didn't return them in the
  /// response message of the WebSocket handshake.
  ///
  /// The list of extensions that are needed should appear in the close reason.
  /// Note that this status code is not used by the server, because it can fail
  /// the WebSocket handshake instead.
  MissingMandatoryExtension,

  /// The server is terminating the connection because it encountered an
  /// unexpected condition that prevented it from fulfilling the request.
  InternalServerError,

  /// The connection was closed due to a failure to perform a TLS handshake.
  ///
  /// For example, the server certificate may not have been verified.
  ///
  /// This **must not** be set explicitly by an endpoint.
  TlsHandshakeFailed,
}

class CloseReason {
  CloseCode? code;
  String? message;
  CloseReason({this.code, this.message});
}

/// A wrapper over AbstractConnection that provides Socket IO kinda messaging
class EventedConnection<C extends AbstractConnection> {
  final C connection;

  // bool reconnectOnFailure;
  void Function(EventedConnection<C>, CloseReason)? onFinish;
  void Function(EventedConnection<C>, AppiaMessage<dynamic>)? onMessage;
  void Function(EventedConnection<C>, Object err)? onError;

  final Map<String, void Function(EventedConnection<C> socket, dynamic data)>
      _eventListeners;

  late Stream<dynamic> _messageStream;
  // The wrapped AbstractConnection will handle closing the sink
  // ignore: close_sinks
  late Sink<dynamic> _messageSink;

  EventedConnection(
    this.connection, {
    this.onError,
    this.onFinish,
    this.onMessage,
    // this.reconnectOnFailure = true,
  }) : this._eventListeners = new Map() {
    this._setup();
  }

  void _setup() {
    this._messageStream = this.connection.messageStream;
    this._messageSink = this.connection.messageSink;
    this._messageStream.listen(this._onData,
        onDone: this._onDone, onError: this._onError, cancelOnError: true);
  }

  // private stuff

  void _onData(dynamic dynamicMessage) {
    print(dynamicMessage);
    try {
      final message =
          AppiaMessage<dynamic>.fromJson(jsonDecode(dynamicMessage));
      this.onMessage?.call(this, message);
      this._eventListeners[message.event]?.call(this, message.data);
    } catch (err) {
      print("error decoding message $err");
      this.onError?.call(this, new Exception("error thrown in _onData: $err"));
    }
  }

  void _onError(Object err, StackTrace _) {
    print("websocket err: ${err.toString()}");
    this.onError?.call(this, err);
  }

  void _onDone() {
    try {
      this.onFinish?.call(this, this.connection.closeReason!);
    } catch (err) {
      print("error decoding message $err");
      this.onError?.call(this, new Exception("error thrown in _onDone: $err"));
    }
  }

  // public stuff
  bool get isConnected => this.connection.isConnected;

  /// Get a new instance of the message stream.
  ///
  /// Message data will be one of the JSON types
  /// Map<String, dynamic> for JSON objects.
  Stream<AppiaMessage<dynamic>> get messageStream {
    // Stream<AppiaMessage<Map<String, dynamic>>> get messageStream {
    if (!this.isConnected) throw NotConnectedException();
    return this
        ._messageStream
        .map((msg) => AppiaMessage.fromJson(jsonDecode(msg)));
  }

  Stream<dynamic> getEventStream(String event) {
    if (!this.isConnected) throw NotConnectedException();
    return this
        .messageStream
        .where((msg) => msg.event == event)
        .map((msg) => msg.data);
  }

  Future<void> reconnect() async {
    print("connecting websocket to addr $this.connection.peerAddress");
    await this.connection.reconnect();
    this._setup();
  }

  Future<void> close(CloseReason reason) async {
    if (this.isConnected) {
      await this.connection.close(reason);
    }
  }

  Future<void> emit<T>(AppiaMessage<T> message) async {
    if (!this.isConnected) throw NotConnectedException();
    print("outgoing message: ${message.data.toString()}");
    final jsonString = message.toJson();
    this._messageSink.add(jsonString);
  }

  void listen(
    String event,
    void Function(EventedConnection<C> connection, dynamic data) listener,
  ) {
    this._eventListeners[event] = listener;
  }

  Future<AppiaMessage<dynamic>> sendRequest<T>(String requestEvent, T message,
      {String? responseEvent, Duration? timeout}) async {
    if (!this.isConnected) throw NotConnectedException();

    if (responseEvent == null) responseEvent = requestEvent;
    if (timeout == null) timeout = Duration(seconds: 3);

    /* // keep a reference if there were any previous listeners;
    final oldListener = this._eventListeners[responseEvent];
    final responseListener = (OffTimeSocket socket, dynamic data) {
      if (oldListener != null) {
        // reinstate old listner
        this._eventListeners[responseEvent] = oldListener;
        oldListener.call(socket, data);
      }
      return data;
    };
    // replace with new listener
    this._eventListeners[responseEvent] = responseListener; */

    await this.emit(AppiaMessage(requestEvent, message));
    return this
        .messageStream
        .firstWhere((msg) => msg.event == responseEvent)
        .timeout(timeout);
  }
}
