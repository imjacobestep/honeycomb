//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ResourcesPage extends StatefulWidget {
  @override
  ResourcesPageState createState() => ResourcesPageState();
  Proxy proxyModel = Proxy();
  Future<Iterable>? resourceList;

  ResourcesPage();
}

class ResourcesPageState extends State<ResourcesPage> {
  @override
  void initState() {
    widget.resourceList = widget.proxyModel.list("resources");
    super.initState();
  }

  // VARIABLES

  // FUNCTIONS

  // WIDGETS

  List<Widget> getFilters(Map map) {
    List<Widget> ret = [];
    ret.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              onPressed: () {
                resetFilters();
              },
              child: const Text("clear filters")),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
    );
    ret.add(getSpacer(8));

    ret.add(ElevatedButton(
        onPressed: () {
          setState(() {});
          Navigator.pop(context);
        },
        child: const Text("Apply Filters")));
    return ret;
  }

  Widget sheetBuilder() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
      Widget filterChip(String label, bool value) {
        return InkWell(
            borderRadius: BorderRadius.circular(35),
            enableFeedback: true,
            onTap: () {
              setFilter(label, !value);
              setSheetState(() {});
            },
            child: !value
                ? Chip(
                    label: Text(label),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.black12, width: 1),
                  )
                : Chip(
                    side: const BorderSide(color: Colors.transparent, width: 1),
                    backgroundColor: Colors.black,
                    label: Text(
                      label,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ));
      }

      List<Widget> filterSection(Map map) {
        List<Widget> ret = [];
        for (var key in map.keys) {
          if (map[key] != null) {
            ret.add(filterChip(key, map[key]));
          }
        }
        return ret;
      }

      Widget filterHeader() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () {
                  filters.forEach(
                    (key, value) {
                      value.forEach((key, value) {
                        setFilter(key, false);
                      });
                    },
                  );
                  setSheetState(() {});
                },
                child: const Text("clear filters")),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close))
          ],
        );
      }

      Widget applyButton() {
        return ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Apply Filters"));
      }

      List<Widget> buildList() {
        List<Widget> children = [];
        children.add(filterHeader());
        children.add(getSpacer(8));
        filters.forEach((key, value) {
          children.add(Text(key));
          children.add(Wrap(
            spacing: 4,
            children: filterSection(value),
          ));
        });
        children.add(applyButton());
        return children;
      }

      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: buildList(),
      );
    });
  }

  Future filterSheet() {
    return showMaterialModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        expand: false,
        isDismissible: false,
        context: context,
        builder: (context) {
          return sheetBuilder();
        });
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

  Widget getResourceList() {
    return FutureBuilder(
      future: !ifAnyFilters()
          ? widget.resourceList
          : widget.proxyModel.filter("resources", filters),
      builder: (BuildContext context, AsyncSnapshot<Iterable> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData && snapshot.data != null) {
          Iterable testList = snapshot.data!;
          if (testList.isEmpty) {
            return const Center(
              child: Text("No Results"),
            );
          } else {
            for (Resource resource in testList) {
              children.add(resourceCard(context, resource));
            }
          }
        } else {
          children = <Widget>[
            const Padding(
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

  Widget searchBar() {
    return TextField(
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: (text) {
        setState(() {
          if (text == "") {
            widget.resourceList = widget.proxyModel.list("resources");
          } else {
            widget.resourceList = widget.proxyModel.searchResources("text");
          }
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(0),
        isDense: true,
        constraints: const BoxConstraints(maxHeight: 50),
        filled: true,
        hintText: "Search resources...",
        prefixIcon: const Icon(Icons.search_outlined),
        fillColor: Theme.of(context).canvasColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
    );
  }

  Widget headerButton() {
    return ElevatedButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: const [
            SizedBox(height: 50, child: Center(child: Text("Add"))),
            //getSpacer(2),
            Icon(Icons.add_circle)
          ],
        ));
  }

  PreferredSizeWidget topHeader() {
    return AppBar(
      toolbarHeight: 80,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 20, child: searchBar()),
          Expanded(
            flex: 1,
            child: getSpacer(4),
          ),
          Expanded(flex: 8, child: headerButton())
        ],
      ),
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topHeader(),
      body: getResourceList(),
      floatingActionButton: ElevatedButton(
          onPressed: () async {
            await filterSheet();
            setState(() {});
          },
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
