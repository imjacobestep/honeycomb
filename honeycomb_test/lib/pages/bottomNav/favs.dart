import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_list.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';

class FavsPage extends StatefulWidget {
  @override
  FavsPageState createState() => FavsPageState();
  ResourceList mainList;

  FavsPage({required this.mainList});
}

class FavsPageState extends State<FavsPage> {
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
          "Favs",
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: widget.mainList.resources.length,
        itemBuilder: (BuildContext context, int index) {
          return widget.mainList.resources[index]
              .getServiceCard(context, "favs");
        },
      ),
      bottomNavigationBar: customNav(context, 3),
    );
  }
}
