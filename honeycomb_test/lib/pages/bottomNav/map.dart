// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, use_build_context_synchronously

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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
  Proxy proxyModel = Proxy();
  GeoHelper geo = GeoHelper();
  Future<Iterable>? resourceList;
  Location location = Location();
  Future<LocationData>? currentLocation;
  Future<Map<dynamic, dynamic>>? typedLocation;
  bool? useCurrentLocation;
  String? typedAddress;
  String typedZipCode = "";
  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();
  Set<Marker> markers = {
    const Marker(markerId: MarkerId("test"), position: LatLng(0, 0))
  };

  MapPage(this.typedAddress);
}

class MapPageState extends State<MapPage> {
  @override
  void initState() {
    resetFilters();
    widget.resourceList = widget.proxyModel.list("resources");
    widget.currentLocation = widget.location.getLocation();
    widget.typedLocation =
        widget.geo.parseAddress(widget.typedAddress!, widget.typedZipCode);
    widget.useCurrentLocation = true;
    clearMarkers();
    super.initState();
  }

  @override
  void dispose() {
    filters.forEach(
      (key, value) {
        value.forEach((key, value) {
          setFilter(key, false);
        });
      },
    );
    if (widget.mapController != null) {
      widget.mapController!.dispose();
    }
    widget.searchController.dispose();
    super.dispose();
  }

  // VARIABLES

  LatLng lastLocation = const LatLng(0, 0);

  // FUNCTIONS

  void clearMarkers() {
    widget.markers = {
      const Marker(markerId: MarkerId("test"), position: LatLng(0, 0))
    };
  }

  void typedLocationMarker(LatLng position) {
    widget.markers.add(Marker(
        onTap: () {},
        markerId: const MarkerId("current"),
        position: position,
        infoWindow: const InfoWindow(title: "You Are Here"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)));
  }

  Marker newResourceMarker(Resource resource) {
    return (Marker(
        markerId: MarkerId(resource.name!),
        position: resource.coords!,
        infoWindow: InfoWindow(
          title: resource.name!,
          snippet: categoriesToString(resource),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResourceDetails(
                          resource: resource,
                        )));
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
  }

  String categoriesToString(Resource resource) {
    if (resource.categories != null) {
      return resource.categories!.toString();
    } else {
      return "";
    }
  }

  Set<Marker> generateResourceMarkers(Iterable resourceList) {
    Set<Marker> ret = {};
    for (Resource resource in resourceList) {
      if (resource.coords != null) {
        ret.add(newResourceMarker(resource));
      }
    }
    return ret;
  }

  // LOADERS (wait on an asynchronous item, then return a Widget)

  Widget userLocationLoader(Iterable resources) {
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
            return map(cam, resources);
          } else {
            return LoadingIndicator(
              size: 50,
              borderWidth: 5,
              color: Theme.of(context).colorScheme.primary,
            );
          }
        });
  }

  Widget typedLocationLoader(Iterable resources) {
    return FutureBuilder(
        future:
            widget.geo.parseAddress(widget.typedAddress!, widget.typedZipCode),
        builder: (BuildContext context, AsyncSnapshot loc) {
          CameraPosition cam;
          LatLng location;
          if (loc.hasData) {
            if (loc.data!['lat'] != null && loc.data!['lng'] != null) {
              location = LatLng(loc.data!['lat']!, loc.data!['lng']!);
              cam = CameraPosition(
                target: location,
                zoom: 17.5,
              );
              typedLocationMarker(location);
              return map(cam, resources);
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

  Widget resourcesLoader() {
    return FutureBuilder(
      future: howManyFilters() == 0
          ? widget.resourceList
          : widget.proxyModel.filter("resources", getFilterQuery()),
      builder: (BuildContext context, AsyncSnapshot<Iterable> resourceResults) {
        if (resourceResults.hasData && resourceResults.data != null) {
          if (widget.typedAddress != "") {
            return typedLocationLoader(resourceResults.data!);
          } else {
            return userLocationLoader(resourceResults.data!);
          }
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No Results"),
          );
        }
      },
    );
  }

  // UI WIDGETS

  Future filterSheet() {
    return showMaterialModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        expand: false,
        isDismissible: false,
        context: context,
        builder: (context) {
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
                          label: Text(
                            label,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          backgroundColor: Colors.transparent,
                          side:
                              const BorderSide(color: Colors.black12, width: 1),
                        )
                      : Chip(
                          side: const BorderSide(
                              color: Colors.transparent, width: 1),
                          backgroundColor: Colors.black,
                          label: Text(
                            label,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .fontSize),
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
              children.add(getSpacer(0));
              filters.forEach((key, value) {
                children.add(getDivider(context));
                children.add(Text(key));
                children.add(Wrap(
                  spacing: 4,
                  children: filterSection(value),
                ));
              });
              children.add(getSpacer(16));
              children.add(applyButton());
              return children;
            }

            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: buildList(),
            );
          });
        });
  }

  Widget map(CameraPosition cam, Iterable resources) {
    return GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      markers: generateResourceMarkers(resources),
      initialCameraPosition: cam,
      mapToolbarEnabled: false,
      buildingsEnabled: true,
      compassEnabled: false,
      liteModeEnabled: false,
      trafficEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        widget.mapController = controller;
      },
    );
  }

  Widget searchBar() {
    return TextField(
      maxLines: 1,
      controller: widget.searchController,
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: (text) async {
        if (text != "") {
          Map<dynamic, dynamic> coords =
              await widget.geo.parseAddress(text, widget.typedZipCode);
          if (coords["lat"] != null || coords["lng"] != null) {
            widget.mapController!.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(coords["lat"], coords["lng"]), zoom: 17.5)));
            showToast("Moving to $text", Theme.of(context).primaryColor);
          } else {
            showToast("ERROR: invalid address", Theme.of(context).primaryColor);
          }
        }
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(0),
        isDense: true,
        constraints: const BoxConstraints(maxHeight: 50),
        filled: true,
        hintText: "Search address...",
        prefixIcon: const Icon(
          Icons.search_outlined,
          color: Colors.black87,
        ),
        fillColor: Theme.of(context).canvasColor,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.black26),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.black),
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
              widget.searchController.clear();
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

  PreferredSizeWidget pageHeader() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Navigator.canPop(context) ? const BackButton() : null,
      //automaticallyImplyLeading: false,
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
    );
  }

  Widget filtersButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 40,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: howManyFilters() == 0
                    ? Colors.white
                    : const Color(0xFFFFC700),
                side: const BorderSide(width: 2, color: Colors.black26)
                /* side: !ifAnyFilters()
                        ? null
                        : const BorderSide(color: Colors.black, width: 4) */
                ),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: pageHeader(),
      body: resourcesLoader(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: filtersButton(),
      bottomNavigationBar: customNav(context, 1),
    );
  }
}
