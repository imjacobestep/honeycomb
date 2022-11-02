import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/resource.dart';
import '../model/user.dart';
import '../ui_components/resource_ui.dart';

class ServiceDetails extends StatefulWidget {
  @override
  ServiceDetailsState createState() => ServiceDetailsState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  Resource resource;
  GoogleMapController? mapController;
  ServiceDetails({required this.resource});
}

class ServiceDetailsState extends State<ServiceDetails> {
  @override
  void initState() {
    super.initState();
  }

  final Completer<GoogleMapController> _controller = Completer();

  Widget getAction(String label, String value) {
    switch (label) {
      case "Phone Number":
        {
          return IconButton(
              onPressed: () {
                launchUrl(Uri(
                  scheme: 'tel',
                  path: value,
                ));
              },
              icon: const Icon(Icons.call_outlined));
        }

      case "Email Address":
        {
          return IconButton(
              onPressed: () {
                launchUrl(Uri(
                  scheme: 'mailto',
                  path: value,
                ));
              },
              icon: const Icon(Icons.mail_outlined));
        }

      case "Street Address":
        {
          return IconButton(
              onPressed: () {
                MapsLauncher.launchQuery(widget.resource.address!);
                //launchUrl(Uri.parse("https://maps.google.com?q=${widget.service.serviceAddress.replaceAll(RegExp(" "), "+")}"));
              },
              icon: const Icon(Icons.directions_outlined));
        }

      case "Website":
        {
          return IconButton(
              onPressed: () {
                launchUrl(Uri.parse(widget.resource.website!));
              },
              icon: const Icon(Icons.language));
        }

      default:
        {
          return Container();
        }
    }
  }

  bool isAction(String label) {
    switch (label) {
      case "Phone Number":
        return true;
      case "Email Address":
        return true;
      case "Street Address":
        return true;
      case "Website":
        return true;
      default:
        return false;
    }
  }

  Widget numbersSection() {
    List<Widget> children = [];
    children.add(
      Text(
        "Phone Numbers",
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
    widget.resource.phoneNumbers!.forEach((key, value) {
      String contactName = key;
      String number = value;
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "$contactName:",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                getSpacer(8),
                Text(
                  number,
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              ],
            ),
            getAction("Phone Number", number)
          ],
        ),
      ));
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget detailItem(String label, String value) {
    List<Widget> children = [
      Expanded(
        flex: 9,
        child: Column(
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
      )
    ];
    if (isAction(label)) {
      children.add(Expanded(flex: 1, child: getAction(label, value)));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }

  Widget getQuickAction(String label, String value) {
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
                  const Icon(Icons.call_outlined),
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
                  const Icon(Icons.mail_outline),
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

      case "Directions":
        {
          return InkWell(
            onTap: () {
              MapsLauncher.launchQuery(widget.resource.address!);
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_outlined),
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

      case "Web":
        {
          return InkWell(
            onTap: () {
              MapsLauncher.launchQuery(widget.resource.address!);
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language_outlined),
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

      case "Client":
        {
          return InkWell(
            onTap: () {
              MapsLauncher.launchQuery(widget.resource.address!);
              //launchUrl(Uri.parse("https://maps.google.com?q=${widget.service.serviceAddress.replaceAll(RegExp(" "), "+")}"));
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_outlined),
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

      default:
        {
          return Container();
        }
    }
  }

  Widget tagsBuilder(Map<dynamic, dynamic> categories, BuildContext context) {
    return Wrap(children: [
      for (String category in categories.keys)
        detailsCategoryLabel(context, category)
    ]);
  }

  Widget getMisc() {
    Map<dynamic, dynamic> miscDetails = {};
    if (widget.resource.multilingual != null && widget.resource.multilingual!) {
      miscDetails["Multilingual"] = true;
    }

    return tagsBuilder(miscDetails, context);
  }

  Widget editButton() {
    return ElevatedButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Edit"),
            getSpacer(8),
            const Icon(Icons.edit_outlined),
          ],
        ));
  }

  Widget favoriteButton(value, MPUser user) {
    Icon favStar =
        value ? const Icon(Icons.star) : const Icon(Icons.star_border_outlined);
    return ElevatedButton(
        onPressed: () {
          if (user.favorites != null && widget.resource.id != null) {
            user.favorites!.add(widget.resource.id!);
          }
          widget.proxyModel.upsert(user);
          setState(() {});
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            favStar,
          ],
        ));
  }

  Widget userBuilder() {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          MPUser user = snapshot.data!;
          return favoritesButtonBuilder(snapshot.data);
        } else {
          return const Center(
            child: Text("No user found"),
          );
        }
      },
    );
  }

  Widget favoritesButtonBuilder(MPUser user) {
    return FutureBuilder(
      future: widget.proxyModel.listUserFavorites(user),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          Iterable favs = snapshot.data!;
          bool isFavorite = false;
          if (favs.contains(widget.resource)) {
            isFavorite = true;
          }
          return favoriteButton(isFavorite, user);
        } else {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0, backgroundColor: Colors.black12),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.error),
                  ],
                )),
          );
        }
      },
    );
  }

  PreferredSizeWidget topHeader() {
    return AppBar(
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: editButton(),
        ),
      ],
    );
  }

  List<Widget> quickActionsBuilder() {
    List<Widget> ret = [];
    if (widget.resource.address != null) {
      ret.add(getQuickAction("Directions", widget.resource.address!));
    } //directions
    if (widget.resource.phoneNumbers != null &&
        widget.resource.phoneNumbers!["primary"] != null) {
      ret.add(getQuickAction("Call", widget.resource.phoneNumbers!['primary']));
    } //phone
    if (widget.resource.email != null) {
      ret.add(getQuickAction("Email", widget.resource.email!));
    } //email
    if (widget.resource.website != null) {
      ret.add(getQuickAction("Web", widget.resource.website!));
    }
    ret.add(getQuickAction("Client", "stuff")); //web
    //client
    return ret;
  }

  Widget getMap() {
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border.all(
            color: Colors.black12, width: 2, strokeAlign: StrokeAlign.outside),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      height: 250,
      margin: const EdgeInsets.only(bottom: 16),
      child: GoogleMap(
        //liteModeEnabled: true,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        mapType: MapType.normal,
        markers: {
          Marker(
              markerId: MarkerId(widget.resource.name!),
              position: widget.resource.coords!,
              infoWindow: InfoWindow(
                title: widget.resource.name!,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure))
        },
        initialCameraPosition:
            CameraPosition(target: widget.resource.coords!, zoom: 18),
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            widget.mapController = controller;
          });
        },
      ),
    );
  }

  Widget resourceHeader() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.resource.name!,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        userBuilder()
      ],
    );
  }

  Widget listBuilder() {
    List<Widget> children = [];
    //MAP
    if (widget.resource.coords != null) {
      children.add(getMap());
    }
    //HEADER
    children.add(resourceHeader());
    if (widget.resource.categories != null) {
      children.add(tagsBuilder(widget.resource.categories!, context));
    }
    children.add(getDivider(context));
    //QUICK ACTIONS
    children.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: quickActionsBuilder(),
    ));
    //NOTES
    children.add(getDivider(context));
    if (widget.resource.notes != null) {
      children.add(detailItem("Notes", widget.resource.notes!));
      children.add(getDivider(context));
    }
    //OTHER INFO
    if (widget.resource.eligibility != null) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Eligibility Requirements",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            tagsBuilder(widget.resource.eligibility!, context)
          ],
        ),
      ));
      children.add(getDivider(context));
    }
    if (widget.resource.eligibility != null) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Misc Details",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            getMisc()
          ],
        ),
      ));
      children.add(getDivider(context));
    }
    //EXPANDED CONTACTS
    if (widget.resource.phoneNumbers != null) {
      children.add(numbersSection());
      children.add(getDivider(context));
    }
    if (widget.resource.email != null) {
      children.add(detailItem("Email Address", widget.resource.email!));
      children.add(getDivider(context));
    }
    if (widget.resource.address != null) {
      children.add(detailItem("Street Address", widget.resource.address!));
      children.add(getDivider(context));
    }
    if (widget.resource.website != null) {
      children.add(detailItem("Website", widget.resource.website!));
      children.add(getDivider(context));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topHeader(),
      body: listBuilder(),
    );
  }
}
