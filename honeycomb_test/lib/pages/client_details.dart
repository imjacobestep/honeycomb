// ignore_for_file: use_key_in_widget_constructors

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/client_onboarding.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/client.dart';

// ignore: must_be_immutable
class ClientDetails extends StatefulWidget {
  bool enableAgencyButton = true; // AGENCY BUTTON SWITCH
  @override
  ClientDetailsState createState() => ClientDetailsState();
  Proxy proxyModel = Proxy();
  Client client;
  ClientDetails({required this.client});
}

class ClientDetailsState extends State<ClientDetails> {
  @override
  void initState() {
    super.initState();
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
                style: Theme.of(context).textTheme.bodyText2,
              ),
              getSpacer(4),
              Row(
                children: [
                  getSpacer(8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget getQuickAction(String label, String value) {
    double size = 70.0;
    switch (label) {
      case "Open in Agency":
        {
          return InkWell(
            onTap: () {
              launchUrl(Uri.parse(
                  "https://marysplace.agency-software.org/client_display.php?action=show&d=${widget.client.agencyId!}"));
            },
            child: SizedBox(
              height: size,
              width: size * 1.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "lib/assets/agency_button.png",
                    width: 40,
                    height: 40,
                  ),
                  //getSpacer(4),
                  Text(
                    label,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
              ),
            ),
          );
        }
      case "Share":
        {
          return InkWell(
            onTap: () {
              //launchUrl(Uri.parse(widget.resource.website!));
            },
            child: SizedBox(
              height: size,
              width: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.ios_share_outlined,
                    size: 30,
                  ),
                  getSpacer(8),
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

  Widget quickActionsBuilder() {
    List<Widget> actions = [];
    if (widget.client.agencyId != null) {
      actions.add(getQuickAction("Open in Agency", widget.client.agencyId!));
    } //agency
    actions.add(getQuickAction("Share", "stuff")); //share
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: actions);
  }

  Widget detailsBuilder() {
    List<Widget> children = [];
    children.addAll([
      clientHeader(),
      getDivider(context),
      quickActionsBuilder(),
      getDivider(context),
    ]);

    if (widget.client.agencyId != null) {
      children.add(detailListing("Agency ID", widget.client.agencyId!));
    }
    if (widget.client.familySize != null) {
      children.add(
          detailListing("Family Size", widget.client.familySize!.toString()));
    }
    if (widget.client.notes != null) {
      children.add(detailListing("Notes", widget.client.notes!));
    }
    children.addAll([
      getDivider(context),
      resourceHeader(),
      getSpacer(8),
      resourcesBuilder()
    ]);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }

  Widget clientHeader() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.client.alias!,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        editButton()
      ],
    );
  }

  Widget resourcesBuilder() {
    return FutureBuilder(
      future: widget.proxyModel.listClientResources(widget.client),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data != null && snapshot.data.isNotEmpty) {
            return resourcesList(snapshot.data);
          } else {
            return helperText("This Client has no resources",
                "Try adding some from the List page", context, true);
          }
        } else {
          return const LoadingIndicator(size: 50, borderWidth: 4);
        }
      },
    );
  }

  Widget resourcesList(List<dynamic> resources) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: resources.length,
      itemBuilder: (BuildContext context, int index) {
        return resourceCard(context, resources.elementAt(index), () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ResourceDetails(
                        resource: resources.elementAt(index),
                      )));
        });
      },
    );
  }

  Widget resourceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [const Text("Resources"), addButton()],
    );
  }

  Widget editButton() {
    return ElevatedButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewClient(client: widget.client)));
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

  Widget addButton() {
    return ElevatedButton(
        onPressed: () async {
          await Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ResourcesPage()));
          setState(() {});
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Add"),
            getSpacer(8),
            const Icon(Icons.add_circle),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading:
              BackButton(color: Theme.of(context).appBarTheme.foregroundColor),
          title: const Text("Client Details"),
        ),
        body: detailsBuilder()
        //bottomNavigationBar: BottomNavigationBar(items: [],),
        );
  }
}
