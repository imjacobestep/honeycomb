import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
  //ResourceList mainList;
  Proxy proxyModel = Proxy();
  Iterable? unfilteredList;
  Iterable? filteredList;

  MapPage();
}

class MapPageState extends State<MapPage> {
  @override
  Future<void> initState() async {
    widget.unfilteredList = await widget.proxyModel.list('resources');

    super.initState();
  }

  static const LatLng center = LatLng(47.621527688800185, -122.17670223058742);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: center,
    zoom: 17.4746,
  );

  final Set<Marker> markers = {
    Marker(
        markerId: MarkerId(center.toString()),
        position: center,
        infoWindow: const InfoWindow(title: "Your location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue))
  };
  LatLng lastPosition = center;

  final Completer<GoogleMapController> _controller = Completer();

  void onCameraMove(CameraPosition position) {
    lastPosition = position.target;
    onAddMarker();
  }

  void onAddMarker() {
    markers.add(Marker(
        markerId: MarkerId(lastPosition.toString()),
        position: lastPosition,
        infoWindow: const InfoWindow(title: "Testing..."),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)));
  }

  @override
  Widget build(BuildContext context) {
    for (Resource resource in widget.unfilteredList!) {
      markers.add(Marker(
          markerId: MarkerId(resource.name!),
          position: resource.coords!,
          infoWindow: InfoWindow(
              title: resource.name,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServiceDetails(
                              resource: resource,
                            )));
              }),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange)));
    }
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
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            markers: markers,
            initialCameraPosition: _kGooglePlex,
            //onCameraMove: onCameraMove,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          )
        ],
      ),
      bottomNavigationBar: customNav(context, 1),
    );
  }
}
