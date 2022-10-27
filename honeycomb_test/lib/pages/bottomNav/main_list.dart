//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_list.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:bottom_sheet_bar/bottom_sheet_bar.dart';

class ResourcesPage extends StatefulWidget {
  @override
  ResourcesPageState createState() => ResourcesPageState();
  ResourceList mainList;
  BottomSheetBarController sheetCont = BottomSheetBarController();

  ResourcesPage({required this.mainList});
}

class ResourcesPageState extends State<ResourcesPage> {
  @override
  void initState() {
    //BottomSheetBarController sheetCont;
    super.initState();
  }

  Widget filterChip(String label, bool value) {
    if (value) {
      return InkWell(
        onTap: () {
          category_filters[label] = false;
          filterSheet(true);
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

  filterSheet2() {
    return BottomSheetBar(
      locked: false,
      controller: widget.sheetCont,
      body: getList(
          widget.mainList, applyFilters(widget.mainList), getActiveFilters()),
      expandedBuilder: (scrollController) => ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) =>
            ListTile(title: Text(index.toString())),
        itemCount: 50,
      ),
      collapsed: TextButton(
        child: Text("Open Sheet"),
        onPressed: () {
          widget.sheetCont.expand();
        },
      ),
    );
  }

  Future filterSheet(bool refresh) {
    return showMaterialModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      expand: false,
      context: context,
      duration: Duration(milliseconds: refresh ? 0 : 400),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.close))
            ],
          ),
          const Text("Categories"),
          Wrap(
            children: filterType(category_filters),
          ),
          const Text("Accessibility"),
          Wrap(
            children: filterType(accessibility_filters),
          ),
          const Text("Elegibility Requirements"),
          Wrap(
            children: filterType(eligibility_filters),
          ),
          const Text("Other"),
          Wrap(
            children: filterType(misc_filters),
          ),
          ElevatedButton(onPressed: () {}, child: const Text("Apply Filters"))
        ],
      ),
    );
  }

  Widget showActiveFilters(List<String> activeFilters) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        children: [
          for (String label in activeFilters)
            Chip(
              padding: EdgeInsets.fromLTRB(0, 2, 2, 2),
              label: Text(label),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                category_filters[label] = !category_filters[label]!;
                activeFilters.removeWhere((element) => element == label);
              },
            )
        ],
      ),
    );
  }

  List<String> getActiveFilters() {
    List<String> activeFilters = [];
    category_filters.forEach((key, value) {
      if (value) {
        activeFilters.add(key);
      }
    });
    accessibility_filters.forEach((key, value) {
      if (value) {
        activeFilters.add(key);
      }
    });
    eligibility_filters.forEach((key, value) {
      if (value) {
        activeFilters.add(key);
      }
    });
    misc_filters.forEach((key, value) {
      if (value) {
        activeFilters.add(key);
      }
    });
    return activeFilters;
  }

  Widget getList(ResourceList unfiltered, ResourceList filtered,
      List<String> activeFilters) {
    //cases: no filters, filteres with resources, filters with no resources
    if (filtered.resources.isEmpty && activeFilters.isNotEmpty) {
      return const Center(
        child: Text("no values, change filters"),
      );
    } else if (filtered.resources.isNotEmpty && activeFilters.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 20,
              child: TextField(
                decoration: InputDecoration(
                  constraints: BoxConstraints(maxHeight: 50),
                  filled: true,
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search_outlined),
                  fillColor: Theme.of(context).canvasColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: getSpacer(4),
            ),
            //getSpacer(8),
            Expanded(
              flex: 8,
              child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                          height: 50, child: Center(child: const Text("Add"))),
                      //getSpacer(2),
                      const Icon(Icons.add_circle_outline)
                    ],
                  )),
            )
          ],
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
      ),
      body: getList(
          widget.mainList, applyFilters(widget.mainList), getActiveFilters()),
      //body: filterSheet2(),
      floatingActionButton: ElevatedButton(
          onPressed: () async {
            await filterSheet(false);
          },
          /*onPressed: () {
                    widget.sheetCont.expand();
                  },*/
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filters"),
              getSpacer(4),
              const Icon(Icons.filter_list_outlined)
            ],
          )),
      bottomNavigationBar: customNav(context, 2),
    );
  }
}
