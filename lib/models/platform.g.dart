// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformModel _$PlatformModelFromJson(Map<String, dynamic> json, [PlatformModel instance]) {
  return instance ?? PlatformModel()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..countries = (json['countries'] as List)
        ?.map((e) =>
            e == null ? null : Country.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$PlatformModelToJson(PlatformModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'countries': instance.countries,
    };
