import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/model/resource.dart';
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

void serviceToContact(Resource resource, int index) async {
  final newContact = Contact()
    ..name.first = resource.name!
    ..addresses = [Address(resource.address!)]
    ..emails = [
      Email(resource.email!),
    ]
    ..phones = [Phone(resource.phoneNumbers!["primary"])];
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

Map<String, Map<String, bool>> filters = {
  "Categories": {
    "Shelter": false,
    "Domestic Violence": false,
    "Housing": false,
    "Food": false,
    "Medical": false,
    "Mental Health": false,
    "Clothing": false,
    "Education": false,
    "Translation": false,
    "Legal": false,
    "Employment": false,
  },
  "Requirements": {
    "None": false,
    "Women Only": false,
    "Minors Only": false,
    "Adult Only": false,
    "Family": false,
    "Individual": false
  },
  "Accessibility": {
    "Wheelchair": false,
    "Sign Language": false,
  },
  "Other Filters": {"Multilingual": false, "Active": false},
};

bool ifAnyFilters() {
  bool ret = false;
  filters.forEach((key, value) {
    value.forEach((key2, value2) {
      if (value2) {
        ret = true;
      }
    });
  });
  return ret;
}

void setFilter(String inKey, bool inVal) {
  filters.forEach((key, value) {
    if (value.containsKey(inKey)) {
      value[inKey] = inVal;
    }
  });
}

void resetFilters() {
  filters.forEach((key, value) {
    setFilter(key, false);
  });
}
