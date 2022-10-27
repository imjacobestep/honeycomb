import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_list.dart';
import 'package:honeycomb_test/pages/bottomNav/clients.dart';
import 'package:honeycomb_test/pages/bottomNav/favs.dart';
import 'package:honeycomb_test/pages/bottomNav/home.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/bottomNav/map.dart';
import 'package:honeycomb_test/utilities.dart';

List<String> labels = ["Home", "Map", "List", "Favs", "Clients"];
List<Icon> icons = [
  const Icon(Icons.home_outlined),
  const Icon(Icons.map_outlined),
  const Icon(Icons.list),
  const Icon(Icons.star_outline),
  const Icon(Icons.people_alt_outlined)
];

TextStyle labelStyle = TextStyle(color: Colors.grey[600]);
Widget customNav(context, currentIndex) {
  List<CustomNavigationBarItem> items = [
    CustomNavigationBarItem(
        icon: icons[0],
        title: Text(
          labels[0],
          style: labelStyle,
        )),
    CustomNavigationBarItem(
        icon: icons[1],
        title: Text(
          labels[1],
          style: labelStyle,
        )),
    CustomNavigationBarItem(
        icon: icons[2],
        title: Text(
          labels[2],
          style: labelStyle,
        )),
    CustomNavigationBarItem(
        icon: icons[3],
        title: Text(
          labels[3],
          style: labelStyle,
        )),
    CustomNavigationBarItem(
        icon: icons[4],
        title: Text(
          labels[4],
          style: labelStyle,
        )),
  ];

  void goToNav(index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      mainList: buildTest(),
                    )));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MapPage(
                      mainList: buildTest(),
                    )));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ResourcesPage(
                      mainList: buildTest(),
                    )));
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => FavsPage(
                      mainList: buildTest(),
                    )));
        break;
      case 4:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ClientsPage(
                      mainList: buildTest(),
                    )));
        break;
      default:
    }
  }

  return CustomNavigationBar(
    items: items,
    //blurEffect: true,
    //opacity: 1,
    iconSize: 26,
    isFloating: true,
    selectedColor: Theme.of(context).colorScheme.primary,
    strokeColor: Colors.white,
    unSelectedColor: Colors.grey[600],
    backgroundColor: const Color(0xFF2B2A2A),
    borderRadius: const Radius.circular(30.0),
    currentIndex: currentIndex,
    onTap: (index) {
      if (currentIndex != index) {
        goToNav(index);
      }
    },
  );
}
