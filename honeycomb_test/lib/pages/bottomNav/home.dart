// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:honeycomb_test/model/client.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/client_details.dart';
import 'package:honeycomb_test/pages/client_onboarding.dart';
import 'package:honeycomb_test/ui_components/clients_ui.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../proxy.dart';
import '../../ui_components/animated_navigator.dart';
import '../../utilities.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:bottom_sheet_bar/bottom_sheet_bar.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  MPUser? user;
  Iterable? favs;
  Iterable? clients;
  BottomSheetBarController sheetCont = BottomSheetBarController();

  HomePage();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    resetFilters();
    super.initState();
  }

  Widget sectionHeader(String header, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8, 0, 0),
      child: Text(
        header,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget filterCard(IconData icon, String label) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(width: 2, color: Color(0xFFE7E7E7))),
      child: InkWell(
        onTap: () {
          filters["Categories"]![label] = !filters["Categories"]![label]!;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ResourcesPage()));
        },
        onLongPress: () {
          resetFilters();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon),
              getSpacer(10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget clientsBuilder(MPUser user) {
    return FutureBuilder(
      future: widget.proxyModel.listUserClients(user),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          Iterable clients = snapshot.data!;
          clients = widget.proxyModel.sort(clients, "updatedStamp", false);
          if (clients.isEmpty) {
            return (const Center(
              child: Text("No Clients Found"),
            ));
          }
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return clientCard(context, clients.elementAt(index), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClientDetails(
                              client: clients.elementAt(index),
                            )));
              });
            },
          );
        } else {
          return getLoader();
        }
      },
    );
  }

  Widget greetingBuilder(MPUser user) {
    String name = FirebaseAuth.instance.currentUser!.displayName != null
        ? FirebaseAuth.instance.currentUser!.displayName!
        : "user";
    return Text(
      "Hi, $name",
      style: Theme.of(context)
          .textTheme
          .headlineMedium!
          .copyWith(color: Colors.white),
    );
  }

  Widget userBuilder(String component) {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          MPUser user = snapshot.data!;
          switch (component) {
            case "clients":
              return clientsBuilder(user);
            case "greeting":
              return greetingBuilder(user);
            default:
              return const Center(
                child: Text("error"),
              );
          }
        } else {
          return const Center(
            child: Text("No user found"),
          );
        }
      },
    );
  }

  PreferredSizeWidget topHeader() {
    return AppBar(
      toolbarHeight: 80,
      leadingWidth: 80,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          "lib/assets/icon/icon.png",
          width: 80,
          height: 80,
        ),
      ),
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Honeycomb",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          userBuilder("greeting")
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
              )),
        )
      ],
    );
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
                    label: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.black12, width: 1),
                  )
                : Chip(
                    side: const BorderSide(color: Colors.transparent, width: 1),
                    backgroundColor: Colors.black,
                    label: Text(
                      label,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: topHeader(),
      body: ListView(
        children: [
          sectionHeader("Find by Category", context),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            childAspectRatio: 3.5,
            children: [
              filterCard(Icons.home_work_outlined, "Shelter"),
              filterCard(Icons.house_outlined, "Housing"),
              filterCard(Icons.food_bank_outlined, "Food"),
              filterCard(Icons.medical_services_outlined, "Medical"),
              filterCard(Icons.psychology_outlined, "Mental Health"),
              filterCard(Icons.sports_kabaddi_outlined, "DV"),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.black.withAlpha(30), width: 2),
                        foregroundColor: Colors.black,
                        alignment: Alignment.center),
                    onPressed: () async {
                      await filterSheet();
                      if (ifAnyFilters()) {
                        Navigator.push(
                          context,
                          FadeInRoute(
                            routeName: "/list",
                            page: ResourcesPage(),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_downward_outlined),
                        getSpacer(4),
                        Text("See All")
                      ],
                    )),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
          getDivider(context),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectionHeader("Recent Clients", context),
                ElevatedButton(
                    onPressed: () async {
                      Client newClient =
                          Client(createdStamp: DateTime.now(), resources: []);
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NewClient(client: newClient)));
                      setState(() {});
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Add"),
                        getSpacer(8),
                        const Icon(Icons.add_circle),
                      ],
                    ))
              ],
            ),
          ),
          userBuilder("clients"),
        ],
      ),
      bottomNavigationBar: customNav(context, 0),
    );
  }
}
