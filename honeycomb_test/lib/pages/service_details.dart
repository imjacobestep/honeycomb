import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/service.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetails extends StatefulWidget {
  @override
  ServiceDetailsState createState() => ServiceDetailsState();
  Service service;

  ServiceDetails({required this.service});
}

class ServiceDetailsState extends State<ServiceDetails> {
  @override
  void initState() {
    super.initState();
  }

  Widget getProvider() {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "provider",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  Row(
                    children: [
                      getSpacer(8),
                      Text(
                        widget.service.serviceProvider,
                        style: Theme.of(context).textTheme.bodyText1,
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

  Widget getAction(String label, String value) {
    switch (label) {
      case "number":
        {
          return IconButton(
              onPressed: () {
                launchUrl(Uri(
                  scheme: 'tel',
                  path: value,
                ));
              },
              icon: Icon(Icons.call_outlined));
        }
        break;

      case "email":
        {
          return IconButton(
              onPressed: () {
                launchUrl(Uri(
                  scheme: 'mailto',
                  path: value,
                ));
              },
              icon: Icon(Icons.mail_outlined));
        }
        break;

      case "address":
        {
          return IconButton(
              onPressed: () {
                launchUrl(Uri.parse(
                    "https://maps.google.com?q=${widget.service.serviceAddress.replaceAll(RegExp(" "), "+")}"));
              },
              icon: Icon(Icons.map_outlined));
        }
        break;

      default:
        {
          return Container();
        }
        break;
    }
  }

  Widget detailListing(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Row(
                children: [
                  getSpacer(8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              )
            ],
          ),
          getAction(label, value)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.service.serviceName),
            getSpacer(4),
            widget.service.showVerified()
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          getProvider(),
          detailListing("category", widget.service.serviceCategory),
          detailListing("number", widget.service.serviceNumber),
          detailListing("email", widget.service.serviceEmail),
          detailListing("address", widget.service.serviceAddress),
          detailListing("notes", "Just some example notes")
        ],
      ),
      //bottomNavigationBar: BottomNavigationBar(items: [],),
    );
  }
}
