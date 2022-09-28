import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Lists extends StatefulWidget {
  @override
  ListsState createState() => ListsState();
  List<String> favs = [];

  Lists({required this.favs});
}

class ListsState extends State<Lists> {
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
