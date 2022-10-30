import 'package:flutter/material.dart';

class ServiceEdit extends StatefulWidget {
  @override
  ServiceEditState createState() => ServiceEditState();
  List<String> favs = [];

  ServiceEdit({required this.favs});
}

class ServiceEditState extends State<ServiceEdit> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Favs"),
        ),
        body: Container(),
        bottomNavigationBar: BottomNavigationBar(
          items: const [],
        ),
      ),
    );
  }
}
