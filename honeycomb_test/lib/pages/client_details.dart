// ignore_for_file: use_key_in_widget_constructors

import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/client_onboarding.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  double quickActionSize = 70.0;

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

  Widget agencyButton(String value) {
    return InkWell(
      onTap: () {
        launchUrl(Uri.parse(
            "https://marysplace.agency-software.org/client_display.php?action=show&d=${widget.client.agencyId!}"));
      },
      child: SizedBox(
        height: quickActionSize,
        width: quickActionSize * 1.6,
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
              "Open Agency",
              maxLines: 1,
              style: Theme.of(context).textTheme.labelLarge,
            )
          ],
        ),
      ),
    );
  }

  Widget shareButton(String value) {
    return InkWell(
      onTap: () {
        Share.share(value);
        //launchUrl(Uri.parse(widget.resource.website!));
      },
      child: SizedBox(
        height: quickActionSize,
        width: quickActionSize * 1.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.ios_share_outlined,
              size: 30,
            ),
            getSpacer(8),
            Text(
              "Share",
              style: Theme.of(context).textTheme.labelLarge,
            )
          ],
        ),
      ),
    );
  }

  Widget printButton(List<Resource> resources) {
    return Container();
  }

  Widget getQuickAction(String label, String value) {
    switch (label) {
      case "Open Agency":
        {
          return agencyButton(value);
        }
      case "Share":
        {
          return shareButton(value);
        }

      case "Print":
        {
          return InkWell(
            onTap: () async {
              final pdf = pw.Document();

              pdf.addPage(pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    pw.Text test = pw.Text(value);
                    List<pw.Column> data = [];
                    data.add(pw.Column(children: [pw.Text('stuff')]));

                    return pw.ListView(children: data);

                    return pw.Center(
                      child: pw.Text(value),
                    ); // Center
                  }));
              final output = await getTemporaryDirectory();
              final file =
                  File("${output.path}/${widget.client.alias}_resources.pdf");
              await file.writeAsBytes(await pdf.save());
              Share.shareXFiles([XFile(file.path)]); // Page
            },
            child: SizedBox(
              height: quickActionSize,
              width: quickActionSize * 1.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.print_outlined,
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
      actions.add(getQuickAction("Open Agency", widget.client.agencyId!));
    } //agency
    actions.addAll([
      resourcesBuilder("printButton"),
      resourcesBuilder("shareButton")
      //getQuickAction("Print", "stuff"),
      //getQuickAction("Share", "stuff")
    ]); //share
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
      resourcesBuilder("resourceList")
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

  Widget resourcesBuilder(String elementContext) {
    return FutureBuilder(
      future: widget.proxyModel.listClientResources(widget.client),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data != null && snapshot.data.isNotEmpty) {
            if (elementContext == "resourceList") {
              return resourcesList(snapshot.data);
            } else if (elementContext == "shareButton") {
              List<Resource> resources = [];
              Iterable<dynamic> data = snapshot.data;
              for (var element in data) {
                resources.add(element);
              }
              String toShare = widget.proxyModel.serialize(resources);
              return getQuickAction("Share", toShare);
            } else {
              List<Resource> resources = [];
              Iterable<dynamic> data = snapshot.data;
              for (var element in data) {
                resources.add(element);
              }
              String toShare = widget.proxyModel.serialize(resources);
              return getQuickAction("Print", toShare);
            }
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
