import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/service.dart';
import 'package:honeycomb_test/pages/provider_details.dart';
import 'package:honeycomb_test/utilities.dart';

import '../pages/service_details.dart';

class Provider {
  String providerName = "";
  String providerNumber = "";
  String providerEmail = "";
  String providerAddress = "";
  String providerReligion = "none";
  bool hasMou = false;

  List<Service> serviceList = [];

  Provider(
      {required this.providerName,
      required this.providerEmail,
      required this.providerNumber,
      required this.providerAddress,
      required this.providerReligion,
      required this.serviceList,
      required this.hasMou});

  Widget showMou() {
    return hasMou
        ? Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4)),
            child: const Text(
              "MOU",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
            ),
          )
        : Container();
  }

  Widget getCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProviderDetails(
                    provider: this,
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
                  showMou(),
                  getSpacer(4),
                  Row(
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(fontSize: 20),
                      ),
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

  Widget getServiceCard(BuildContext context, int index, String currentPage) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServiceDetails(
                    provider: this,
                    serviceIndex: index,
                    previousPage: currentPage,
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
                      serviceList[index].categoryLabel(),
                      getSpacer(4),
                      showMou()
                    ],
                  ),
                  getSpacer(4),
                  Row(
                    children: [
                      Text(
                        serviceList[index].serviceName,
                        style: const TextStyle(fontSize: 20),
                      ),
                      getSpacer(4),
                      serviceList[index].showVerified()
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
