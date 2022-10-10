import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_list.dart';
import 'package:honeycomb_test/pages/bottomNav/favs.dart';
import 'package:honeycomb_test/pages/bottomNav/home.dart';
import 'package:honeycomb_test/pages/bottomNav/clients.dart';
import 'package:honeycomb_test/pages/bottomNav/map.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:material_color_generator/material_color_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Honeycomb',
      theme: ThemeData(
        //useMaterial3: true,
        primarySwatch: generateMaterialColor(color: const Color(0xFFFFE93E)),
      ),
      home: const MyHomePage(title: 'Honeycomb'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  List<String> navs = ["stock", "custom", "snake", "google", "floating", "dot"];
  String dropdownValue = "stock";

  ResourceList resourceList = buildTest();

  List<String> labels = ["Home", "Map", "Resources", "Favs", "Clients"];
  List<Icon> icons = [
    const Icon(Icons.home_outlined),
    const Icon(Icons.map_outlined),
    const Icon(Icons.list),
    const Icon(Icons.star_outline),
    const Icon(Icons.people_alt_outlined)
  ];

  PreferredSizeWidget navAppBar(int index) {
    List<PreferredSizeWidget> bars = [
      Home(context: context).getAppBar(),
      Search(context: context).getAppBar(),
      MainList(context: context).getAppBar(),
      Favs(context: context).getAppBar(),
      Lists(context: context).getAppBar(),
    ];
    return bars[index];
  }

  Widget navBody(int index) {
    List<Widget> bodies = [
      Home(context: context).getBody(resourceList),
      Search(context: context).getBody(),
      MainList(context: context).getBody(),
      Favs(context: context).getBody(resourceList),
      Lists(context: context).getBody(resourceList),
    ];
    return bodies[index];
  }

  TextStyle labelStyle = TextStyle(color: Colors.grey[600]);
  Widget customNav() {
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
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: navAppBar(_currentIndex),
      body: navBody(_currentIndex),
      bottomNavigationBar: customNav(),
      //getNav2(),
    );
  }
}
