// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) {
  return $checkedNew('Room', json, () {
    final val = Room(
      $checkedConvert(json, 'type', (v) => _$enumDecode(_$RoomTypeEnumMap, v)),
      $checkedConvert(
          json,
          'users',
          (v) => (v as List<dynamic>)
              .map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList()),
      $checkedConvert(
          json,
          'entries',
          (v) => (v as List<dynamic>)
              .map((e) => RoomEntry.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'users': instance.users,
      'type': _$RoomTypeEnumMap[instance.type],
      'entries': instance.entries,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$RoomTypeEnumMap = {
  RoomType.personalChat: 'personalChat',
};
