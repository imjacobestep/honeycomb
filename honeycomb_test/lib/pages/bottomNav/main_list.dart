import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_list.dart';
import 'package:honeycomb_test/utilities.dart';

class MainList {
  BuildContext context;

  MainList({required this.context});

  PreferredSizeWidget getAppBar() {
    return AppBar(
      toolbarHeight: 80,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
                onPressed: () {},
                child: Row(
                  children: [
                    const Icon(Icons.search_outlined),
                    getSpacer(4),
                    const Text("Search")
                  ],
                )),
          ),
          getSpacer(8),
          Expanded(
            flex: 1,
            child: ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text("Add"),
                    getSpacer(4),
                    const Icon(Icons.add_circle_outline)
                  ],
                )),
          )
        ],
      ),
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
    );
  }

  Widget getBody(ResourceList resourceList) {
    ResourceList mainList = applyFilters(resourceList);
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: mainList.resources.length,
      itemBuilder: (BuildContext context, int index) {
        return mainList.resources[index].getServiceCard(context, "home");
      },
    );
  }
}
