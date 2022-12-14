// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_haptic/haptic.dart';
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
  List<dynamic> resources = [];
  ClientDetails({required this.client});
}

class ClientDetailsState extends State<ClientDetails> {
  @override
  void initState() {
    super.initState();
  }

  // VARIABLES

  double quickActionSize = 70.0;

  // FUNCTIONS

  Future<void> printToPDF(List<dynamic> resources) async {
    // Centralized styles for the shared PDF
    pw.TextStyle nameStyle =
        pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
    pw.TextStyle labelStyle =
        pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.normal);
    pw.TextStyle bodyStyle =
        pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal);
    pw.TextStyle headerStyle =
        pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal);

    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          List<pw.Widget> data = [
            pw.Text("Here are some resources we thought you might find useful!",
                style: headerStyle)
          ];

          for (Resource resource in resources) {
            data.addAll(
                [pw.SizedBox(height: 2), pw.Text(" "), pw.SizedBox(height: 2)]);
            List<pw.Widget> children = [];
            //HEADER
            children.add(pw.Text(resource.name!, style: nameStyle));
            //CATEGORIES
            if (resource.categories != null) {
              children.add(pw.Text("services offered:", style: labelStyle));
              children.add(pw.Wrap(spacing: 4, children: [
                for (var text in resource.categories!)
                  pw.Text("$text,", style: bodyStyle)
              ]));
            }
            //PHONE
            if (resource.phoneNumbers != null) {
              children.add(pw.Text("phone numbers:", style: labelStyle));
              children.add(pw.Column(children: [
                for (String key in resource.phoneNumbers!.keys)
                  pw.Text("$key: ${resource.phoneNumbers![key]}",
                      style: bodyStyle)
              ]));
            }
            //EMAIL
            if (resource.email != null) {
              children.add(pw.Text("email:", style: labelStyle));
              children.add(pw.Text(resource.email!, style: bodyStyle));
            }
            //ADDRESS
            if (resource.address != null) {
              children.add(pw.Text("address:", style: labelStyle));
              children.add(pw.Text(resource.address!, style: bodyStyle));
            }
            //WEBSITE
            if (resource.website != null) {
              children.add(pw.Text("website:", style: labelStyle));
              children.add(pw.Text(resource.website!, style: bodyStyle));
            }
            //NOTES
            if (resource.notes != null) {
              children.add(pw.Text("notes:", style: labelStyle));
              children.add(pw.Text(resource.notes!, style: bodyStyle));
            }
            //ELIGIBILITY
            if (resource.eligibility != null) {
              children.add(pw.Wrap(spacing: 8, children: [
                for (var text in resource.eligibility!)
                  pw.Text("$text,", style: bodyStyle)
              ]));
            }
            //MISC HEADER
            if (resource.multilingual != null ||
                resource.accessibility != null) {
              children.add(pw.Text("misc:", style: labelStyle));
            }
            //LANGUAGE
            if (resource.multilingual != null) {
              children.add(pw.Text(
                  "This resource is${resource.multilingual! ? " " : " not "}multilingual",
                  style: bodyStyle));
            }
            //ACCESSIBILITY
            if (resource.accessibility != null) {
              children.add(pw.Text(
                  "This resource is${resource.accessibility! ? " " : " not "}wheelchair accessible",
                  style: bodyStyle));
            }

            data.add(pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: children));
          }
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start, children: data);
        }));
    final output = await getTemporaryDirectory();
    final file = File(
        "${output.path}/${widget.client.alias}_${DateTime.now()}_resources.pdf");
    await file.writeAsBytes(await pdf.save());
    Share.shareXFiles([XFile(file.path)]);
  }

  // LOADERS (wait on an asynchronous item, then return a Widget)

  Widget resourcesLoader(String elementContext) {
    return FutureBuilder(
      future: widget.proxyModel.listClientResources(widget.client),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data != null && snapshot.data.isNotEmpty) {
            widget.resources = snapshot.data;
            if (elementContext == "resourceList") {
              return resourcesList(snapshot.data);
            } else if (elementContext == "shareButton") {
              List<Resource> resources = [];
              Iterable<dynamic> data = snapshot.data;
              for (var element in data) {
                resources.add(element);
              }
              String toShare = widget.proxyModel.serialize(resources);
              return quickActionButton("Share", toShare);
            } else {
              List<Resource> resources = [];
              Iterable<dynamic> data = snapshot.data;
              for (var element in data) {
                resources.add(element);
              }
              String toShare = widget.proxyModel.serialize(resources);
              return quickActionButton("Print", toShare);
            }
          } else {
            if (elementContext == "resourceList") {
              return helperText("This Client has no resources",
                  "Try adding some from the List page", context, true);
            } else if (elementContext == "shareButton") {
              return SizedBox(
                height: quickActionSize,
                width: quickActionSize * 1.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.ios_share_outlined,
                      color: Colors.black26,
                      size: 30,
                    ),
                    getSpacer(8),
                    Text(
                      "Share",
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
                          fontStyle:
                              Theme.of(context).textTheme.labelLarge!.fontStyle,
                          color: Colors.black26),
                    )
                  ],
                ),
              );
            } else {
              return SizedBox(
                height: quickActionSize,
                width: quickActionSize * 1.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.print_disabled_outlined,
                      color: Colors.black26,
                      size: 30,
                    ),
                    getSpacer(8),
                    Text(
                      "Print",
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
                          fontStyle:
                              Theme.of(context).textTheme.labelLarge!.fontStyle,
                          color: Colors.black26),
                    )
                  ],
                ),
              );
            }
          }
        } else {
          return const LoadingIndicator(size: 50, borderWidth: 4);
        }
      },
    );
  }

  // UI WIDGETS

  Widget clientElement(String label, String value) {
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
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onLongPress: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  Haptic.onSuccess();
                  showToast("$label copied to clipboard",
                      Theme.of(context).primaryColor);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
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

  Widget quickActionButton(String label, String value) {
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
              printToPDF(widget.resources);
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

  Widget quickActionsBar() {
    List<Widget> actions = [];
    if (widget.client.agencyId != null) {
      actions.add(quickActionButton("Open Agency", widget.client.agencyId!));
    } //agency
    actions.addAll([
      resourcesLoader("printButton"),
      resourcesLoader("shareButton")
    ]); //share
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: actions);
  }

  Widget pageBody() {
    List<Widget> bodyElements = [];
    bodyElements.addAll([
      clientHeader(),
      getDivider(context),
      quickActionsBar(),
      getDivider(context),
    ]);

    if (widget.client.agencyId != null) {
      bodyElements.add(clientElement("Agency ID", widget.client.agencyId!));
    }
    if (widget.client.familySize != null) {
      bodyElements.add(
          clientElement("Family Size", widget.client.familySize!.toString()));
    }
    if (widget.client.notes != null) {
      bodyElements.add(clientElement("Notes", widget.client.notes!));
    }
    bodyElements.addAll([
      getDivider(context),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [const Text("Resources"), addResourcesButton()],
      ),
      getSpacer(8),
      resourcesLoader("resourceList")
    ]);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: bodyElements,
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
        editClientButton()
      ],
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

  Widget editClientButton() {
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

  Widget addResourcesButton() {
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

  PreferredSizeWidget pageHeader() {
    return AppBar(
      leading: BackButton(color: Theme.of(context).appBarTheme.foregroundColor),
      title: const Text("Client Details"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: pageHeader(), body: pageBody());
  }
}
