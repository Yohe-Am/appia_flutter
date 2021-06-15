import 'dart:collection';

import 'package:appia/models/models.dart';

// FIXME: the interface sucs
class RoomRepository {
  Map<String, Room> _rooms = new HashMap();
  Map<String, List<RoomEntry>> _roomsEntries = new HashMap();

  Future<Room?> getRoom(String roomId) async {
    return _rooms[roomId];
  }

  Future<void> setRoom(String roomId, Room room) async {}

  Future<List<RoomEntry>?> getRoomEntries(String roomId) async {
    return _roomsEntries[roomId];
  }

  Future<void> setRoomEntries(String roomId, List<RoomEntry> entries) async {
    if (!_rooms.containsKey(roomId)) throw Exception("No such room found bich");
    _roomsEntries[roomId] = entries;
  }
}
