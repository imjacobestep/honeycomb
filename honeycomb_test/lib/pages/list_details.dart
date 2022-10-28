import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models_old/resource_list.dart';
import 'package:honeycomb_test/utilities.dart';

class ListDetails extends StatefulWidget {
  @override
  ListDetailsState createState() => ListDetailsState();
  ResourceList resourceList;

  ListDetails({required this.resourceList});
}

class ListDetailsState extends State<ListDetails> {
  @override
  void initState() {
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
            Text(widget.resourceList.listName),
            //getSpacer(4),
          ],
        ),
      ),
      body: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: widget.resourceList.resources.length,
        itemBuilder: (BuildContext context, int index) {
          return widget.resourceList.resources[index]
              .getServiceCard(context, "client");
        },
      ),
      //bottomNavigationBar: BottomNavigationBar(items: [],),
    );
  }
}
