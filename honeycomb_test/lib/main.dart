import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/pages/bottomNav/home.dart';
import 'package:material_color_generator/material_color_generator.dart';

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
          primarySwatch: generateMaterialColor(color: const Color(0xFFFFE93E)),
          //primarySwatch: Colors.orange
          cardTheme: CardTheme(
            color: Color(0xFFF6F6F6),
            surfaceTintColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(width: 2, color: Color(0xFFE7E7E7))),
          ),
          canvasColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.black,
                backgroundColor: const Color(0xFFFFE93E)),
          )),

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
          return HomePage();
        },
        '/profile': (context) {
          return ProfileScreen(
            appBar: AppBar(
              title: const Text("Account Settings"),
              centerTitle: true,
              automaticallyImplyLeading: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
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
