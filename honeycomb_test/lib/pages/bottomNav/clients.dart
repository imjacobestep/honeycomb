import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/clients_ui.dart';

class ClientsPage extends StatefulWidget {
  @override
  ClientsPageState createState() => ClientsPageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  MPUser? user;
  Iterable? clients;

  ClientsPage();
}

class ClientsPageState extends State<ClientsPage> {
  @override
  Future<void> initState() async {
    widget.user = await widget.proxyModel.getUser(widget.userID);
    widget.clients = await widget.proxyModel.listUserClients(widget.user!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: const Text(
          "Clients",
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: widget.clients!.length,
        itemBuilder: (BuildContext context, int index) {
          return clientCard(context, widget.clients!.elementAt(index));
        },
      ),
      bottomNavigationBar: customNav(context, 4),
    );
  }
}
