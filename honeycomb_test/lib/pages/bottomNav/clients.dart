import 'package:flutter/material.dart';
import 'package:honeycomb_test/models_old/resource_list.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';

class ClientsPage extends StatefulWidget {
  @override
  ClientsPageState createState() => ClientsPageState();
  ResourceList mainList;

  ClientsPage({required this.mainList});
}

class ClientsPageState extends State<ClientsPage> {
  @override
  void initState() {
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
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return widget.mainList.getCard(context);
        },
      ),
      bottomNavigationBar: customNav(context, 4),
    );
  }
}
