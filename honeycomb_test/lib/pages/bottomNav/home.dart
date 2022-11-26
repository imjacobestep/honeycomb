// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/client.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/client_details.dart';
import 'package:honeycomb_test/pages/client_onboarding.dart';
import 'package:honeycomb_test/ui_components/clients_ui.dart';
import '../../proxy.dart';
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
