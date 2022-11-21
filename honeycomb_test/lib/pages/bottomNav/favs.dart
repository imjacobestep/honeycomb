import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';

// ignore: must_be_immutable
class FavsPage extends StatefulWidget {
  @override
  FavsPageState createState() => FavsPageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  Iterable<dynamic> favoritesList = [];

  // ignore: use_key_in_widget_constructors
  FavsPage();
}

class FavsPageState extends State<FavsPage> {
  @override
  void initState() {
    resetFilters();
    super.initState();
  }

  Widget userBuilder() {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return favoritesBuilder(snapshot.data);
        } else {
          return const Center(
            child: Text("No user found"),
          );
        }
      },
    );
  }

  Widget favoritesBuilder(MPUser user) {
    return FutureBuilder(
      future: widget.proxyModel.listUserFavorites(user),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          //Iterable favs = snapshot.data!;
          widget.favoritesList = snapshot.data!;
          if (widget.favoritesList.isEmpty) {
            return (Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  "No Favorites",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Text('Tap the "Add +" button to make one')
              ]),
            ));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.favoritesList.length,
              itemBuilder: (BuildContext context, int index) {
                return resourceCard(
                    context, widget.favoritesList.elementAt(index), () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResourceDetails(
                                resource: widget.favoritesList.elementAt(index),
                              )));
                  widget.favoritesList =
                      await widget.proxyModel.listUserFavorites(user);
                  setState(() {});
                });
              },
            ),
          );
        } else {
          return Center(
            child: getLoader(),
          );
        }
      },
    );
  }

  Widget addButton() {
    return ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ResourcesPage()));
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          "My Favorites",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: addButton(),
          ),
        ],
      ),
      body: userBuilder(),
      bottomNavigationBar: customNav(context, 3),
    );
  }
}
