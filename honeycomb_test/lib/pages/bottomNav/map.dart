import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/utilities.dart';

class Map {
  BuildContext context;

  Map({required this.context});

  PreferredSizeWidget getAppBar() {
    return AppBar(
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
    );
  }

  static const LatLng center =
      const LatLng(47.621527688800185, -122.17670223058742);

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: center,
    zoom: 17.4746,
  );

  final Set<Marker> markers = {
    Marker(
        markerId: MarkerId(center.toString()),
        position: center,
        infoWindow: InfoWindow(title: "Testing..."),
        icon: BitmapDescriptor.defaultMarker)
  };
  LatLng lastPosition = center;

  Completer<GoogleMapController> _controller = Completer();

  void onCameraMove(CameraPosition position) {
    lastPosition = position.target;
    onAddMarker();
  }

  void onAddMarker() {
    markers.add(Marker(
        markerId: MarkerId(lastPosition.toString()),
        position: lastPosition,
        infoWindow: InfoWindow(title: "Testing..."),
        icon: BitmapDescriptor.defaultMarker));
  }

  Widget getBody() {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          markers: markers,
          initialCameraPosition: _kGooglePlex,
          onCameraMove: onCameraMove,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        )
      ],
    );
  }
}
