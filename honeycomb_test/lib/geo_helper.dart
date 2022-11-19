import 'dart:convert';
import "package:honeycomb_test/secrets.dart";
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class GeoHelper {
  final apiKey = hcMapsKey;

  GeoHelper();

  Future<String> parseZipCode(String zipCode) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$zipCode&key=$apiKey');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      final formattedAddress = data['results'].first['formatted_address'];

      return formattedAddress;
    } catch (e) {
      // print(e);
      return '';
    }
  }

  Future<String> parseLatLong(double lat, double long) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$apiKey');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      final formattedAddress = data['results'].first['formatted_address'];

      return formattedAddress;
    } catch (e) {
      // print(e);
      return '';
    }
  }

  Future<Map> parseAddress(String address, String zipCode) async {
    try {
      final suffix = await parseZipCode(zipCode);

      final fullAddress = '$address, $suffix';

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$fullAddress&key=$apiKey');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      return data['results'].first['geometry']['location'];
    } catch (e) {
      // print(e);
      return {};
    }
  }
}
