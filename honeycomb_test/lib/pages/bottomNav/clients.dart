import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/client.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/pages/client_details.dart';
import 'package:honeycomb_test/pages/client_onboarding.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/clients_ui.dart';
import 'package:honeycomb_test/utilities.dart';

// ignore: must_be_immutable
class ClientsPage extends StatefulWidget {
  @override
  ClientsPageState createState() => ClientsPageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  Iterable<dynamic> clientsList = [];

  // ignore: use_key_in_widget_constructors
  ClientsPage();
}

class ClientsPageState extends State<ClientsPage> {
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
          return clientsBuilder(snapshot.data);
        } else {
          return const Center(
            child: Text("No user found"),
          );
        }
      },
    );
  }

  Widget clientsBuilder(MPUser user) {
    return FutureBuilder(
      future: widget.proxyModel.listUserClients(user),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          widget.clientsList = snapshot.data!;
          if (widget.clientsList.isEmpty) {
            return (Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  "No Clients",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Text('Tap the "+ Client" button to make one')
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
              itemCount: widget.clientsList.length,
              itemBuilder: (BuildContext context, int index) {
                return clientCard(context, widget.clientsList.elementAt(index),
                    () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientDetails(
                                client: widget.clientsList.elementAt(index),
                              )));
                  widget.clientsList =
                      await widget.proxyModel.listUserClients(user);
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
        onPressed: () async {
          Client newClient =
              Client(createdStamp: DateTime.now(), resources: []);
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewClient(client: newClient)));
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: const Text(
          "My Clients",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: addButton(),
          ),
        ],
      ),
      body: userBuilder(),
      bottomNavigationBar: customNav(context, 4),
    );
  }
}
