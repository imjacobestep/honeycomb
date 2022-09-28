import 'package:flutter/cupertino.dart';
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
    return Container(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Favs"),
          ),
          body: Container(),
          bottomNavigationBar: BottomNavigationBar(
            items: [],
          ),
        ),
      ),
    );
  }
}
