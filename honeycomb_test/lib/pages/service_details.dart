import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProviderEdit extends StatefulWidget {
  @override
  ProviderEditState createState() => ProviderEditState();
  List<String> favs = [];

  ProviderEdit({required this.favs});
}

class ProviderEditState extends State<ProviderEdit> {
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
