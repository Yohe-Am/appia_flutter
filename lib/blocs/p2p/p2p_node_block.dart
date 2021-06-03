import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:appia/blocs/p2p/connection_bloc.dart';
import 'package:appia/p2p/p2p.dart';

// -- EVENTS

abstract class NodeEvent {}

/* class ConnectToNode extends NodeEvent {
  final AppiaId address;
  ConnectToNode(this.address);
}
 */

// FIXME: this shouldn't be a bloc
// a data provider maybe?

// -- STATE

enum NodeState { Initial }

// -- BLOC

class P2PBloc extends Bloc<NodeEvent, NodeState> {
  // void Function(Object) onSocketError;
  final P2PNode node;
  // FIXME: storing Blocs outside Flutter tree context
  // WAIIT a minute...having multiple blocs of the same type around doesn't sound right
  // I don't want to write another connection layer to handle reconnection goddamit
  // Yeah, we'll have to resort to this. Until we come up with something better...
  final Map<AppiaId, ConnectionBloc> connections = new HashMap();
  late final Stream<ConnectionBloc> incomingConnectionBlocs;

  P2PBloc(
    this.node,
  ) : super(NodeState.Initial) {
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

  @override
  Stream<NodeState> mapEventToState(NodeEvent event) async* {}

  @override
  Future<void> close() async {
    await this.node.close();
    await super.close();
  }
}
