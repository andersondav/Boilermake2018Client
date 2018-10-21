import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dart:convert';

const MAPS_API_KEY = 'AIzaSyDx51vyR0IGRSrrtD9FVS6HVQOLWeRzGQ0';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

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

Future<FirebaseUser> handleSignIn() async {
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  print("signed in " + user.displayName);
  return user;
}
