import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/provider.dart';
import 'package:honeycomb_test/pages/provider_details.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetails extends StatefulWidget {
  @override
  ServiceDetailsState createState() => ServiceDetailsState();
  Provider provider;
  int serviceIndex;
  String previousPage;

  ServiceDetails(
      {required this.provider,
      required this.serviceIndex,
      required this.previousPage});
}

class ServiceDetailsState extends State<ServiceDetails> {
  @override
  void initState() {
    super.initState();
  }

  Widget getProvider() {
    return Card(
      child: InkWell(
        onTap: () => widget.previousPage == "provider"
            ? Navigator.pop(context)
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderDetails(
                    provider: widget.provider,
                  ),
                )),
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
                        widget.provider.providerName,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  )
                ],
              ),
              IconButton(
                  onPressed: () => widget.previousPage == "provider"
                      ? Navigator.pop(context)
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProviderDetails(
                              provider: widget.provider,
                            ),
                          )),
                  icon: const Icon(Icons.chevron_right_sharp))
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
                MapsLauncher.launchQuery(widget
                    .provider.serviceList[widget.serviceIndex].serviceAddress);
                //launchUrl(Uri.parse("https://maps.google.com?q=${widget.service.serviceAddress.replaceAll(RegExp(" "), "+")}"));
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
      padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 16),
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
              getSpacer(4),
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
            onPressed: () {
              serviceToContact(widget.provider, widget.serviceIndex);
            },
            icon: const Icon(Icons.edit),
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.provider.serviceList[widget.serviceIndex].serviceName),
            getSpacer(4),
            widget.provider.serviceList[widget.serviceIndex].showVerified()
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          getProvider(),
          detailListing("category",
              widget.provider.serviceList[widget.serviceIndex].serviceCategory),
          detailListing("number",
              widget.provider.serviceList[widget.serviceIndex].serviceNumber),
          detailListing("email",
              widget.provider.serviceList[widget.serviceIndex].serviceEmail),
          detailListing("address",
              widget.provider.serviceList[widget.serviceIndex].serviceAddress),
          detailListing("notes", "Just some example notes")
        ],
      ),
      //bottomNavigationBar: BottomNavigationBar(items: [],),
    );
  }
}
