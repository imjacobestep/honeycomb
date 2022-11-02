import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/user.dart';
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

  Widget filterCard(IconData icon, String label) {
    return Card(
      child: InkWell(
        onTap: () {
          filters["Categories"]![label] = !filters["Categories"]![label]!;
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
            itemCount: clients.length,
            itemBuilder: (BuildContext context, int index) {
              return clientCard(context, clients.elementAt(index));
            },
          );
        } else {
          return const Center(
            child: Text("Error"),
          );
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

  Widget listsBuilder() {
    return Container();
  }

  PreferredSizeWidget topHeader() {
    return AppBar(
      toolbarHeight: 80,
      leadingWidth: 80,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      leading: Padding(
        padding: EdgeInsets.all(8),
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
          padding: EdgeInsets.all(16),
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
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topHeader(),
      body: ListView(
        children: [
          sectionHeader("Find by Category", context),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            childAspectRatio: 2,
            children: [
              filterCard(Icons.home_work, "Shelter"),
              filterCard(Icons.sports_kabaddi, "Domestic Violence"),
              filterCard(Icons.psychology, "Mental Health"),
              filterCard(Icons.food_bank, "Food"),
              filterCard(Icons.medical_services, "Medical Help"),
              filterCard(Icons.gavel, "Legal"),
            ],
          ),
          getDivider(context),
          sectionHeader("Recent Clients", context),
          listsBuilder(),
          getDivider(context),
          sectionHeader("Favorites", context),
          listsBuilder(),
        ],
      ),
      bottomNavigationBar: customNav(context, 0),
    );
  }
}
