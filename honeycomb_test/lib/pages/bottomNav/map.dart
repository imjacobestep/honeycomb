import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/geo_helper.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
  //ResourceList mainList;
  Proxy proxyModel = Proxy();
  GeoHelper geo = GeoHelper();
  Future<Iterable>? resourceList;
  Location location = Location();
  Future<LocationData>? currentLocation;
  Future<Map<dynamic, dynamic>>? typedLocation;
  bool? useCurrentLocation;
  String typedAddress = "12280 NE District Wy";
  String typedZipCode = "98005";
  Completer<GoogleMapController>? _controller;
  bool showReturnLocation = false;

  MapPage();
}

class MapPageState extends State<MapPage> {
  @override
  void initState() {
    widget._controller = Completer();
    //widget.unfilteredList = await widget.proxyModel.list('resources');
    widget.resourceList = widget.proxyModel.list("resources");
    widget.currentLocation = widget.location.getLocation();
    /* widget.typedLocation =
        widget.geo.parseAddress(widget.typedAddress, widget.typedZipCode); */
    widget.typedLocation =
        widget.geo.parseAddress(widget.typedAddress, widget.typedZipCode);
    //widget.useCurrentLocation = true;
    widget.useCurrentLocation = false;
    super.initState();
  }

// VARIABLES
  final Set<Marker> markers = {
    const Marker(markerId: MarkerId("test"), position: LatLng(0, 0))
  };
// FUNCTIONS
  void currentMarker(LatLng position) {
    markers.add(Marker(
        onTap: () {},
        markerId: const MarkerId("current"),
        position: position,
        infoWindow: const InfoWindow(title: "You Are Here"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)));
  }

  void addMarker(Resource resource) {
    markers.add(Marker(
        markerId: MarkerId(resource.name!),
        position: resource.coords!,
        infoWindow: InfoWindow(
          title: resource.name!,
          snippet: getCategories(resource),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ServiceDetails(
                          resource: resource,
                        )));
          },
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)));
  }

  String getCategories(Resource resource) {
    //String ret = "";
    if (resource.categories != null) {
      return resource.categories!.keys.toString();
    } else {
      return "";
    }
  }

  void buildList(Iterable resourceList) {
    for (Resource resource in resourceList) {
      addMarker(resource);
    }
  }

// UI WIDGETS
  Widget noResources() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text("No Results"),
    );
  }

  Widget getMap(CameraPosition cam) {
    return GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: widget.showReturnLocation,
      mapType: MapType.normal,
      markers: markers,
      initialCameraPosition: cam,
      onMapCreated: (GoogleMapController controller) {
        widget._controller!.complete(controller);
      },
    );
  }

  Widget buildCurrentLocation() {
    return FutureBuilder(
        future: widget.currentLocation,
        builder: (BuildContext context, AsyncSnapshot loc) {
          CameraPosition cam;
          LatLng location;
          if (loc.hasData &&
              (loc.data!.latitude != null && loc.data!.longitude != null)) {
            location = LatLng(loc.data!.latitude!, loc.data!.longitude!);
            cam = CameraPosition(
              target: location,
              zoom: 17.4746,
            );
            //currentMarker(location);
            return getMap(cam);
          } else {
            return LoadingIndicator(
              size: 50,
              borderWidth: 5,
              color: Theme.of(context).colorScheme.primary,
            );
          }
        });
  }

  Widget buildClientLocation() {
    return FutureBuilder(
        future: widget.typedLocation,
        builder: (BuildContext context, AsyncSnapshot loc) {
          CameraPosition cam;
          LatLng location;
          if (loc.hasData) {
            //print(loc.data);
            if (loc.data!['lat'] != null && loc.data!['lng'] != null) {
              location = LatLng(loc.data!['lat']!, loc.data!['lng']!);
              cam = CameraPosition(
                target: location,
                zoom: 17.4746,
              );
              currentMarker(location);
              return getMap(cam);
            } else {
              return const Center(
                  child: Text(
                "invalid address",
              ));
            }
          } else {
            return LoadingIndicator(
              size: 50,
              borderWidth: 5,
              color: Theme.of(context).colorScheme.primary,
            );
          }
        });
  }

  Widget buildMap() {
    return FutureBuilder(
      future: widget.resourceList,
      builder: (BuildContext context, AsyncSnapshot<Iterable> resourceResults) {
        if (resourceResults.hasData && resourceResults.data != null) {
          buildList(resourceResults.data!);
        } else {
          return noResources();
        }
        if (widget.useCurrentLocation != null && widget.useCurrentLocation!) {
          return buildCurrentLocation();
        } else {
          return buildClientLocation();
        }
      },
    );
  }

  Widget searchBar() {
    return TextField(
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: (text) {
        setState(() {
          final split = text.split(',');

          widget.typedAddress = split[0];
          widget.typedZipCode = split[split.length - 1];
          widget.typedLocation =
              widget.geo.parseAddress(widget.typedAddress, widget.typedZipCode);
          widget.useCurrentLocation = false;
          widget._controller = Completer();
          widget.showReturnLocation = false;
        });
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(0),
        isDense: true,
        constraints: const BoxConstraints(maxHeight: 50),
        filled: true,
        hintText: "Search address...",
        prefixIcon: const Icon(Icons.search_outlined),
        fillColor: Theme.of(context).canvasColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
    );
  }

  Widget headerButton() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            widget.useCurrentLocation = true;
            widget._controller = Completer();
            widget.showReturnLocation = true;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            const SizedBox(height: 50, child: Center(child: Text("Me"))),
            //getSpacer(2),
            const Icon(Icons.my_location)
          ],
        ));
  }

  PreferredSizeWidget topHeader() {
    return AppBar(
      toolbarHeight: 80,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 20, child: searchBar()),
          Expanded(
            flex: 1,
            child: getSpacer(4),
          ),
          Expanded(flex: 8, child: headerButton())
        ],
      ),
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topHeader(),
      body: Stack(
        children: [buildMap()],
      ),
      bottomNavigationBar: customNav(context, 1),
    );
  }
}
