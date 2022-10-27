import 'dart:convert';
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

var category_filters = {
  "Shelter": false,
  "Domestic Violence": false,
  "Mental Health": false,
  "Food": false,
  "Medical Help": false,
  "Legal": false
};
var accessibility_filters = {
  "Shelter": false,
  "Domestic Violence": false,
  "Mental Health": false,
  "Food": false,
  "Medical Help": false,
  "Legal": false
};
var eligibility_filters = {
  "Women Only": false,
  "Minors Only": false,
  "Adult Only": false,
  "Family": false,
  "Individual": false
};

var misc_filters = {"Multilingual": false, "Active": false};

void resetFilters() {
  category_filters.forEach((key, value) {
    value = false;
  });
  accessibility_filters.forEach((key, value) {
    value = false;
  });
  eligibility_filters.forEach((key, value) {
    value = false;
  });
  misc_filters.forEach((key, value) {
    value = false;
  });
}

ResourceList applySearch(ResourceList inputList, String searchTerms) {
  ResourceList ret = ResourceList(listName: "Test Client", resources: []);

  const fillers = ["in", "near", "at", "close"];

  searchTerms = searchTerms.toLowerCase();
  var words = searchTerms.split(" ");
  words.removeWhere((element) => fillers.contains(element));

  for (Resource_Model resource in inputList.resources) {
    for (String word in words) {
      if (jsonEncode(resource).contains(word)) {
        ret.resources.add(resource);
      }
    }
  }

  return ret;
}

ResourceList applyFilters(ResourceList inputList) {
  ResourceList ret = ResourceList(listName: "Test Client", resources: []);
  bool add = false;
  for (Resource_Model resource in inputList.resources) {
    category_filters.forEach((filter, value) {
      if (value && resource.categories.contains(filter)) {
        add = true;
      }
    });
    accessibility_filters.forEach((filter, value) {
      if (value && resource.accessibility.contains(filter)) {
        add = true;
      }
    });
    eligibility_filters.forEach((filter, value) {
      if (value && resource.eligibility.contains(filter)) {
        add = true;
      }
    });
    if (misc_filters["Multilingual"] == true && resource.languages.length > 1) {
      add = true;
    }
    ;
    if (misc_filters["Active"] == true && resource.isActive) {
      add = true;
    }
    ;
    if (add) {
      ret.resources.add(resource);
    }
    print(resource.toString());
  }
  return ret;
}
