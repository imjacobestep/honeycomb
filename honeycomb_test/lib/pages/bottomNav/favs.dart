import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';

class FavsPage extends StatefulWidget {
  @override
  FavsPageState createState() => FavsPageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  MPUser? user;
  Iterable? favs;

  FavsPage();
}

class FavsPageState extends State<FavsPage> {
  @override
  Future<void> initState() async {
    widget.user = await widget.proxyModel.getUser(widget.userID);
    widget.favs = await widget.proxyModel.listUserFavorites(widget.user!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: const Text(
          "Favs",
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: widget.favs!.length,
        itemBuilder: (BuildContext context, int index) {
          return resourceCard(context, widget.favs!.elementAt(index));
        },
      ),
      bottomNavigationBar: customNav(context, 3),
    );
  }
}
