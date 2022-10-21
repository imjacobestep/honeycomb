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

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];
    return MaterialApp(
      title: 'Honeycomb',
      theme: ThemeData(
        useMaterial3: true,
        //primarySwatch: generateMaterialColor(color: const Color(0xFFEEBB02)),
        //primarySwatch: Colors.orange
      ),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/home');
              }),
            ],
          );
        },
        '/home': (context) {
          return MyHomePage(title: "Honeycomb");
        },
        '/profile': (context) {
          return ProfileScreen(
            appBar: AppBar(
              title: Text("Account Settings"),
              centerTitle: true,
              automaticallyImplyLeading: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              ),
            ),
            providers: providers,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );
        },
      },
      //home: const MyHomePage(title: 'Honeycomb'),
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

  List<String> labels = ["Home", "Map", "List", "Favs", "Clients"];
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
      Map(context: context).getAppBar(),
      MainList(context: context).getAppBar(),
      Favs(context: context).getAppBar(),
      Lists(context: context).getAppBar(),
    ];
    return bars[index];
  }

  Widget navBody(int index) {
    List<Widget> bodies = [
      Home(context: context).getBody(resourceList),
      Map(context: context).getBody(),
      MainList(context: context).getBody(resourceList),
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

    void goToNav(index) {
      setState(() {
        _currentIndex = index;
      });
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
      currentIndex: _currentIndex,
      onTap: (index) {
        goToNav(index);
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
