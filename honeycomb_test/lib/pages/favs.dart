import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Favs extends StatefulWidget {
  @override
  FavsState createState() => FavsState();
  List<String> favs = [];

  Favs({required this.favs});
}

class FavsState extends State<Favs> {
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
