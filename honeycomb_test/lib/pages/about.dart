import 'package:about/about.dart' as prefix;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class AboutPage extends StatefulWidget {
  @override
  AboutPageState createState() => AboutPageState();
  String userID = FirebaseAuth.instance.currentUser!.uid;

  // ignore: use_key_in_widget_constructors
  AboutPage();
}

class AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
  }

  // VARIABLES

  String githubURL = "https://github.com/imjacobestep/honeycomb";
  String copyright =
      '''Copyright © Jacob Estep, Shih-Hsin Lo, Saif Mustafa, and Abhijeet Saraf, 2022''';
  String description = '''
Created by grad students at UW's GIX to help Mary's Place Seattle collect resource information, identifyresources nearby, and share this info with families.
''';

  // FUNCTIONS

  void licenses() {
    showLicensePage(context: context, applicationIcon: appIcon());
  }

  // UI WIDGETS

  Widget appIcon() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        "lib/assets/icon/icon.png",
        width: 80,
        height: 80,
      ),
    );
  }

  PreferredSizeWidget pageHeader() {
    return AppBar(
      leading: const BackButton(color: Colors.white),
      title: const Text(
        "Settings",
      ),
    );
  }

  Widget itemCard(String label, Icon icon) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          icon,
          getSpacer(16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      ),
    ));
  }

  pageBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        getSpacer(16),
        appIcon(),
        getSpacer(4),
        Text(
          textAlign: TextAlign.center,
          "Honeycomb",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        getSpacer(16),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            textAlign: TextAlign.center,
            copyright,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            textAlign: TextAlign.center,
            description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child:
                itemCard("Account", const Icon(Icons.account_circle_outlined))),
        getSpacer(8),
        InkWell(
            onTap: () {
              launchUrl(Uri.parse(githubURL));
            },
            child: itemCard("GitHub", const Icon(Icons.link_outlined))),
        getSpacer(8),
        InkWell(
            onTap: () {
              licenses();
            },
            child:
                itemCard("Licenses", const Icon(Icons.description_outlined))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: pageHeader(),
      body: pageBody(),
    );
  }
}
