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
            flex: 24,
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
          Expanded(
            flex: 1,
            child: getSpacer(8),
          ),
          //getSpacer(8),
          Expanded(
            flex: 10,
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

  Widget getActiveFilters() {
    List<String> active_filters = [];
    category_filters.forEach((key, value) {
      if (value) {
        active_filters.add(key);
      }
    });
    accessibility_filters.forEach((key, value) {
      if (value) {
        active_filters.add(key);
      }
    });
    eligibility_filters.forEach((key, value) {
      if (value) {
        active_filters.add(key);
      }
    });
    misc_filters.forEach((key, value) {
      if (value) {
        active_filters.add(key);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        children: [
          for (String label in active_filters)
            Chip(
              padding: EdgeInsets.fromLTRB(0, 2, 2, 2),
              label: Text(label),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                category_filters[label] = !category_filters[label]!;
                active_filters.removeWhere((element) => element == label);
              },
            )
        ],
      ),
    );
  }

  Widget getBody(ResourceList resourceList) {
    ResourceList mainList = applyFilters(resourceList);
    return ListView(
      children: [
        Container(
          //width: MediaQuery.of(context).size.width - 50,
          child: getActiveFilters(),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          itemCount: mainList.resources.length,
          itemBuilder: (BuildContext context, int index) {
            return mainList.resources[index].getServiceCard(context, "home");
          },
        )
      ],
    );
  }
}
