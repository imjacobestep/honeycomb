import 'package:flutter/material.dart';
import 'package:honeycomb_test/utilities.dart';

class Service {
  String serviceName = "";
  String serviceCategory = "";
  String serviceNumber = "";
  String serviceEmail = "";
  String serviceAddress = "";
  String servicePopulation = "";
  String serviceStatus = "";
  bool hasMou = false;
  bool isVerified = false;

  Service(
      {required this.serviceName,
      required this.serviceCategory,
      required this.hasMou,
      required this.isVerified});

  Widget showMou() {
    return hasMou
        ? Container(
            child: Text(
              "MOU",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
            ),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4)),
          )
        : Container();
  }

  Widget showVerified() {
    return isVerified
        ? Container(
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.yellow),
            child: Icon(Icons.check_sharp),
          )
        : Container();
  }

  Widget categoryLabel() {
    return Container(
      child: Text(
        serviceCategory,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
      ),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget getCard() {
    return Card(
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(8),
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
                        this.serviceName,
                        style: TextStyle(fontSize: 20),
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
