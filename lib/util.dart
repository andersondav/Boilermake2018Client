import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

const MAPS_API_KEY = 'AIzaSyDx51vyR0IGRSrrtD9FVS6HVQOLWeRzGQ0';

class LocationData {
  LocationData({this.loc, this.name});

  LatLng loc;
  String name;
}

Future<LocationData> dataFromPlaceID(String placeID) async {
  // get the lat+long of p
  var response = await http.get(
      'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$MAPS_API_KEY');
  var json = jsonDecode(response.body);

  var result = json["result"];
  var location = result["geometry"]["location"];
  var lat = location["lat"];
  var long = location["lng"];

  return LocationData(
      loc: LatLng(lat, long), name: result["formatted_address"]);
}
