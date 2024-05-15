import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';



// Replace with your chosen geocoding API logic
Future<LatLng?> searchLocation(String query) async {
  // Example using Nominatim (free, public geocoding API)
  const nominatimBaseUrl = "AIzaSyC-DKsnyxHrf5weat6g2vYmbWtuHe1ZcU8import";
  //AIzaSyC-DKsnyxHrf5weat6g2vYmbWtuHe1ZcU8import
  final url = Uri.parse("$nominatimBaseUrl?q=$query&format=json");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data["lat"] != null && data["lon"] != null) {
      return LatLng(double.parse(data["lat"]), double.parse(data["lon"]));
    }
  }

  return null;
}
