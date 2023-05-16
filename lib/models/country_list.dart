import 'country.dart';

class CountryList {
  List<Country> data;

  CountryList({this.data});

  CountryList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Country>[];
      json['data'].forEach((v) {
        data.add(Country.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
