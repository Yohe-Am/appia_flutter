import 'package:appia/models/room_entry.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'room.g.dart';

enum RoomType { personalChat }

@JsonSerializable()
class Room {
  final List<User> users;
  final RoomType type;
  final List<RoomEntry> entries;

  const Room(this.type, this.users, this.entries);

  Map<String, dynamic> toJson() {
    return _$RoomToJson(this);
  }

  static Room fromJson(Map<String, dynamic> json) {
    return _$RoomFromJson(json);
  }
}
