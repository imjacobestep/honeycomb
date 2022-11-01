//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:bottom_sheet_bar/bottom_sheet_bar.dart';

class ResourcesPage extends StatefulWidget {
  @override
  ResourcesPageState createState() => ResourcesPageState();
  BottomSheetBarController sheetCont = BottomSheetBarController();
  Proxy proxyModel = Proxy();
  Iterable? unfilteredList;
  Iterable? filteredList;

  ResourcesPage();
}

class ResourcesPageState extends State<ResourcesPage> {
  @override
  void initState() {
    //loadData();
    //BottomSheetBarController sheetCont;
    super.initState();
  }

  Widget filterChip(String label, bool value) {
    if (value) {
      return InkWell(
        onTap: () {
          filters["Categories"]![label] = false;
          setState(() {});
          //filterSheet(true);
        },
        child: Chip(
          label: Text(label),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          filters["Categories"]![label] = true;
          setState(() {});
        },
        child: Chip(
          label: Text(label),
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.black12, width: 1),
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
      body: getList(getActiveFilters()),
      expandedBuilder: (scrollController) => ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) =>
            ListTile(title: Text(index.toString())),
        itemCount: 50,
      ),
      collapsed: TextButton(
        child: const Text("Open Sheet"),
        onPressed: () {
          widget.sheetCont.expand();
        },
      ),
    );
  }

  List<Widget> getFilters() {
    List<Widget> ret = [];
    ret.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [IconButton(onPressed: () {}, icon: const Icon(Icons.close))],
      ),
    );
    filters.forEach((key, value) {
      ret.add(Text(key));
      ret.add(Wrap(
        children: filterType(value),
      ));
    });
    ret.add(ElevatedButton(
        onPressed: () {
          setState(() {});
        },
        child: const Text("Apply Filters")));
    return ret;
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
        children: getFilters(),
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
              padding: const EdgeInsets.fromLTRB(0, 2, 2, 2),
              label: Text(label),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                filters.forEach((key, value) {
                  value.forEach((key, value) {
                    if (key == label) {
                      value = !value;
                    }
                  });
                });
                activeFilters.removeWhere((element) => element == label);
                setState(() {});
              },
            )
        ],
      ),
    );
  }

  List<String> getActiveFilters() {
    List<String> activeFilters = [];

    filters.forEach((key, value) {
      value.forEach((key, value) {
        if (value) {
          activeFilters.add(key);
        }
      });
    });
    return activeFilters;
  }

  Widget getList2(List<String> activeFilters, Future<Iterable> unfilteredList) {
    return FutureBuilder(
      future: unfilteredList,
      builder: (BuildContext context, AsyncSnapshot<Iterable> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData && snapshot.data != null) {
          //print(snapshot.data.runtimeType);
          Iterable testList = snapshot.data!;
          for (Resource resource in testList) {
            children.add(resourceCard(context, resource));
          }
          //children = <Widget>[resourceCard(context, snapshot.data as Resource)];
        } else {
          children = <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Text("No Results"),
            )
          ];
        }
        return ListView(
          children: children,
        );
      },
    );
  }

  Widget getList(List<String> activeFilters) {
    //cases: no filters, filteres with resources, filters with no resources
    if (widget.filteredList != null &&
        widget.filteredList!.isEmpty &&
        activeFilters.isNotEmpty) {
      return const Center(
        child: Text("no values, change filters"),
      );
    } else if (widget.filteredList!.isNotEmpty && activeFilters.isNotEmpty) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: widget.filteredList!.length,
        itemBuilder: (BuildContext context, int index) {
          return resourceCard(context, widget.unfilteredList!.elementAt(index));
        },
      );
    } else {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: widget.unfilteredList!.length,
        itemBuilder: (BuildContext context, int index) {
          return resourceCard(context, widget.unfilteredList!.elementAt(index));
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
                  constraints: const BoxConstraints(maxHeight: 50),
                  filled: true,
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search_outlined),
                  fillColor: Theme.of(context).canvasColor,
                  border: const OutlineInputBorder(
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
                    children: const [
                      SizedBox(height: 50, child: Center(child: Text("Add"))),
                      //getSpacer(2),
                      Icon(Icons.add_circle_outline)
                    ],
                  )),
            )
          ],
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
      ),
      //body: getList2(getActiveFilters(), widget.proxyModel.list('resources')),
      body: getList2(
          getActiveFilters(), widget.proxyModel.filter('resources', filters)),
      //body: filterSheet2(),
      floatingActionButton: ElevatedButton(
          onPressed: () async {
            await filterSheet(false);
            setState(() {});
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
