import 'package:json_annotation/json_annotation.dart';

part 'province.g.dart';

@JsonSerializable()
class Province {
  int id;
  String name;
  String abbr;
  String abbr3;

  Province();

  factory Province.fromJson(Map<String, dynamic> json) =>
      _$ProvinceFromJson(json);

  Province updateByJson(Map<String, dynamic> json) {
    return _$ProvinceFromJson(json, this);
  }

  Map<String, dynamic> toJson() => _$ProvinceToJson(this);
}
