import 'package:flutter/material.dart';
import 'package:flutter_polygon/flutter_polygon.dart';

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
}
