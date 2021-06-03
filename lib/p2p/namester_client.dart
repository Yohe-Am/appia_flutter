import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:namester/namester.dart';

/// Interface for interacting with a name server
abstract class AbstractNamester {
  /// Returns null if id not recognized
  Future<PeerAddress?> getAddressForId(String id);

  /// Returns null if username not recognized
  Future<PeerAddress?> getAddressForUsername(String username);
  Future<void> updateMyAddress(String id, String username, PeerAddress address);
}

/// Returns null if id not recognized
/// Interface for nameserver that's on an REST API elsewhere
class HttpNamesterProxy extends AbstractNamester {
  final Client _client;

  Uri _nameserverAddress;

  HttpNamesterProxy(this._nameserverAddress) : _client = new Client();

  Future<PeerAddress?> getAddressForId(String id) async {
    try {
      final response = await _client.post(
        _nameserverAddress.resolve("/get-peer-address"),
        body: '{ "id":"${id.toString()}" }',
      );
      switch (response.statusCode) {
        case HttpStatus.ok:
          final entry = UserEntry.fromJson(jsonDecode(response.body));
          return entry.address;
        case HttpStatus.notFound:
          return null;
        default:
          throw Exception(
              "nameserver response not recognized: ${response.toString()}");
      }
    } catch (e) {
      throw Exception("error talking with nameserver: ${e.toString()}");
    }
  }

  @override
  Future<PeerAddress?> getAddressForUsername(String username) async {
    try {
      final response = await _client.post(
        _nameserverAddress.resolve("/get-peer-address"),
        body: '{ "username":"$username" }',
      );
      switch (response.statusCode) {
        case HttpStatus.ok:
          final entry = UserEntry.fromJson(jsonDecode(response.body));
          return entry.address;
        case HttpStatus.notFound:
          return null;
        default:
          throw Exception(
              "nameserver response not recognized: ${response.toString()}");
      }
    } catch (e) {
      throw Exception("error talking with nameserver: ${e.toString()}");
    }
  }

  @override
  Future<void> updateMyAddress(
      String id, String username, PeerAddress address) async {
    try {
      final response = await _client.put(
        _nameserverAddress.resolve("/put-peer-address"),
        body: UserEntry(username, id.toString(), address).toJson(),
      );
      switch (response.statusCode) {
        case HttpStatus.created:
          return;
        default:
          throw Exception(
              "nameserver response not recognized: ${response.toString()}");
      }
    } catch (e) {
      throw Exception("error talking with nameserver: ${e.toString()}");
    }
  }
}

/// Namester that always returns the same peerAddress
class DumbNamester extends AbstractNamester {
  final PeerAddress universalAddress;

  DumbNamester(this.universalAddress);
  @override
  Future<PeerAddress?> getAddressForId(String id) async {
    return this.universalAddress;
  }

  @override
  Future<void> updateMyAddress(
      String id, String username, PeerAddress address) async {
    throw UnimplementedError();
  }

  @override
  Future<PeerAddress?> getAddressForUsername(String username) async {
    return this.universalAddress;
  }
}
