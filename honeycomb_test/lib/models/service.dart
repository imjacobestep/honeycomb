import 'package:flutter/material.dart';
import 'package:flutter_polygon/flutter_polygon.dart';
import 'package:honeycomb_test/pages/service_details.dart';
import 'package:honeycomb_test/utilities.dart';

class Service {
  String serviceName = "";
  String serviceCategory = "";
  String serviceNumber = "";
  String serviceEmail = "";
  String serviceAddress = "";
  String servicePopulation = "";
  String serviceStatus = "";
  String serviceProvider = "";
  bool hasMou = false;
  bool isVerified = false;

  Service({
    required this.serviceName,
    required this.serviceCategory,
    required this.hasMou,
    required this.isVerified,
    required this.serviceNumber,
    required this.serviceEmail,
    required this.serviceAddress,
    required this.serviceProvider,
  });

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

  Widget showVerified() {
    return isVerified
        ? Container(
            padding: const EdgeInsets.all(2),
            decoration: const ShapeDecoration(
              color: Colors.orange,
              shape: PolygonBorder(sides: 6),
            ),
            child: const Icon(
              Icons.check_sharp,
              color: Colors.white,
              size: 20,
            ),
          )
        : Container();
  }

  Widget categoryLabel() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(4)),
      child: Text(
        serviceCategory,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget getCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServiceDetails(
                    service: this,
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
                    children: [categoryLabel(), getSpacer(4), showMou()],
                  ),
                  getSpacer(4),
                  Row(
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(fontSize: 20),
                      ),
                      getSpacer(4),
                      showVerified()
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
