import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../pages/service_details.dart';
import '../utilities.dart';

class Resource_Model {
  //MAIN ATTRIBUTES
  String name = "";
  Map phoneNumbers = {"primary": ""};
  String email = "";
  String address = "";
  String zip_code = "";
  LatLng coords = LatLng(0.0, 0.0);
  String website = "";
  //LIST ATTRIBUTES
  List<String> categories = [];
  List<String> languages = [];
  List<String> eligibility = [];
  List<String> accessibility = [];
  //EXTRA ATTRIBUTES
  String notes = "";
  bool isActive = true;
  //SYSTEM ATTRIBUTES
  String createdBy = "";
  DateTime createdStamp = DateTime.now();
  String updatedBy = "";
  DateTime updatedStamp = DateTime.now();

  Resource_Model(
      name,
      phoneNumbers,
      email,
      address,
      zip_code,
      coords,
      website,
      categories,
      accessibility,
      languages,
      eligibility,
      notes,
      isActive,
      createdBy,
      createdStamp,
      updatedBy,
      updatedStamp) {
    this.name = name;
    this.phoneNumbers = phoneNumbers;
    this.email = email;
    this.address = address;
    this.zip_code = zip_code;
    this.coords = coords;
    this.website = website;
    this.categories = categories;
    this.accessibility = accessibility;
    this.languages = languages;
    this.notes = notes;
    this.isActive = isActive;
    this.createdBy = createdBy;
    this.createdStamp = createdStamp;
    this.updatedBy = updatedBy;
    this.updatedStamp = updatedStamp;
  }

  Map toJson() => {
        'name': name,
        'numbers': phoneNumbers.toString(),
        'email': email,
        'address': address,
        'zip': zip_code,
        'web': website,
        'categories': categories,
        'languages': languages,
        'eligibility': eligibility,
        'accessibility': accessibility,
        'notes': notes,
        'activity': isActive ? "active" : "inactive",
      };

  Widget showRecency(BuildContext context) {
    int diff = updatedStamp.difference(DateTime.now()).inDays;
    Color recencyColor;

    if (diff < 14) {
      recencyColor = Colors.greenAccent;
    } else if ((diff > 14) && (diff < 30)) {
      recencyColor = Colors.orangeAccent;
    } else {
      recencyColor = Colors.redAccent;
    }

    return Chip(
      labelPadding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      visualDensity: VisualDensity.compact,
      backgroundColor: recencyColor,
      label: Text(
        "$diff days",
      ),
    );
  }

  Widget cardCategoryLabel(BuildContext context, String category) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: Chip(
        labelPadding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        labelStyle: Theme.of(context).textTheme.labelSmall,
        visualDensity: VisualDensity.compact,
        label: Text(
          category,
        ),
      ),
    );
  }

  Widget detailsCategoryLabel(BuildContext context, String category) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Chip(
        label: Text(category),
      ),
    );

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(8)),
      child: Text(category, style: Theme.of(context).textTheme.labelLarge),
    );
  }

  Widget getServiceCard(BuildContext context, String currentPage) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServiceDetails(
                    previousPage: currentPage,
                    resource: this,
                  )),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (String category in categories)
                        cardCategoryLabel(context, category)
                    ],
                  ),
                  getSpacer(4),
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 20),
                      ),
                      getSpacer(4),
                      showRecency(context)
                    ],
                  )
                ],
              ),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.chevron_right_sharp))
            ],
          ),
        ),
      ),
    );
  }
}
