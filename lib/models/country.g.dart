// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json, [Country instance]) {
  return instance ?? Country()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..iso = json['iso'] as String
    ..iso3 = json['iso3'] as String
    ..currency = json['currency'] as String
    ..states = (json['states'] as List)
        ?.map(
            (e) => e == null ? null : Province.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iso': instance.iso,
      'iso3': instance.iso3,
      'currency': instance.currency,
      'states': instance.states,
    };
