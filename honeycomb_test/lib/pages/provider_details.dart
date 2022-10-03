import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/provider.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderDetails extends StatefulWidget {
  @override
  ProviderDetailsState createState() => ProviderDetailsState();
  Provider provider;

  ProviderDetails({required this.provider});
}

class ProviderDetailsState extends State<ProviderDetails> {
  @override
  void initState() {
    super.initState();
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
                    "https://maps.google.com?q=${widget.provider.providerAddress.replaceAll(RegExp(" "), "+")}"));
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
            Text(widget.provider.providerName),
            getSpacer(4),
            widget.provider.showMou()
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          detailListing("number", widget.provider.providerNumber),
          detailListing("email", widget.provider.providerEmail),
          detailListing("address", widget.provider.providerAddress),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "services",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.provider.serviceList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return widget.provider.serviceList[index].getCard(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      //bottomNavigationBar: BottomNavigationBar(items: [],),
    );
  }
}
