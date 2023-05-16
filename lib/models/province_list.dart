import './province.dart';

class ProvinceList {
  List<Province> data;

  ProvinceList({this.data});

  ProvinceList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Province>[];
      json['data'].forEach((v) {
        data.add(Province.fromJson(v));
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
