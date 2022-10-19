import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/models/resource_list.dart';
import 'package:honeycomb_test/models/resource_model.dart';
import 'package:share_plus/share_plus.dart';

Widget getSpacer(double size) {
  return SizedBox(
    width: size,
    height: size,
  );
}

void shareContact(String contact) {
  Share.share(contact);
}

Future<CameraPosition> getCamera(String address) async {
  GeoData locData = await Geocoder2.getDataFromAddress(
      address: address,
      googleMapApiKey: "AIzaSyC1hEwGPXOck5HeY0ziBFtNGZ7GJGa5HAs");

  CameraPosition ret = CameraPosition(
    //target: LatLng(47.621527688800185, -122.17670223058742),
    target: LatLng(locData.latitude, locData.longitude),
    zoom: 17.4746,
  );

  return ret;
}

void serviceToContact(Resource_Model resource, int index) async {
  final newContact = Contact()
    ..name.first = resource.name
    ..addresses = [Address(resource.address)]
    ..emails = [
      Email(resource.email),
    ]
    ..phones = [Phone(resource.phoneNumbers["primary"])];
  await newContact.insert();

  String filename = "${resource.name}.vcf";

  var file = File(filename);
  await file.writeAsString(newContact.toVCard(includeDate: true));

  await Share.shareXFiles([XFile(file.path)]);
}

Widget sectionHeader(String header, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8.0, 8, 0, 0),
    child: Text(
      header,
      style: Theme.of(context).textTheme.titleMedium,
    ),
  );
}

Widget filterCard(IconData icon, String label) {
  return Card(
    child: InkWell(
      onTap: () {
        all_filters[label] = !all_filters[label]!;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon),
            getSpacer(10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget getDivider(BuildContext context) {
  return const Divider(
    height: 4,
    thickness: 2,
    indent: 8,
    endIndent: 8,
  );
}

List<String> all_categories = [
  "Food",
  "Shelter",
  "Mental Health",
  "Medical",
  "Legal",
  "Immigration",
  "Domestic Violence"
];

var all_filters = {
  "Shelter": false,
  "Domestic Violence": false,
  "Mental Health": false,
  "Food": false,
  "Medical Help": false,
  "Legal": false
};

//ResourceList mainList = ResourceList(listName: "mainList", resources: resources)

ResourceList applyFilters(ResourceList inputList) {
  ResourceList ret = ResourceList(listName: "Test Client", resources: []);
  for (Resource_Model resource in inputList.resources) {
    if ((all_filters["Shelter"] == true) &&
        resource.categories.contains("Shelter")) {
      ret.resources.add(resource);
    }
  }
  return ret;
}
