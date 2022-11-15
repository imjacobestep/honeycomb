//import 'package:flutter/cupertino.dart';
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
    //resetFilters();
    filters.forEach(
      (key, value) {
        value.forEach((key, value) {
          setFilter(key, false);
        });
      },
    );
    super.dispose();
  }

  // VARIABLES
  var sortCriteria = ['name', 'date created', 'date updated'];
  var sortOrder = ['ascending', 'descending'];
  String defaultSortCriteria = 'name';
  String defaultSortOrder = "ascending";

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
              Haptic.onSelection;
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
        children.add(getSpacer(24));
        filters.forEach((key, value) {
          children.add(Text(key));
          children.add(Wrap(
            spacing: 4,
            children: filterSection(value),
          ));
          children.add(getSpacer(8));
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
          : widget.proxyModel.filter("resources", getFilterQuery()),
      builder: (BuildContext context, AsyncSnapshot<Iterable> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData && snapshot.data != null) {
          bool sortOrder = defaultSortOrder == "ascending" ? true : false;
          Iterable testList = widget.proxyModel
              .sort(snapshot.data!, defaultSortCriteria, sortOrder);
          if (testList.isEmpty) {
            //Haptic.onFailure();
            String helper = ifAnyFilters() ? "filters" : "search terms";
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  "No Results",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text("Try changing your $helper"),
                //Text(getFilterQuery().toString())
              ]),
            );
          } else {
            for (Resource resource in testList) {
              if (resource.name != null && resource.name != "") {
                children.add(resourceCard(context, resource, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ServiceDetails(
                                resource: resource,
                              )));
                }));
              }
            }
          }
        } else {
          //Haptic.onFailure();
          children = <Widget>[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Error"),
            )
          ];
        }
        //Haptic.onSuccess;
        return ListView(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
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
      ),
    );
  }

  Widget userBuilder() {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          MPUser user = snapshot.data!;
          return headerButton(user);
        } else {
          return Center(
            child: ElevatedButton(onPressed: () {}, child: Icon(Icons.error)),
          );
        }
      },
    );
  }

  Widget headerButton(MPUser user) {
    return ElevatedButton(
        onPressed: () async {
          Resource res =
              makeNewResource(FirebaseAuth.instance.currentUser!.displayName!);
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewResource(resource: res)));
          setState(() {});
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

  PreferredSizeWidget topHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
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
          Expanded(flex: 8, child: userBuilder())
        ],
      ),
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
    );
  }

  Widget sortOrderDropdown() {
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), color: Color(0xFFFFE93E)),
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
    );
  }

  Widget fabButtons() {
    //return sortOrderDropdown();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Color(0xFFFFE93E)),
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
              color: Color(0xFFFFE93E)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: topHeader(),
      body: getResourceList(),
      floatingActionButton: fabButtons(),
      bottomNavigationBar: customNav(context, 2),
    );
  }
}
