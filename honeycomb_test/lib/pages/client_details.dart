import 'package:flutter/material.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';

import '../model/client.dart';

class ListDetails extends StatefulWidget {
  @override
  ListDetailsState createState() => ListDetailsState();
  Proxy proxyModel = Proxy();
  Client client;
  Iterable? resources;
  ListDetails({required this.client});
}

class ListDetailsState extends State<ListDetails> {
  @override
  Future<void> initState() async {
    widget.resources =
        await widget.proxyModel.listClientResources(widget.client);
    super.initState();
  }

  Widget detailListing(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.client.alias!),
            //getSpacer(4),
          ],
        ),
      ),
      body: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: widget.resources!.length,
        itemBuilder: (BuildContext context, int index) {
          return resourceCard(context, widget.resources!.elementAt(index), () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ServiceDetails(
                          resource: widget.resources!.elementAt(index),
                        )));
          });
        },
      ),
      //bottomNavigationBar: BottomNavigationBar(items: [],),
    );
  }
}
