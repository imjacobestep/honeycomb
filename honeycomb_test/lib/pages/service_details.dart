import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/resource_model.dart';

class ServiceDetails extends StatefulWidget {
  @override
  ServiceDetailsState createState() => ServiceDetailsState();
  String previousPage;
  Resource_Model resource;
  //var locData;

  ServiceDetails({required this.resource, required this.previousPage});
}

class ServiceDetailsState extends State<ServiceDetails> {
  @override
  void initState() {
    var locData = Geocoder2.getDataFromAddress(
        address: widget.resource.address,
        googleMapApiKey: "AIzaSyC1hEwGPXOck5HeY0ziBFtNGZ7GJGa5HAs");
    super.initState();
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(47.621527688800185, -122.17670223058742),
    //target: LatLng(locData.latitude, locData.longitude),
    zoom: 17.4746,
  );

  final Completer<GoogleMapController> _controller = Completer();

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
                MapsLauncher.launchQuery(widget.resource.address);
                //launchUrl(Uri.parse("https://maps.google.com?q=${widget.service.serviceAddress.replaceAll(RegExp(" "), "+")}"));
              },
              icon: Icon(Icons.directions_outlined));
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
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              getSpacer(4),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 50),
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  value,
                  maxLines: 10,
                  softWrap: true,
                  textWidthBasis: TextWidthBasis.parent,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          getAction(label, value)
        ],
      ),
    );
  }

  Widget getAction2(String label, String value) {
    double size = 70.0;
    switch (label) {
      case "Call":
        {
          return InkWell(
            onTap: () {
              launchUrl(Uri(
                scheme: 'tel',
                path: value,
              ));
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call_outlined),
                  getSpacer(4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
              ),
            ),
          );
        }
        break;

      case "Email":
        {
          return InkWell(
            onTap: () {
              launchUrl(Uri(
                scheme: 'mailto',
                path: value,
              ));
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline),
                  getSpacer(4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
              ),
            ),
          );
        }
        break;

      case "Directions":
        {
          return InkWell(
            onTap: () {
              MapsLauncher.launchQuery(widget.resource.address);
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_outlined),
                  getSpacer(4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
              ),
            ),
          );
        }
        break;

      case "Web":
        {
          return InkWell(
            onTap: () {
              MapsLauncher.launchQuery(widget.resource.address);
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language_outlined),
                  getSpacer(4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
              ),
            ),
          );
        }
        break;

      case "Client":
        {
          return InkWell(
            onTap: () {
              MapsLauncher.launchQuery(widget.resource.address);
              //launchUrl(Uri.parse("https://maps.google.com?q=${widget.service.serviceAddress.replaceAll(RegExp(" "), "+")}"));
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_outlined),
                  getSpacer(4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
              ),
            ),
          );
        }
        break;

      default:
        {
          return Container();
        }
        break;
    }
  }

  Widget detailsCategory(List<String> categories, BuildContext context) {
    return Wrap(children: [
      for (String category in categories)
        widget.resource.detailsCategoryLabel(context, category)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    //_kGooglePlex = getCamera(widget.provider.serviceList[widget.serviceIndex].serviceAddress);

    final Set<Marker> markers = {
      Marker(
          markerId: MarkerId(_kGooglePlex.toString()),
          position: _kGooglePlex.target,
          infoWindow: InfoWindow(
              title: widget.resource.name,
              snippet: widget.resource.categories.first),
          icon: BitmapDescriptor.defaultMarker)
    };

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: const Color(0xFF2B2A2A),
        //backgroundColor: Colors.transparent,
        elevation: 0,
        //foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Container(
            foregroundDecoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            clipBehavior: Clip.antiAlias,
            height: 300,
            margin: EdgeInsets.only(bottom: 16),
            child: GoogleMap(
              //liteModeEnabled: true,
              mapToolbarEnabled: false,
              mapType: MapType.normal,
              markers: markers,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.resource.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.star_border_outlined),
                    iconSize: 30,
                  )
                ],
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Edit"),
                      getSpacer(4),
                      const Icon(Icons.edit_outlined),
                    ],
                  )
                  //icon: const Icon(Icons.edit_outlined),
                  //iconSize: 30,
                  )
            ],
          ),
          detailsCategory(widget.resource.categories, context),
          getSpacer(8),
          getDivider(context),
          getSpacer(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              getAction2("Directions", widget.resource.address),
              getAction2("Call", widget.resource.phoneNumbers['primary']),
              getAction2("Email", widget.resource.email),
              getAction2("Web", widget.resource.website),
              getAction2("Client", widget.resource.website),
            ],
          ),
          getSpacer(8),
          getDivider(context),
          getSpacer(8),
          detailListing("notes", widget.resource.notes),
          getSpacer(8),
          getDivider(context),
          getSpacer(8),
          detailListing("number", widget.resource.phoneNumbers["primary"]),
          detailListing("email", widget.resource.email),
          detailListing("address", widget.resource.address),
          detailListing("website", widget.resource.website)
        ],
      ),
      //bottomNavigationBar: BottomNavigationBar(items: [],),
    );
  }
}
