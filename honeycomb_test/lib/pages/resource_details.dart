// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, depend_on_referenced_packages

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/model/client.dart';
import 'package:honeycomb_test/pages/bottomNav/map.dart';
import 'package:honeycomb_test/pages/resource_onboarding.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/animated_navigator.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/resource.dart';
import '../model/user.dart';
import '../ui_components/resource_ui.dart';
import 'package:intl/intl.dart';

class ResourceDetails extends StatefulWidget {
  @override
  ResourceDetailsState createState() => ResourceDetailsState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  Resource resource;
  MPUser? user;
  GoogleMapController? mapController;
  Map<Client, bool> clientsList = {};
  List<Widget> sheetChildren = [];
  ResourceDetails({required this.resource});
}

class ResourceDetailsState extends State<ResourceDetails> {
  @override
  void initState() {
    super.initState();
    widget.sheetChildren = [];
  }

  @override
  void dispose() {
    if (widget.mapController != null) {
      widget.mapController!.dispose();
    }
    super.dispose();
  }

  Widget sheetBuilder(MPUser user) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
      List<Widget> children = [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Add this resource to..."),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close))
          ],
        ),
        getSpacer(8),
        resourceCard(context, widget.resource, () {
          Navigator.pop(context);
        }),
        getDivider(context)
      ];
      Widget clientCheckBox(Client client) {
        if (widget.clientsList[client]!) {
          return IconButton(
              onPressed: () async {
                await widget.proxyModel.delFromList(client, widget.resource);
                setSheetState(() {
                  widget.clientsList.clear();
                });
              },
              icon: const Icon(Icons.check_box));
        } else {
          return IconButton(
              onPressed: () async {
                if (client.resources == null) {
                  client.resources = [];
                  widget.proxyModel.upsert(client);
                }
                await widget.proxyModel.addToList(client, widget.resource);
                setSheetState(() {
                  widget.clientsList.clear();
                  widget.sheetChildren = [];
                });
              },
              icon: const Icon(Icons.check_box_outline_blank_outlined));
        }
      }

      Widget addToClientCard(Client client) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  client.alias!,
                  style: const TextStyle(fontSize: 20),
                ),
                clientCheckBox(client)
              ],
            ),
          ),
        );
      }

      return FutureBuilder(
        future: widget.proxyModel.listUserClients(user),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              for (Client client in snapshot.data) {
                bool isHere = (client.resources != null &&
                    (client.resources!.contains(widget.resource.id)));
                widget.clientsList[client] = isHere;
                children.add(addToClientCard(client));
              }
              children.add(getSpacer(8));
              children.add(ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Done",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )));
              children.add(getSpacer(24));
              return ListView(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                children: children,
              );
            } else {
              return helperText("No Clients Found",
                  "Go to the clients tab to add clients", context, false);
            }
          } else {
            return const SizedBox(
              height: 48,
              //child: getLoader(),
              child: Text("loading"),
            );
          }
        },
      );
    });
  }

  Future filterSheet() {
    return showMaterialModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        expand: false,
        isDismissible: true,
        context: context,
        builder: (context) {
          return sheetBuilder(widget.user!);
        });
  }

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
              child: InkWell(
                onLongPress: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  // copied successfully
                },
                child: Text(
                  value,
                  maxLines: 10,
                  //softWrap: true,
                  textWidthBasis: TextWidthBasis.parent,
                  //overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
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
    TextStyle labelStyle = Theme.of(context).textTheme.labelMedium!;
    double size = 65.0;
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
                    style: labelStyle,
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
                    style: labelStyle,
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
                    style: labelStyle,
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
              launchUrl(Uri.parse(widget.resource.website!));
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
                    style: labelStyle,
                  )
                ],
              ),
            ),
          );
        }

      case "Client":
        {
          return FutureBuilder(
            future: widget.proxyModel.listUserClients(widget.user!),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  for (Client client in snapshot.data) {
                    bool isHere = (client.resources != null &&
                        (client.resources!.contains(widget.resource.id)));
                    widget.clientsList[client] = isHere;
                  }
                  return InkWell(
                    onTap: () async {
                      await filterSheet();
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
                            style: labelStyle,
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return SizedBox(
                    height: size,
                    width: size,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error),
                        getSpacer(4),
                        Text(
                          "No User",
                          style: labelStyle,
                        )
                      ],
                    ),
                  );
                }
              } else {
                return SizedBox(
                  height: size,
                  width: size,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingIndicator(size: size / 3, borderWidth: 2),
                      getSpacer(4),
                      Text(
                        "Loading",
                        style: labelStyle,
                      )
                    ],
                  ),
                );
              }
            },
          );
        }

      default:
        {
          return Container();
        }
    }
  }

  Widget tagsBuilder(Iterable<dynamic> categories, BuildContext context) {
    return Wrap(spacing: 4, runSpacing: 0, children: [
      for (String category in categories)
        detailsCategoryLabel(context, category)
    ]);
  }

  Widget getMisc() {
    Map<dynamic, dynamic> miscDetails = {};
    if (widget.resource.multilingual != null && widget.resource.multilingual!) {
      miscDetails["Multilingual"] = true;
    }
    if (widget.resource.accessibility != null &&
        widget.resource.accessibility!) {
      miscDetails["Wheelchair Accessible"] = true;
    }
    if (widget.resource.isActive != null && widget.resource.isActive!) {
      miscDetails["Active"] = true;
    }
    if (widget.resource.isActive != null && !widget.resource.isActive!) {
      miscDetails["Inactive"] = true;
    }

    return tagsBuilder(miscDetails.keys, context);
  }

  bool miscTest() {
    if (widget.resource.multilingual != null && widget.resource.multilingual!) {
      return true;
    }
    return false;
  }

  Widget editButton() {
    return ElevatedButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewResource(resource: widget.resource)));
          setState(() {});
        },
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
          if (widget.resource.id != null) {
            if (value) {
              widget.proxyModel.delFromList(user, widget.resource);
            } else {
              widget.proxyModel.addToList(user, widget.resource);
            }
          }
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

  Widget userBuilder(String elementContext) {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          widget.user = snapshot.data;
          if (elementContext == "fav button") {
            return favoritesButtonBuilder(snapshot.data);
          } else if (elementContext == "client button") {
            return getQuickAction("Client", "");
          } else {
            return sheetBuilder(snapshot.data);
          }
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
          for (var element in favs) {
            if (element.id == widget.resource.id) {
              isFavorite = true;
            }
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
                  children: const [
                    Icon(Icons.error),
                  ],
                )),
          );
        }
      },
    );
  }

  PreferredSizeWidget topHeader() {
    return AppBar(
      leading: BackButton(color: Theme.of(context).appBarTheme.foregroundColor),
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
        widget.resource.phoneNumbers!["primary"] != "") {
      ret.add(getQuickAction("Call", widget.resource.phoneNumbers!['primary']));
    } //phone
    if (widget.resource.email != null) {
      ret.add(getQuickAction("Email", widget.resource.email!));
    } //email
    if (widget.resource.website != null) {
      ret.add(getQuickAction("Web", widget.resource.website!));
    }
    ret.add(userBuilder("client button"));
    //ret.add(getQuickAction("Client", "stuff")); //web
    //client
    return ret;
  }

  Widget getMap() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          FadeInRoute(
            routeName: "/map",
            page: MapPage(false, widget.resource.address!),
          ),
        );
      },
      child: IgnorePointer(
        child: Container(
          foregroundDecoration: BoxDecoration(
            border: Border.all(
                color: Colors.black12,
                width: 2,
                strokeAlign: StrokeAlign.outside),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          height: 250,
          margin: const EdgeInsets.only(bottom: 16),
          child: GoogleMap(
            scrollGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: false,
            zoomControlsEnabled: false,
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
        ),
      ),
    );
  }

  Widget getRecency() {
    DateFormat formatter = DateFormat('MM-dd-yyyy');
    String updatedTime = widget.resource.updatedStamp != null
        ? formatter.format(widget.resource.updatedStamp!).toString()
        : "unknown time";
    String updatedUser = widget.resource.updatedBy != null
        ? widget.resource.updatedBy!.toString()
        : "unknown user";
    int updatedDays =
        DateTime.now().difference(widget.resource.updatedStamp!).inDays;

    String createdTime = widget.resource.createdStamp != null
        ? formatter.format(widget.resource.createdStamp!).toString()
        : "unknown time";
    String createdUser = widget.resource.createdBy != null
        ? widget.resource.createdBy!.toString()
        : "unknown user";
    int createdDays =
        DateTime.now().difference(widget.resource.createdStamp!).inDays;

    String plural(int num) {
      String ret = (num == 1) ? "" : "s";
      return ret;
    }

    return Row(
      children: [
        Column(
          children: [
            Text(
              "updated $updatedDays day${plural(updatedDays)} ago by $updatedUser",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            getSpacer(2),
            Text(
              "created $createdDays day${plural(createdDays)} ago by $createdUser",
              style: Theme.of(context).textTheme.labelMedium,
            )
          ],
        ),
      ],
    );
  }

  Widget resourceHeader() {
    List<Widget> children = [];

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.resource.name!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        userBuilder("fav button"),
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
    children.add(getRecency());
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
    if (miscTest()) {
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
    if (widget.resource.phoneNumbers != null &&
        widget.resource.phoneNumbers!['primary'] != "") {
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
