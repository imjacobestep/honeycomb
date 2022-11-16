import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/geo_helper.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:location/location.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
  BitmapDescriptor resourceIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  Proxy proxyModel = Proxy();
  GeoHelper geo = GeoHelper();
  Future<Iterable>? resourceList;
  Location location = Location();
  Future<LocationData>? currentLocation;
  Future<Map<dynamic, dynamic>>? typedLocation;
  bool? useCurrentLocation;
  String typedAddress = "12280 NE District Wy";
  String typedZipCode = "98005";
  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();
  CustomInfoWindowController infoController = CustomInfoWindowController();
  Set<Marker> markers = {
    const Marker(markerId: MarkerId("test"), position: LatLng(0, 0))
  };

  MapPage();
}

class MapPageState extends State<MapPage> {
  @override
  void initState() {
    resetFilters();
    widget.resourceList = widget.proxyModel.list("resources");
    widget.currentLocation = widget.location.getLocation();
    widget.typedLocation =
        widget.geo.parseAddress(widget.typedAddress, widget.typedZipCode);
    widget.useCurrentLocation = true;
    clearMarkers();
    super.initState();
    setResourceIcon();
  }

  @override
  void dispose() {
    //resetFilters();
    filters.forEach(
      (key, value) {
        value.forEach((key, value) {
          setFilter(key, false);
        });
      },
    );
    if (widget.infoController != null) {
      widget.infoController!.dispose();
    }
    if (widget.mapController != null) {
      widget.mapController!.dispose();
    }
    if (widget.searchController != null) {
      widget.searchController.dispose();
    }
    super.dispose();
  }

  LatLng lastLocation = const LatLng(0, 0);

// FUNCTIONS

  void setResourceIcon() async {
    widget.resourceIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/map_pins/resource_pin.bmp');
    setState(() {});
  }

  void clearMarkers() {
    widget.markers = {
      const Marker(markerId: MarkerId("test"), position: LatLng(0, 0))
    };
  }

  void currentMarker(LatLng position) {
    widget.markers.add(Marker(
        onTap: () {},
        markerId: const MarkerId("current"),
        position: position,
        infoWindow: const InfoWindow(title: "You Are Here"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)));
  }

  Marker newMarker(Resource resource) {
    return (Marker(
        markerId: MarkerId(resource.name!),
        position: resource.coords!,
        /* onTap: () {
          widget.infoController.addInfoWindow!(
              resourceWindow(context, resource), resource.coords!);
        }, */
        infoWindow: InfoWindow(
          title: resource.name!,
          snippet: getCategories(resource),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResourceDetails(
                          resource: resource,
                        )));
          },
        ),
        icon: widget.resourceIcon));
  }

  String getCategories(Resource resource) {
    //String ret = "";
    if (resource.categories != null) {
      return resource.categories!.keys.toString();
    } else {
      return "";
    }
  }

  Set<Marker> buildList(Iterable resourceList) {
    Set<Marker> ret = {};
    for (Resource resource in resourceList) {
      if (resource.coords != null) {
        ret.add(newMarker(resource));
      }
    }
    return ret;
  }

// UI WIDGETS

  List<Widget> getFilters(Map map) {
    List<Widget> ret = [];
    ret.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              onPressed: () {
                resetFilters();
              },
              child: const Text("clear filters")),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
    );
    ret.add(getSpacer(8));

    ret.add(ElevatedButton(
        onPressed: () {
          setState(() {});
          Navigator.pop(context);
        },
        child: const Text("Apply Filters")));
    return ret;
  }

  Widget sheetBuilder() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
      Widget filterChip(String label, bool value) {
        return InkWell(
            borderRadius: BorderRadius.circular(35),
            enableFeedback: true,
            onTap: () {
              setFilter(label, !value);
              setSheetState(() {});
            },
            child: !value
                ? Chip(
                    label: Text(label),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.black12, width: 1),
                  )
                : Chip(
                    side: const BorderSide(color: Colors.transparent, width: 1),
                    backgroundColor: Colors.black,
                    label: Text(
                      label,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ));
      }

      List<Widget> filterSection(Map map) {
        List<Widget> ret = [];
        for (var key in map.keys) {
          if (map[key] != null) {
            ret.add(filterChip(key, map[key]));
          }
        }
        return ret;
      }

      Widget filterHeader() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () {
                  filters.forEach(
                    (key, value) {
                      value.forEach((key, value) {
                        setFilter(key, false);
                      });
                    },
                  );
                  setSheetState(() {});
                },
                child: const Text("clear filters")),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close))
          ],
        );
      }

      Widget applyButton() {
        return ElevatedButton(
            onPressed: () {
              setState(() {
                widget.markers.clear();
              });

              widget.markers.clear();
              Navigator.pop(context);
            },
            child: const Text("Apply Filters"));
      }

      List<Widget> buildList() {
        List<Widget> children = [];
        children.add(filterHeader());
        children.add(getSpacer(8));
        filters.forEach((key, value) {
          children.add(Text(key));
          children.add(Wrap(
            spacing: 4,
            children: filterSection(value),
          ));
        });
        children.add(applyButton());
        return children;
      }

      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: buildList(),
      );
    });
  }

  Future filterSheet() {
    return showMaterialModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        expand: false,
        isDismissible: false,
        context: context,
        builder: (context) {
          return sheetBuilder();
        });
  }

  Widget noResources() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text("No Results"),
    );
  }

  Widget getMap(CameraPosition cam, Iterable resources) {
    return GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      markers: buildList(resources),
      initialCameraPosition: cam,
      trafficEnabled: true,
      onTap: (position) {
        widget.infoController.hideInfoWindow!();
      },
      /* onCameraMove: ((position) {
        widget.infoController.hideInfoWindow!();
      }), */
      onMapCreated: (GoogleMapController controller) {
        widget.infoController.googleMapController = controller;
        setState(() {
          widget.mapController = controller;
        });
      },
    );
  }

  Widget buildCurrentLocation(Iterable resources) {
    return FutureBuilder(
        future: widget.currentLocation,
        builder: (BuildContext context, AsyncSnapshot loc) {
          CameraPosition cam;
          LatLng location;
          if (loc.hasData &&
              (loc.data!.latitude != null && loc.data!.longitude != null)) {
            location = LatLng(loc.data!.latitude!, loc.data!.longitude!);
            lastLocation = location;
            cam = CameraPosition(
              target: location,
              zoom: 17.5,
            );
            //buildList(resources);
            //currentMarker(location);
            return getMap(cam, resources);
          } else {
            return LoadingIndicator(
              size: 50,
              borderWidth: 5,
              color: Theme.of(context).colorScheme.primary,
            );
          }
        });
  }

  Widget buildClientLocation(Iterable resources) {
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
                zoom: 17.5,
              );
              currentMarker(location);
              //buildList(resources);
              return getMap(cam, resources);
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
      future: !ifAnyFilters()
          ? widget.resourceList
          : widget.proxyModel.filter("resources", getFilterQuery()),
      builder: (BuildContext context, AsyncSnapshot<Iterable> resourceResults) {
        if (resourceResults.hasData && resourceResults.data != null) {
          //buildList(resourceResults.data!);
          if (widget.useCurrentLocation != null && widget.useCurrentLocation!) {
            return buildCurrentLocation(resourceResults.data!);
          } else {
            return buildClientLocation(resourceResults.data!);
          }
        } else {
          return noResources();
        }
      },
    );
  }

  Widget searchBar() {
    return TextField(
      maxLines: 1,
      controller: widget.searchController,
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: (text) {
        if (widget.searchController.text != "") {
          setState(() {
            //final split = widget.searchController.text.split(',');

            widget.typedAddress = widget.searchController.text;
            /* widget.typedZipCode = split[split.length - 1];
            widget.typedLocation = widget.geo
                .parseAddress(widget.searchController.text, ''); */
            widget.useCurrentLocation = false;
            widget.markers.clear();
          });
        } else {
          setState(() {
            widget.markers.clear();
            widget.useCurrentLocation = true;
          });
        }
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(0),
        isDense: true,
        constraints: const BoxConstraints(maxHeight: 50),
        filled: true,
        hintText: "Search address...",
        prefixIcon: const Icon(Icons.search_outlined),
        fillColor: Theme.of(context).canvasColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        suffixIcon: widget.searchController.text != ""
            ? IconButton(
                onPressed: () {
                  widget.searchController.clear;
                  setState(() {
                    widget.searchController.clear();
                    setState(() {
                      widget.markers.clear();
                      widget.useCurrentLocation = true;
                    });
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
    );
  }

  Widget headerButton() {
    return ElevatedButton(
        onPressed: () {
          if (widget.useCurrentLocation!) {
            widget.mapController!.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: lastLocation, zoom: 17.5)));
          } else {
            setState(() {
              widget.useCurrentLocation = true;
              widget.markers.clear();
            });
          }
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
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
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
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: topHeader(),
      /* body: Stack(children: [
        buildMap(),
        CustomInfoWindow(
          controller: widget.infoController,
          height: 100,
          width: 260,
          offset: 30,
        ),
      ]), */
      body: buildMap(),
      floatingActionButton: ElevatedButton(
          onPressed: () async {
            await filterSheet();
            setState(() {
              widget.markers.clear();
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filters"),
              getSpacer(4),
              const Icon(Icons.filter_list_outlined)
            ],
          )),
      bottomNavigationBar: customNav(context, 1),
    );
  }
}
