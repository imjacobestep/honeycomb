import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Future<Iterable>? resourceList;
  Location location = new Location();
  Future<LocationData>? loc;

  MapPage();
}

class MapPageState extends State<MapPage> {
  @override
  void initState() {
    //widget.unfilteredList = await widget.proxyModel.list('resources');
    widget.resourceList = widget.proxyModel.list("resources");
    widget.loc = widget.location.getLocation();
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

  final Completer<GoogleMapController> _controller = Completer();

  String getCategories(Resource resource) {
    //String ret = "";
    if (resource.categories != null) {
      return resource.categories!.keys.toString();
    } else {
      return "";
    }
  }

// UI WIDGETS
  Widget getMap() {
    return FutureBuilder(
      future: widget.resourceList,
      builder: (BuildContext context, AsyncSnapshot<Iterable> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData && snapshot.data != null) {
          Iterable testList = snapshot.data!;
          for (Resource resource in testList) {
            addMarker(resource);
          }
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No Results"),
          );
        }
        return FutureBuilder(
            future: widget.loc,
            builder:
                (BuildContext context, AsyncSnapshot<LocationData> snapshot2) {
              CameraPosition cam;
              LatLng location;
              if (snapshot2.hasData &&
                  (snapshot2.data!.latitude != null &&
                      snapshot2.data!.longitude != null)) {
                location = LatLng(
                    snapshot2.data!.latitude!, snapshot2.data!.longitude!);
                cam = CameraPosition(
                  target: location,
                  zoom: 17.4746,
                );
                currentMarker(location);
                return GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  markers: markers,
                  initialCameraPosition: cam,
                  //onCameraMove: onCameraMove,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                );
              } else {
                return const LoadingIndicator(size: 50, borderWidth: 5);
              }
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 20,
              child: TextField(
                decoration: InputDecoration(
                  constraints: const BoxConstraints(maxHeight: 50),
                  filled: true,
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search_outlined),
                  fillColor: Theme.of(context).canvasColor,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: getSpacer(4),
            ),
            //getSpacer(8),
            Expanded(
              flex: 8,
              child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const SizedBox(
                          height: 50, child: Center(child: Text("Add"))),
                      //getSpacer(2),
                      const Icon(Icons.add_circle_outline)
                    ],
                  )),
            )
          ],
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
      ),
      /*appBar: AppBar(
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      getSpacer(4),
                      const Text("my location")
                    ],
                  )),
            ),
            getSpacer(8),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text("Filters"),
                      getSpacer(4),
                      const Icon(Icons.filter_list)
                    ],
                  )),
            )
          ],
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
      ),*/
      body: Stack(
        children: [getMap()],
      ),
      bottomNavigationBar: customNav(context, 1),
    );
  }
}
