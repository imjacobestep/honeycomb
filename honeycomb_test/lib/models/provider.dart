import 'package:honeycomb_test/models/service.dart';

class Provider {
  String providerName = "";
  String providerNumber = "";
  String providerEmail = "";
  String providerAddress = "";
  String providerReligion = "";

  List<Service> serviceList = [];

  Provider({
    required this.providerName,
    required this.providerEmail,
  });
}
