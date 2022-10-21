import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_list.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
            flex: 10,
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
                onPressed: () async {
                  await filterSheet();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text("Filters"),
                    getSpacer(4),
                    const Icon(Icons.filter_list_outlined)
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

  Widget filterChip(String label, bool value) {
    if (value) {
      return InkWell(
        onTap: () {
          category_filters[label] = false;
        },
        child: Chip(
          label: Text(label),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          category_filters[label] = true;
        },
        child: Chip(
          label: Text(label),
          backgroundColor: Colors.transparent,
          side: BorderSide(color: Colors.black12, width: 1),
        ),
      );
    }
  }

  List<Widget> filterType(Map map) {
    List<Widget> ret = [];
    for (var key in map.keys) {
      if (map[key] != null) {
        ret.add(filterChip(key, map[key]!));
      }
    }
    return ret;
  }

  Future filterSheet() {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: [
          Text("Categories"),
          Wrap(
            children: filterType(category_filters),
          ),
          Text("Accessibility"),
          Wrap(
            children: filterType(accessibility_filters),
          ),
          Text("Elegibility Requirements"),
          Wrap(
            children: filterType(eligibility_filters),
          ),
          Text("Other"),
          Wrap(
            children: filterType(misc_filters),
          ),
        ],
      ),
    );
  }

  Widget showActiveFilters(List<String> active_filters) {
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

  List<String> getActiveFilters() {
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
    return active_filters;
  }

  Widget getList(ResourceList unfiltered, ResourceList filtered,
      List<String> active_filters) {
    //cases: no filters, filteres with resources, filters with no resources
    if (filtered.resources.length == 0 && active_filters.length > 0) {
      return Center(
        child: Text("no values, change filters"),
      );
    } else if (filtered.resources.length > 0 && active_filters.length > 0) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: filtered.resources.length,
        itemBuilder: (BuildContext context, int index) {
          return filtered.resources[index].getServiceCard(context, "home");
        },
      );
    } else {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: unfiltered.resources.length,
        itemBuilder: (BuildContext context, int index) {
          return unfiltered.resources[index].getServiceCard(context, "home");
        },
      );
    }
  }

  Widget getBody(ResourceList resourceList) {
    List<String> active_filters = getActiveFilters();
    ResourceList mainList = applyFilters(resourceList);
    return ListView(
      children: [
        Container(
          //width: MediaQuery.of(context).size.width - 50,
          child: showActiveFilters(active_filters),
        ),
        getList(resourceList, mainList, active_filters)
      ],
    );
  }
}
