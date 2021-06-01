import 'dart:collection';

import 'package:appia/blocs/p2p/connection_bloc.dart';
import 'package:appia/p2p/p2p.dart';

class P2PBloc {
  // void Function(Object) onSocketError;
  final P2PNode node;
  // FIXME: storing Blocs outside Flutter tree context
  // WAIIT a minute...having multiple blocs of the same type around doesn't sound right
  // I don't want to write another connection layer to handle reconnection goddamit
  // Yeah, we'll have to resort to this. Until we come up with something better...
  final Map<String, ConnectionBloc> connections = new HashMap();
  late final Stream<ConnectionBloc> incomingConnectionBlocs;

  P2PBloc(
    this.node,
  ) {
    this.incomingConnectionBlocs = this.node.incomingConnections.map(
      (conn) {
        final bloc = new ConnectionBloc(conn.connection);
        this.connections[conn.id] = new ConnectionBloc(conn.connection);
        return bloc;
      },
    );
    this.node.incomingConnections.listen(this._addConnection);
  }

  // factory ConnectionBloc.connect() => ConnectionBloc()..add(Connect());

  void _addConnection(AppiaConnection connection) {
    this.connections[connection.id] = new ConnectionBloc(connection.connection);
  }

  Future<void> close() async {
    await this.node.close();
  }
}
