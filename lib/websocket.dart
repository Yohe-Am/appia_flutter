// TODO: test this
// I just copied the client we used from offTime and made it null-safe. Lot's of work left to be done
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as ws_channel;
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

class Message<T> {
  final String event;
  final T data;
  Message(this.event, this.data);
  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(json["event"], json["data"]);

  String toJson() => '{ "event": "$event", "data": ${jsonEncode(data)}}';
}

class WsNotConnectedException implements Exception {}

Future<WsConnection> dial(Uri address) async {
  // TODO: make connect call async
  final channel = ws_channel.WebSocketChannel.connect(address);
  return WsConnection(address, channel);
}

Future<WsListener> listen(Uri address) async {
  throw UnimplementedError();
}

/* 
 * WsConnection with event based interface.
 * 
 * TODO: test this
 * */
class WsConnection {
  bool _connected = false;
  ws_channel.WebSocketChannel _channel;
  late Stream<dynamic> _streamAsBrodacast;

  final Uri peerAddress;

  // bool reconnectOnFailure;
  void Function(WsConnection, int)? onFinish;
  void Function(WsConnection, Message<dynamic>)? onMessage;
  void Function(WsConnection, Object err)? onError;

  final Map<String, void Function(WsConnection socket, dynamic data)>
      _eventListeners;

  WsConnection(
    this.peerAddress,
    this._channel, {
    this.onError,
    this.onFinish,
    this.onMessage,
    // this.reconnectOnFailure = true,
  }) : this._eventListeners = new Map() {
    this._streamAsBrodacast = _channel.stream.asBroadcastStream();
    this._streamAsBrodacast.listen(this._onData,
        onDone: this._onDone, onError: this._onError, cancelOnError: true);
  }

  // private stuff

  void _onData(dynamic dynamicMessage) {
    print(dynamicMessage);
    try {
      final message = Message<dynamic>.fromJson(jsonDecode(dynamicMessage));
      this.onMessage?.call(this, message);
      this._eventListeners[message.event]?.call(this, message.data);
    } catch (err) {
      print("error decoding message $err");
      this
          .onError
          ?.call(this, new ErrorDescription("error thrown in _onData: $err"));
    }
  }

  void _onError(Object err, StackTrace _) {
    print("websocket err: ${err.toString()}");
    this._connected = false;
    this.onError?.call(this, err);
  }

  void _onDone() {
    this._connected = false;
    try {
      this.onFinish?.call(this, this._channel.closeCode!);
    } catch (err) {
      print("error decoding message $err");
      this
          .onError
          ?.call(this, new ErrorDescription("error thrown in _onDone: $err"));
    }
  }

  // public stuff
  bool get isConnected => this._connected;

  /// Get a new instance of the message stream.
  Stream<Message<Map<String, dynamic>>> get messageStream {
    if (!this._connected) throw WsNotConnectedException();
    return this
        ._streamAsBrodacast
        .map((msg) => Message.fromJson(jsonDecode(msg)));
  }

  Stream<dynamic> getEventStream(String event) {
    if (!this._connected) throw WsNotConnectedException();
    return this
        .messageStream
        .where((msg) => msg.event == event)
        .map((msg) => msg.data);
  }

  /* Use this to reconnect when connection fails. */
  Future<void> connect() async {
    await this.close();
    print("connecting websocket to addr $this.peerAddress");
    final channel = ws_channel.WebSocketChannel.connect(this.peerAddress);

    // use class methods to allow swapping out handlers during runtime
    this._streamAsBrodacast = channel.stream.asBroadcastStream();
    this._streamAsBrodacast.listen(this._onData,
        onDone: this._onDone, onError: this._onError, cancelOnError: true);
    this._channel = channel;
    this._connected = true;
  }

  Future<void> close() async {
    if (this._connected) {
      await this._channel.sink.close(status.goingAway, "going away");
      this._connected = false;
    }
  }

  Future<void> emit<T>(Message<T> message) async {
    if (!this._connected) throw WsNotConnectedException();
    print("outgoing message: ${message.data.toString()}");
    final jsonString = message.toJson();
    this._channel.sink.add(jsonString);
  }

  void listen(
    String event,
    void Function(WsConnection socket, dynamic data) listener,
  ) {
    this._eventListeners[event] = listener;
  }

  Future<Message<dynamic>> sendRequest<T>(String requestEvent, T message,
      {String? responseEvent, Duration? timeout}) async {
    if (!this._connected) throw WsNotConnectedException();

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

    await this.emit(Message(requestEvent, message));
    return this
        .messageStream
        .firstWhere((msg) => msg.event == responseEvent)
        .timeout(timeout);
  }
}

/*
 * TODO: research
 */
class WsListener {}
