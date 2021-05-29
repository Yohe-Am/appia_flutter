// Yohe: I just copied the client we used from offTime and made it null-safe. Lot's of work left to be done

import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart' as ws_channel;
import 'package:web_socket_channel/io.dart' as ws_channel_io;
import 'package:web_socket_channel/status.dart' as ws_status;

import 'transports.dart';

class WsListeningAddress extends ListeningAddress {
  final InternetAddress host;
  final int port;
  final String path;
  const WsListeningAddress(
    this.host,
    this.port, [
    this.path = "/",
  ]) : super(TransportType.WebSockets);
  @override
  String toString() => "WsListeningAddress(${host.toString()}:$port$path)";
}

class WsPeerAddress extends PeerAddress {
  final Uri uri;
  WsPeerAddress(this.uri) : super(TransportType.WebSockets);
  @override
  String toString() => "WsPeerAddress(${uri.toString()})";
}

class WsNotConnectedException extends NotConnectedException {}

class WsTransport extends AbstractTransport<WsListener, WsConnection> {
  @override
  TransportType get type => TransportType.WebSockets;

  Future<WsConnection> dial(PeerAddress address) async {
    if (address is WsPeerAddress) {
      // TODO: make connect call async
      final channel = ws_channel.WebSocketChannel.connect(
        address.uri,
        protocols: ["appia"],
      );
      return WsConnection(address, channel);
    } else {
      throw Exception(
          "invalid transport type for websocket transport: ${address.transportType}");
    }
  }

  Future<WsListener> listen(ListeningAddress? listeningAddress) async {
    if (listeningAddress is WsListeningAddress) {
      var server = await HttpServer.bind(
        listeningAddress.host,
        listeningAddress.port,
      );
      return WsListener(server, listeningAddress);
    } else {
      throw Exception(
          "invalid transport type for websocket transport: ${listeningAddress?.transportType}");
    }
  }
}

/* 
 * WsConnection with event based interface.
 * 
 * */
class WsConnection extends AbstractConnection {
  @override
  TransportType get type => TransportType.WebSockets;

  bool _connected = true;
  ws_channel.WebSocketChannel _channel;
  late Stream<dynamic> _streamAsBrodacast;

  final WsPeerAddress peerAddress;

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
    final channel = ws_channel.WebSocketChannel.connect(this.peerAddress.uri);
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

class WsListener extends AbstractListener<WsConnection> {
  @override
  TransportType get type => TransportType.WebSockets;

  final HttpServer _httpServer;
  Stream<WsConnection> get incomingConnections => this._connectionStream;
  Stream<WsConnection> _connectionStream;

  @override
  // TODO: implement listeningAddress
  final WsListeningAddress listeningAddress;

  WsListener(this._httpServer, this.listeningAddress)
      : _connectionStream = _httpServer
            .asyncMap((request) async {
              if (/* request.uri.scheme == "ws" && */
                  request.uri.path == listeningAddress.path &&
                      WebSocketTransformer.isUpgradeRequest(request)) {
                print("upgrading request to ws");
                // FIXME: yeah, we should add more to the handshake
                final connInfo = request.connectionInfo!;

                // we shan't use the stream version of the transformer
                // we won't be
                // TODO: make use of WebSocket's protocol feature?
                var socket = await WebSocketTransformer.upgrade(request);
                final peerAddress = new WsPeerAddress(
                  new Uri(
                    host: connInfo.remoteAddress.host,
                    port: connInfo.remotePort,
                  ),
                );
                return new WsConnection(
                  peerAddress,
                  new ws_channel_io.IOWebSocketChannel(socket),
                );
              } else {
                // print(
                //   "invalid request found: ${request.uri.scheme}://${request.uri.host}:${request.uri.port}${request.uri.path}",
                // );
                print(
                  "invalid request found: ${request.uri.toString()}",
                );
                request.response.statusCode = HttpStatus.badRequest;
                await request.response.close();
                return null;
              }
            })
            // filter out the failed upgrades
            // i miss rust
            .where((ws) => ws != null)
            .map((ws) => ws!)
            // .isBroadcast
            // TODO: check if this is a broadcast stream as is
            .asBroadcastStream();

  @override
  void close() {
    this._httpServer.close();
  }
}
