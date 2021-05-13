// TODO: test this
// Yohe: I just copied the client we used from offTime and made it null-safe. Lot's of work left to be done

import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart' as ws_channel;
import 'package:web_socket_channel/io.dart' as ws_channel_io;
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:appia/transports/transports.dart';

class WsNotConnectedException extends NotConnectedException {}

class WsTransport extends AbstractTransport<WsListener, WsConnection> {
  Future<WsConnection> dial(Uri address) async {
    // TODO: make connect call async
    final channel = ws_channel.WebSocketChannel.connect(address);
    return WsConnection(address, channel);
  }

  Future<WsListener> listen(InternetAddress listeningAddress, int listeningPort,
      {String path = "/"}) async {
    // TODO: make this support web platform (can we even? listening on a port in a browser?)
    var server = await HttpServer.bind(listeningAddress, listeningPort);
    return WsListener(server, listeningAddress, listeningPort, path: path);
  }
}

/* 
 * WsConnection with event based interface.
 * 
 * TODO: test this
 * */
class WsConnection extends AbstractConnection {
  bool _connected = true;
  ws_channel.WebSocketChannel _channel;
  late Stream<dynamic> _streamAsBrodacast;

  final Uri peerAddress;

  WsConnection(
    this.peerAddress,
    this._channel,
  ) {
    this._streamAsBrodacast = _channel.stream.asBroadcastStream();
    this._streamAsBrodacast.listen(
      null,
      onDone: () {
        this._connected = false;
      },
      onError: (_, __) {
        this._connected = false;
      },
      cancelOnError: true,
    );
  }

  @override
  bool get isConnected => this._connected;

  @override
  Stream<dynamic> get messageStream {
    if (!this._connected) throw WsNotConnectedException();
    return this._streamAsBrodacast;
  }

  @override
  Sink<dynamic> get messageSink {
    if (!this._connected) throw WsNotConnectedException();
    return this._channel.sink;
  }

  @override
  Future<void> reconnect() async {
    await this.close(
        CloseReason(code: CloseCode.NormalClosure, message: "reconnecting"));
    print("connecting websocket to addr $this.peerAddress");
    final channel = ws_channel.WebSocketChannel.connect(this.peerAddress);
    this._streamAsBrodacast = channel.stream.asBroadcastStream();
    this._channel = channel;
    this._connected = true;
  }

  @override
  Future<void> close(CloseReason reason) async {
    if (this._connected) {
      await this._channel.sink.close(
          WsConnection._closeCodeToWsStatus(reason.code), reason.message);
      this._connected = false;
    }
  }

  static CloseCode? _wsStatusToCloseCode(int? statusCode) {
    switch (statusCode) {
      case null:
        return null;
      case ws_status.abnormalClosure:
        return CloseCode.AbnormalClosure;
      case ws_status.goingAway:
        return CloseCode.GoingAway;
      case ws_status.internalServerError:
        return CloseCode.InternalServerError;
      case ws_status.invalidFramePayloadData:
        return CloseCode.InvalidFramePayloadData;
      case ws_status.messageTooBig:
        return CloseCode.MessageTooBig;
      case ws_status.missingMandatoryExtension:
        return CloseCode.MissingMandatoryExtension;
      case ws_status.noStatusReceived:
        return CloseCode.NoStatusReceived;
      case ws_status.normalClosure:
        return CloseCode.NormalClosure;
      case ws_status.policyViolation:
        return CloseCode.PolicyViolation;
      case ws_status.protocolError:
        return CloseCode.ProtocolError;
      case ws_status.unsupportedData:
        return CloseCode.UnsupportedData;
      default:
        throw new Exception("unrecognized ws_status code");
    }
  }

  static int? _closeCodeToWsStatus(CloseCode? code) {
    switch (code) {
      case null:
        return null;
      case CloseCode.AbnormalClosure:
        return ws_status.abnormalClosure;
      case CloseCode.GoingAway:
        return ws_status.goingAway;
      case CloseCode.InternalServerError:
        return ws_status.internalServerError;
      case CloseCode.InvalidFramePayloadData:
        return ws_status.invalidFramePayloadData;
      case CloseCode.MessageTooBig:
        return ws_status.messageTooBig;
      case CloseCode.MissingMandatoryExtension:
        return ws_status.missingMandatoryExtension;
      case CloseCode.NoStatusReceived:
        return ws_status.noStatusReceived;
      case CloseCode.NormalClosure:
        return ws_status.normalClosure;
      case CloseCode.PolicyViolation:
        return ws_status.policyViolation;
      case CloseCode.ProtocolError:
        return ws_status.protocolError;
      case CloseCode.UnsupportedData:
        return ws_status.unsupportedData;
      default:
        throw new Exception("unrecognized CloseCode");
    }
  }

  Future<void> emit(dynamic message) async {
    this._channel.sink.add(message);
  }

  @override
  CloseReason? get closeReason {
    final closeCode = this._channel.closeCode;
    if (closeCode == null) return null;
    return CloseReason(
        code: WsConnection._wsStatusToCloseCode(closeCode),
        message: this._channel.closeReason);
  }
}

/*
 * TODO: research
 */
class WsListener extends AbstractListener<WsConnection> {
  final HttpServer _httpServer;
  Stream<WsConnection> get incomingConnections => this._connectionStream;
  Stream<WsConnection> _connectionStream;
  final InternetAddress address;
  final int port;
  final String path;
  WsListener(this._httpServer, this.address, this.port, {this.path = ""})
      : _connectionStream = _httpServer
            .asyncMap((request) async {
              if (/* request.uri.scheme == "ws" && */
                  request.uri.path == path &&
                      WebSocketTransformer.isUpgradeRequest(request)) {
                print("upgrading request to ws");
                var socket = await WebSocketTransformer.upgrade(request);
                return new WsConnection(
                  Uri.parse("shit"),
                  // TODO: make this cross platform
                  new ws_channel_io.IOWebSocketChannel(socket),
                );
              } else {
                print(
                    "invalid request found: ${request.uri.scheme}://${request.uri.host}:${request.uri.port}${request.uri.path}");
                request.response.statusCode = HttpStatus.badRequest;
                await request.response.close();
                return null;
              }
            })
            .where((ws) => ws != null)
            .map((ws) => ws!)
            // .isBroadcast
            // TODO: check if this is a broadcast stream as is
            .asBroadcastStream();
}
