import 'package:json_annotation/json_annotation.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/models/country.dart';
import 'package:span_mobile/models/province.dart';

part 'platform.g.dart';

@JsonSerializable()
class PlatformModel {
  static PlatformModel global = PlatformModel();

  int id;
  String name;
  List<Country> countries;

  PlatformModel() {
    name = platform.name();
    if (Platform.TRANSFER_MEX) {
      countries = [
        Country.fromJson({
          'name': 'Mexico',
          'iso': 'MX',
          'iso3': 'MEX',
          'currency': 'MXN',
        }),
        Country.fromJson({
          'name': 'United States',
          'iso': 'US',
          'iso3': 'USA',
          'currency': 'USD',
        }),
      ];
    } else {
      countries = [];
    }
  }

  factory PlatformModel.fromJson(Map<String, dynamic> json) =>
      _$PlatformModelFromJson(json);

  PlatformModel updateByJson(Map<String, dynamic> json) {
    return _$PlatformModelFromJson(json, this);
  }

  Map<String, dynamic> toJson() => _$PlatformModelToJson(this);

  Country countryBy({String iso, String iso3, int id}) {
    if (id != null) {
      return countries.firstWhere(
        (Country c) => c.id == id,
        orElse: () => null,
      );
    }
    if (iso != null) {
      return countries.firstWhere(
        (Country c) => c.iso == iso,
        orElse: () => null,
      );
    }
    if (iso3 != null) {
      return countries.firstWhere(
        (Country c) => c.iso3 == iso3,
        orElse: () => null,
      );
    }
    return null;
  }

  Province provinceBy({int id}) {
    for (Country c in countries) {
      if (c.states == null) {
        continue;
      }
      for (Province s in c.states) {
        if (id != null && s.id == id) {
          return s;
        }
      }
    }
    return null;
  }

  List<String> countryFields({field = 'iso'}) {
    return countries.map<String>((Country c) {
      if (field == 'iso') {
        return c.iso;
      }
      if (field == 'iso3') {
        return c.iso3;
      }
      if (field == 'currency') {
        return c.currency;
      }
      return c.name;
    }).toList();
  }
}
