import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/models_old/resource_model.dart';
import 'package:honeycomb_test/pages/list_details.dart';

class ResourceList {
  String listName = "";

  //List<Provider> providerList = [];
  List<Resource_Model> resources = [];

  ResourceList({required this.listName, required this.resources});

  Widget getCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListDetails(
                      resourceList: this,
                    ))),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                listName,
                style: const TextStyle(fontSize: 20),
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

ResourceList buildTest() {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  //RESOURCE 1
  Resource_Model testService1 = Resource_Model(
      'Allen Family Center',
      {"primary": "012-345-6789"},
      "test_service@gmail.com",
      "1234 Test Street, Seattle, WA",
      "98005",
      LatLng(47.621527688800188, -122.17470223058742),
      "honeycomb.com",
      ["Shelter", "Clothing"],
      ["English"],
      ["Families"],
      ["Wheelchair-accessible"],
      "Template notes to show what an Outreach Specialist might write",
      true,
      userEmail ?? "user",
      DateTime.now(),
      userEmail ?? "user",
      DateTime.now());

  //RESOURCE 2
  Resource_Model testService2 = Resource_Model(
      "Mary's Place Regrade",
      {"primary": "012-345-6789"},
      "test_service@gmail.com",
      "1234 Test Street, Seattle, WA",
      "98005",
      LatLng(47.621527688800182, -122.17870223058742),
      "honeycomb.com",
      ["Shelter", "Clothing"],
      ["English"],
      ["Families"],
      ["Wheelchair-accessible"],
      "Template notes to show what an Outreach Specialist might write",
      true,
      userEmail ?? "user",
      DateTime.now(),
      userEmail ?? "user",
      DateTime.now());

  //RESOURCE 3
  Resource_Model testService3 = Resource_Model(
      "Mary's Place Burien",
      {"primary": "012-345-6789"},
      "test_service@gmail.com",
      "1234 Test Street, Seattle, WA",
      "98005",
      LatLng(47.621027688800186, -122.17670223058740),
      "honeycomb.com",
      ["Shelter", "Clothing"],
      ["English"],
      ["Families"],
      ["Wheelchair-accessible"],
      "Template notes to show what an Outreach Specialist might write",
      true,
      userEmail ?? "user",
      DateTime.now(),
      userEmail ?? "user",
      DateTime.now());

  //RESOURCE 4
  Resource_Model testService4 = Resource_Model(
      "Mary's Place Bellevue",
      {"primary": "012-345-6789"},
      "test_service@gmail.com",
      "1234 Test Street, Seattle, WA",
      "98005",
      LatLng(47.62184778890019, -122.176702255875),
      "honeycomb.com",
      ["Shelter", "Clothing"],
      ["English"],
      ["Families"],
      ["Wheelchair-accessible"],
      "Template notes to show what an Outreach Specialist might write",
      true,
      userEmail ?? "user",
      DateTime.now(),
      userEmail ?? "user",
      DateTime.now());

  ResourceList ret = ResourceList(
      listName: "Test Client",
      resources: [testService1, testService2, testService3, testService4]);
  return ret;
}
