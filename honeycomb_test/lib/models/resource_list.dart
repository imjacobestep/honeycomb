import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_model.dart';
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
  //RESOURCE 1
  Resource_Model testService1 = Resource_Model(
    name: 'Allen Family Center',
  );
  testService1.enrich(
      {"primary": "012-345-6789"},
      "test_service@gmail.com",
      "1234 Test Street, Seattle, WA",
      "98005",
      "honeycomb.com",
      ["Shelter", "Legal"],
      ["English"],
      ["Families"],
      ["Wheelchair-accessible"],
      "Template notes to show what an Outreach Specialist might write");

  //RESOURCE 1
  Resource_Model testService2 = Resource_Model(
    name: "Mary's Place Regrade",
  );
  testService2.enrich(
      {"primary": "012-345-6789"},
      "test_service@gmail.com",
      "1234 Test Street, Seattle, WA",
      "98005",
      "honeycomb.com",
      ["Food", "Legal"],
      ["English"],
      ["Families"],
      ["Wheelchair-accessible"],
      "Template notes to show what an Outreach Specialist might write");

  //RESOURCE 3
  Resource_Model testService3 = Resource_Model(
    name: "Mary's Place Burien",
  );
  testService3.enrich(
      {"primary": "012-345-6789"},
      "test_service@gmail.com",
      "1234 Test Street, Seattle, WA",
      "98005",
      "honeycomb.com",
      ["Food", "Legal"],
      ["English"],
      ["Families"],
      ["Wheelchair-accessible"],
      "Template notes to show what an Outreach Specialist might write");

  //RESOURCE 4
  Resource_Model testService4 = Resource_Model(
    name: "Mary's Place Bellevue",
  );
  testService4.enrich(
      {"primary": "012-345-6789"},
      "test_service@gmail.com",
      "1234 Test Street, Seattle, WA",
      "98005",
      "honeycomb.com",
      ["Food", "Legal"],
      ["English"],
      ["Families"],
      ["Wheelchair-accessible"],
      "Template notes to show what an Outreach Specialist might write");

  ResourceList ret = ResourceList(
      listName: "Test Client",
      resources: [testService1, testService2, testService3, testService4]);
  return ret;
}
