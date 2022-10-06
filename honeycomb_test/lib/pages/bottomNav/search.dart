import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Search {
  BuildContext context;

  Search({required this.context});

  PreferredSizeWidget getAppBar() {
    return AppBar(
      toolbarHeight: 100,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      title: Column(
        children: [
          Text(
            "Search",
          ),
          ElevatedButton(onPressed: () {}, child: Icon(Icons.search)),
        ],
      ),
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
    );
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(47.621527688800185, -122.17670223058742),
    zoom: 17.4746,
  );

  Completer<GoogleMapController> _controller = Completer();

  Widget getBody() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
