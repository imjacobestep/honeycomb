import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:honeycomb_test/models/service.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: generateMaterialColor(color: Color(0xFFFFE93E)),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  int _currentIndex = 0;

  List<String> navs = ["stock", "custom", "snake", "google", "floating", "dot"];
  String dropdownValue = "stock";

  Service testService1 = Service(
    serviceName: 'TestService1',
    serviceCategory: 'Shelter',
    hasMou: true,
    isVerified: true,
  );

  Service testService2 = Service(
    serviceName: 'TestService2',
    serviceCategory: 'Legal',
    hasMou: false,
    isVerified: false,
  );

  List<String> labels = ["Home", "Search", "Search", "Favs", "Lists"];
  List<Icon> icons = [
    const Icon(Icons.home),
    const Icon(Icons.search),
    const Icon(Icons.add_to_photos),
    const Icon(Icons.star),
    const Icon(Icons.list)
  ];

  Widget getDropdown() {
    return DropdownButton(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: navs.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget getNav() {
    switch (dropdownValue) {
      case "stock":
        {
          return stockNav();
        }
        break;

      case "custom":
        {
          return customNav();
        }
        break;

      case "google":
        {
          return googleNav();
        }
        break;

      case "floating":
        {
          return floatingNav();
        }
        break;

      case "dot":
        {
          return dotNav();
        }
        break;

      default:
        {
          return stockNav();
        }
        break;
    }
  }

  TextStyle labelStyle = TextStyle(color: Colors.grey[600]);

  Widget stockNav() {
    int selectedItemPosition = 0;

    return BottomNavigationBar(
      backgroundColor: Colors.black,
      items: [
        BottomNavigationBarItem(icon: icons[0], label: labels[0]),
        BottomNavigationBarItem(icon: icons[1], label: labels[1]),
        BottomNavigationBarItem(icon: icons[2], label: labels[2]),
        BottomNavigationBarItem(icon: icons[3], label: labels[3]),
        BottomNavigationBarItem(icon: icons[4], label: labels[4]),
      ],
      currentIndex: selectedItemPosition,
      onTap: (index) => setState(() => selectedItemPosition = index),
    );
  }

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
      blurEffect: true,
      opacity: 0.9,
      iconSize: 24,
      isFloating: true,
      selectedColor: Colors.white,
      strokeColor: Colors.white,
      unSelectedColor: Colors.grey[600],
      backgroundColor: Colors.black,
      borderRadius: const Radius.circular(30.0),
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Widget snakeNav() {
    int selectedItemPosition = 2;

    return SnakeNavigationBar.color(
      backgroundColor: Colors.black,
      items: [
        BottomNavigationBarItem(icon: icons[0], label: labels[0]),
        BottomNavigationBarItem(icon: icons[1], label: labels[1]),
        BottomNavigationBarItem(icon: icons[2], label: labels[2]),
        BottomNavigationBarItem(icon: icons[3], label: labels[3]),
        BottomNavigationBarItem(icon: icons[4], label: labels[4]),
      ],
      currentIndex: selectedItemPosition,
      onTap: (index) => setState(() => selectedItemPosition = index),
      behaviour: SnakeBarBehaviour.floating,
      snakeViewColor: Theme.of(context).primaryColor,
      snakeShape: SnakeShape(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      selectedItemColor: const SnakeShape(shape: RoundedRectangleBorder()) ==
              SnakeShape.indicator
          ? Theme.of(context).primaryColor
          : null,
      unselectedItemColor: Colors.blueGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedLabelStyle: const TextStyle(fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
    );
  }

  Widget googleNav() {
    return GNav(
      gap: 4,
      tabBackgroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      haptic: true,
      tabMargin: const EdgeInsets.all(4),
      tabs: const [
        GButton(
          icon: Icons.home,
          text: "home",
        ),
        GButton(
          icon: Icons.search,
          text: "search",
        ),
        GButton(
          icon: Icons.add_to_photos,
          text: "add",
        ),
        GButton(
          icon: Icons.star,
          text: "favs",
        ),
        GButton(
          icon: Icons.list,
          text: "lists",
        ),
      ],
    );
  }

  Widget floatingNav() {
    int _selectedItemPosition = 0;
    return FloatingNavigationBar(
      items: [
        NavBarItems(icon: Icons.home, title: labels[0]),
        NavBarItems(icon: Icons.search, title: labels[1]),
        NavBarItems(icon: Icons.add_to_photos, title: labels[2]),
        NavBarItems(icon: Icons.star, title: labels[3]),
      ],
      onChanged: (index) => setState(() => _selectedItemPosition = index),
      backgroundColor: Colors.white,
    );
  }

  Widget dotNav() {
    int _selectedItemPosition = 0;
    return DotNavigationBar(
      items: [
        DotNavigationBarItem(icon: icons[0]),
        DotNavigationBarItem(icon: icons[1]),
        DotNavigationBarItem(icon: icons[2]),
        DotNavigationBarItem(icon: icons[3]),
        DotNavigationBarItem(icon: icons[4]),
      ],
      currentIndex: _selectedItemPosition,
      onTap: (index) => setState(() => _selectedItemPosition = index),
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            testService1.getCard(),
            testService2.getCard(),
            const Text(
              'Select a nav',
            ),
            getDropdown()
          ],
        ),
      ),
      bottomNavigationBar: getNav(),
      //getNav2(),
    );
  }
}
