import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:honeycomb_test/pages/bottomNav/clients.dart';
import 'package:honeycomb_test/pages/bottomNav/favs.dart';
import 'package:honeycomb_test/pages/bottomNav/home.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/bottomNav/map.dart';
import 'package:honeycomb_test/ui_components/animated_navigator.dart';

List<String> labels = ["Home", "Map", "List", "Favs", "Clients"];
List<Icon> icons = [
  const Icon(Icons.home_outlined),
  const Icon(Icons.map_outlined),
  const Icon(Icons.list),
  const Icon(Icons.star_outline),
  const Icon(Icons.people_alt_outlined)
];

TextStyle labelStyle = const TextStyle(color: Colors.white54, fontSize: 14);
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
    Haptic.onSelection();
    switch (index) {
      case 0:
        /* Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage())); */
        Navigator.pushReplacement(
          context,
          FadeInRoute(
            routeName: "/home",
            page: HomePage(),
          ),
        );
        break;
      case 1:
        /* Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MapPage())); */
        Navigator.pushReplacement(
          context,
          FadeInRoute(
            routeName: "/map",
            page: MapPage(true, "12280 NE District Wy, 98005"),
          ),
        );
        break;
      case 2:
        /* Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ResourcesPage())); */
        Navigator.pushReplacement(
          context,
          FadeInRoute(
            routeName: "/list",
            page: ResourcesPage(),
          ),
        );
        break;
      case 3:
        /* Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FavsPage())); */
        Navigator.pushReplacement(
          context,
          FadeInRoute(
            routeName: "/favs",
            page: FavsPage(),
          ),
        );
        break;
      case 4:
        /* Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ClientsPage())); */
        Navigator.pushReplacement(
          context,
          FadeInRoute(
            routeName: "/clients",
            page: ClientsPage(),
          ),
        );
        break;
      default:
    }
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
    child: CustomNavigationBar(
      scaleFactor: 0.44,
      items: items,
      blurEffect: false,
      //opacity: 1,
      iconSize: 28,
      isFloating: true,
      selectedColor: Theme.of(context).colorScheme.primary,
      strokeColor: Colors.white,
      unSelectedColor: Colors.white54,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
      borderRadius: const Radius.circular(50.0),
      currentIndex: currentIndex,
      onTap: (index) {
        if (currentIndex != index) {
          goToNav(index);
        }
      },
    ),
  );
}
