import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindPlaceData {
  String mainText, description;
  String placeId;
  double lat = 0, lng = 0;


  String get getDescription {
    List<String> data = description.split(', ').reversed.toList();
    if (description.isEmpty && mainText.isEmpty) return '';
    if (data.first.toUpperCase() == 'JAPAN') data[0] = '日本';
    return data.join("");
  }

  setDescription(String data) {
    description = '';
    List<String> _data =
        data.split(', ').skipWhile((e) => !e.contains('</span>')).toList();
    _data = [
      for (var i in _data)
        ...i.split('<span ')
            .skip(1)
            .skipWhile((e) => e.contains("country-name") || e.contains("postal-code"))
            .map((e) => e.replaceAll('</span>', '')),
    ];
    _data = [
      ..._data.where((e) => e.contains('street-address')),
      ..._data.where((e) => e.contains('extended-address')),
      ..._data.where((e) => e.contains('locality')),
      ..._data.where((e) => e.contains('region')),
    ].map((e) => e.split('>').last).toList();
    description = _data.join(', ');
  }

  toNew() => new FindPlaceData(
      mainText: mainText, description: description, placeId: placeId, lat: lat, lng: lng);

  toLatLng() => LatLng(lat, lng);

  FindPlaceData(
      {this.mainText = '',
      this.description = '',
      this.placeId = '',
      this.lat = 0,
      this.lng = 0});
}
