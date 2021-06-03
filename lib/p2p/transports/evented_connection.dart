import 'dart:convert';

import 'transports.dart';

/* 
 * This is a relic from offTime. Too obviously so.
 */

/// A dumb message format
///
/// TODO: improve
/// TODO(Yohe): should we make this part of the AbstractConnection interface?
class EventMessage<T> {
  final String event;
  final T data;
  const EventMessage(this.event, this.data);
  factory EventMessage.fromJson(Map<String, dynamic> json) =>
      EventMessage(json["event"], json["data"]);

  String toJson() => '{ "event": "$event", "data": ${jsonEncode(data)}}';
}

/// A wrapper over AbstractConnection that provides Socket IO kinda messaging
///
/// TODO: consider making this non-genric
class EventedConnection<C extends AbstractConnection> {
  final AbstractConnection connection;

  void Function(EventedConnection<C>, CloseReason)? onFinish;
  void Function(EventedConnection<C>, EventMessage<dynamic>)? onMessage;
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
          EventMessage<dynamic>.fromJson(jsonDecode(dynamicMessage));
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
  /// `Map<String, dynamic>` for JSON objects.
  Stream<EventMessage<dynamic>> get messageStream {
    // Stream<AppiaMessage<Map<String, dynamic>>> get messageStream {
    if (!this.isConnected) throw NotConnectedException();
    return this
        ._messageStream
        .map((msg) => EventMessage.fromJson(jsonDecode(msg)));
  }

  /// Subsribe to events in stream form
  Stream<dynamic> getEventStream(String event) {
    if (!this.isConnected) throw NotConnectedException();
    return this
        .messageStream
        .where((msg) => msg.event == event)
        .map((msg) => msg.data);
  }

  Future<void> reconnect() async {
    print("reconnecting to addr $this.connection.peerAddress");
    await this.connection.reconnect();
    this._setup();
  }

  Future<void> close(CloseReason reason) async {
    if (this.isConnected) {
      await this.connection.close(reason);
    }
  }

  /// Publish events
  Future<void> emit<T>(EventMessage<T> message) async {
    if (!this.isConnected) throw NotConnectedException();
    print("outgoing message: ${message.data.toString()}");
    final jsonString = message.toJson();
    this._messageSink.add(jsonString);
  }

  /// Subscribe to events
  void listen(
    String event,
    void Function(EventedConnection<C> connection, dynamic data) listener,
  ) {
    this._eventListeners[event] = listener;
  }

  /// Provides RPC like capacity over the PubSub stream
  Future<EventMessage<dynamic>> sendRequest<T>(
    String requestEvent,
    T message, {
    String? responseEvent,
    Duration? timeout,
  }) async {
    if (!this.isConnected) throw NotConnectedException();

    if (responseEvent == null) responseEvent = requestEvent;
    if (timeout == null) timeout = Duration(seconds: 3);

    await this.emit(EventMessage(requestEvent, message));
    return this
        .messageStream
        .firstWhere((msg) => msg.event == responseEvent)
        .timeout(timeout);

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
  }
}
