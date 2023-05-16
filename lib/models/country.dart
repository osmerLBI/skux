import 'package:json_annotation/json_annotation.dart';
import 'package:span_mobile/models/province.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  int id;
  String name;
  String iso;
  String iso3;
  String currency;
  List<Province> states = [];

  Country();

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);

  Country updateByJson(Map<String, dynamic> json) {
    return _$CountryFromJson(json, this);
  }

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
