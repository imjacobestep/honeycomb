import 'package:flutter/material.dart';
import 'package:flutter_polygon/flutter_polygon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../pages/service_details.dart';
import '../utilities.dart';

class Resource_Model {
  /*String serviceName = "";
  String serviceCategory = "";
  String serviceNumber = "";
  String serviceEmail = "";
  String serviceAddress = "";
  String servicePopulation = "";
  String serviceStatus = "";
  String serviceProvider = "";
  bool hasMou = false;
  bool isVerified = false;*/
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

  Resource_Model({required this.name});

  void enrich(
    Map pN,
    String e,
    String a,
    String zC,
    String w,
    List<String> c,
    List<String> l,
    List<String> eG,
    List<String> aC,
    String n,
  ) {
    phoneNumbers = pN;
    email = e;
    address = a;
    zip_code = zC;
    website = w;
    categories = c;
    languages = l;
    eligibility = eG;
    accessibility = aC;
    notes = n;
  }

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

    return Container(
        padding: const EdgeInsets.all(2),
        decoration: const ShapeDecoration(
          color: Colors.orange,
          shape: PolygonBorder(sides: 6),
        ),
        child: Text("$diff days ago"));
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
