import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/provider.dart';
import 'package:honeycomb_test/models/service.dart';
import 'package:honeycomb_test/pages/list_details.dart';

class ResourceList {
  String listName = "";

  List<Provider> providerList = [];

  ResourceList({required this.listName, required this.providerList});

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
  Service testService1 = Service(
      serviceName: 'TestService1',
      serviceCategory: 'Shelter',
      hasMou: true,
      isVerified: true,
      serviceNumber: 'xxx-xxx-xxxx',
      serviceEmail: 'test_service@gmail.com',
      serviceAddress: '1234 Test Street, Seattle, WA',
      serviceProvider: "Mary's Place");

  Service testService2 = Service(
      serviceName: 'TestService2',
      serviceCategory: 'Legal',
      hasMou: false,
      isVerified: false,
      serviceNumber: 'xxx-xxx-xxxx',
      serviceEmail: 'test_service@gmail.com',
      serviceAddress: '1234 Test Street, Seattle, WA',
      serviceProvider: "Mary's Place");

  Service testService3 = Service(
      serviceName: 'TestService2',
      serviceCategory: 'Professional',
      hasMou: false,
      isVerified: false,
      serviceNumber: 'xxx-xxx-xxxx',
      serviceEmail: 'test_service@gmail.com',
      serviceAddress: '1234 Test Street, Seattle, WA',
      serviceProvider: "GIX");

  Service testService4 = Service(
      serviceName: 'TestService2',
      serviceCategory: 'Food',
      hasMou: false,
      isVerified: false,
      serviceNumber: 'xxx-xxx-xxxx',
      serviceEmail: 'test_service@gmail.com',
      serviceAddress: '1234 Test Street, Seattle, WA',
      serviceProvider: "Safeway");

  Provider marysPlace = Provider(
      providerName: "Mary's Place",
      providerEmail: 'test_service@gmail.com',
      providerAddress: '1234 Test Street, Seattle, WA',
      providerNumber: 'xxx-xxx-xxxx',
      providerReligion: 'none',
      serviceList: [testService1, testService2],
      hasMou: true);

  Provider gix = Provider(
      providerName: "GIX",
      providerEmail: 'test_service@gmail.com',
      providerAddress: '1234 Test Street, Seattle, WA',
      providerNumber: 'xxx-xxx-xxxx',
      providerReligion: 'none',
      serviceList: [testService3],
      hasMou: true);

  Provider safeway = Provider(
      providerName: "Safeway",
      providerEmail: 'test_service@gmail.com',
      providerAddress: '1234 Test Street, Seattle, WA',
      providerNumber: 'xxx-xxx-xxxx',
      providerReligion: 'none',
      serviceList: [testService4],
      hasMou: false);

  ResourceList ret = ResourceList(
      listName: "test list", providerList: [marysPlace, gix, safeway]);
  return ret;
}
