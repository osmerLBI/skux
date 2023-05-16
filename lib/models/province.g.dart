// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'province.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Province _$ProvinceFromJson(Map<String, dynamic> json, [Province instance]) {
  return instance ?? Province()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..abbr = json['abbr'] as String
    ..abbr3 = json['abbr3'] as String;
}

Map<String, dynamic> _$ProvinceToJson(Province instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'abbr': instance.abbr,
      'abbr3': instance.abbr3,
    };
