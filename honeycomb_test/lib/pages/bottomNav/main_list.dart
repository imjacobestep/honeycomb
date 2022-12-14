//import 'package:flutter/cupertino.dart';
// ignore_for_file: unnecessary_null_comparison, must_be_immutable, use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/pages/resource_onboarding.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ResourcesPage extends StatefulWidget {
  @override
  ResourcesPageState createState() => ResourcesPageState();
  Proxy proxyModel = Proxy();
  Future<Iterable>? resourceList;
  String userID = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController searchController = TextEditingController();
  List<Widget> resourcesToShow = [];

  ResourcesPage();
}

class ResourcesPageState extends State<ResourcesPage> {
  @override
  void initState() {
    widget.resourceList = widget.proxyModel.list("resources");
    super.initState();
  }

  @override
  void dispose() {
    filters.forEach(
      (key, value) {
        value.forEach((key, value) {
          setFilter(key, false);
        });
      },
    );
    widget.searchController.dispose();
    super.dispose();
  }

  // VARIABLES
  var sortCriteria = ['name', 'date created', 'date updated'];
  var sortOrder = ['ascending', 'descending'];
  String defaultSortCriteria = 'name';
  String defaultSortOrder = "ascending";

  // FUNCTIONS

  // LOADERS (wait on an asynchronous item, then return a Widget)

  Widget resourceListLoader() {
    return FutureBuilder(
      future: howManyFilters() == 0
          ? widget.resourceList
          : widget.proxyModel.filter("resources", getFilterQuery()),
      builder: (BuildContext context, AsyncSnapshot<Iterable> snapshot) {
        List<Widget> children = [getSpacer(52)];
        //children.add(getSpacer(52));
        if (snapshot.hasData && snapshot.data != null) {
          bool sortOrder = defaultSortOrder == "ascending" ? true : false;
          Iterable testList = widget.proxyModel
              .sort(snapshot.data!, defaultSortCriteria, sortOrder);
          if (testList.isEmpty) {
            String helper = howManyFilters() != 0 ? "filters" : "search terms";
            children.addAll([
              getSpacer(16),
              helperText(
                  "No Results", "Try changing your $helper", context, true)
            ]);
          } else {
            children.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "  ${testList.where((element) => element.name != "").length} resources found"),
                Text("${howManyFilters()} filter${getPlural(howManyFilters())}")
              ],
            ));
            for (Resource resource in testList) {
              if (resource.name != null && resource.name != "") {
                children.add(resourceCard(context, resource, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResourceDetails(
                                resource: resource,
                              )));
                }));
              }
            }
          }
        } else {
          children = <Widget>[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Error"),
            )
          ];
        }
        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              widget.resourceList = widget.proxyModel.list("resources");
            });
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 120),
            children: children,
          ),
        );
      },
    );
  }

  Widget userLoader() {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          MPUser user = snapshot.data!;
          return newResourceButton(user);
        } else {
          return Center(
            child: ElevatedButton(
                onPressed: () {}, child: const Icon(Icons.error)),
          );
        }
      },
    );
  }

  // UI WIDGETS

  Future filterSheet() {
    return showMaterialModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        expand: false,
        isDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setSheetState) {
            Widget filterChip(String label, bool value) {
              return InkWell(
                  borderRadius: BorderRadius.circular(35),
                  enableFeedback: true,
                  onTap: () {
                    Haptic.onSelection;
                    setFilter(label, !value);
                    setSheetState(() {});
                  },
                  child: !value
                      ? Chip(
                          label: Text(
                            label,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          backgroundColor: Colors.transparent,
                          side:
                              const BorderSide(color: Colors.black12, width: 1),
                        )
                      : Chip(
                          side: const BorderSide(
                              color: Colors.transparent, width: 1),
                          backgroundColor: Colors.black,
                          label: Text(
                            label,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .fontSize,
                                fontStyle: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .fontStyle),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Apply Filters",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ));
            }

            List<Widget> buildList() {
              List<Widget> children = [];
              children.add(filterHeader());
              children.add(getSpacer(0));
              filters.forEach((key, value) {
                children.add(getDivider(context));
                children.add(Text(key));
                children.add(Wrap(
                  spacing: 4,
                  children: filterSection(value),
                ));
              });
              children.add(getSpacer(16));
              children.add(applyButton());
              return children;
            }

            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: buildList(),
            );
          });
        });
  }

  Widget searchBar() {
    return TextField(
      controller: widget.searchController,
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: (text) {
        setState(() {
          if (text == "" || text == null) {
            widget.resourceList = widget.proxyModel.list("resources");
          } else {
            widget.resourceList = widget.proxyModel.searchResources(text);
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
        suffixIcon: widget.searchController.text != ""
            ? IconButton(
                onPressed: () {
                  widget.searchController.clear;
                  setState(() {
                    widget.searchController.clear();
                    widget.resourceList = widget.proxyModel.list("resources");
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
    );
  }

  Widget newResourceButton(MPUser user) {
    return ElevatedButton(
        onPressed: () async {
          Resource res =
              makeNewResource(FirebaseAuth.instance.currentUser!.displayName!);
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewResource(resource: res)));
          setState(() {
            widget.resourceList = widget.proxyModel.list("resources");
          });
        },
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

  PreferredSizeWidget pageHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 20, child: searchBar()),
          Expanded(
            flex: 1,
            child: getSpacer(4),
          ),
          Expanded(flex: 8, child: userLoader())
        ],
      ),
    );
  }

  Widget filterAndSortOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 60,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  //color: const Color(0xFFFFC700)
                  border: Border.all(width: 2, color: const Color(0xFFE7E7E7)),
                  color: Theme.of(context).cardTheme.color),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                    style: Theme.of(context).textTheme.labelLarge,
                    isDense: true,
                    underline: Container(),
                    value: defaultSortCriteria,
                    items: sortCriteria.map((String item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        defaultSortCriteria = newValue!;
                      });
                    }),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                //color: const Color(0xFFFFC700)
                border: Border.all(width: 2, color: const Color(0xFFE7E7E7)),
                color: Theme.of(context).cardTheme.color,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                    style: Theme.of(context).textTheme.labelLarge,
                    isDense: true,
                    underline: Container(),
                    value: defaultSortOrder,
                    items: sortOrder.map((String item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        defaultSortOrder = newValue!;
                      });
                    }),
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: howManyFilters() == 0
                        ? Theme.of(context).cardTheme.color
                        : const Color(0xFFFFC700),
                    side: const BorderSide(width: 2, color: Color(0xFFE7E7E7))
                    /* side: !ifAnyFilters()
                        ? null
                        : const BorderSide(color: Colors.black, width: 4) */
                    ),
                onPressed: () async {
                  await filterSheet();
                  setState(() {});
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "filters",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    getSpacer(4),
                    const Icon(Icons.filter_list_outlined)
                  ],
                )),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      appBar: pageHeader(),
      body: resourceListLoader(),
      floatingActionButton: filterAndSortOptions(),
      bottomNavigationBar: customNav(context, 2),
    );
  }
}
