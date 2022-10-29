import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models_old/resource_list.dart';
import 'package:honeycomb_test/pages/bottomNav/home.dart';
import 'package:honeycomb_test/proxy.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          return HomePage(
            mainList: buildTest(),
          );
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
