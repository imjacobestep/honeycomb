import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/client.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/pages/client_onboarding.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/clients_ui.dart';
import 'package:honeycomb_test/utilities.dart';

class ClientsPage extends StatefulWidget {
  @override
  ClientsPageState createState() => ClientsPageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;

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
          MPUser user = snapshot.data!;
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
          Iterable clients = snapshot.data!;
          if (clients.isEmpty) {
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
              await Future.delayed(Duration(seconds: 1));
              setState(() {});
            },
            child: ListView.builder(
              //physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              //shrinkWrap: true,
              itemCount: clients.length,
              itemBuilder: (BuildContext context, int index) {
                return clientCard(context, clients.elementAt(index));
              },
            ),
          );
        } else {
          return const Center(
            child: Text("Error"),
          );
        }
      },
    );
  }

  Widget addButton() {
    return ElevatedButton(
        onPressed: () async {
          Client newClient = Client(createdStamp: DateTime.now());
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
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        title: const Text(
          "My Clients",
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
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
