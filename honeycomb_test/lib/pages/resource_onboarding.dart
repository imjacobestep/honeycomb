import 'package:cool_stepper/cool_stepper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';

class NewResource extends StatefulWidget {
  @override
  NewResourceState createState() => NewResourceState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  Resource resource;

  NewResource({required this.resource});
}

class NewResourceState extends State<NewResource> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Widget userBuilder() {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          MPUser user = snapshot.data!;
          return Container();
          //return favoritesBuilder(snapshot.data);
        } else {
          return const Center(
            child: Text("No user found"),
          );
        }
      },
    );
  }

  var steps = [
    CoolStep(
        title: "Add New Resource",
        subtitle: "Primary Info",
        content: Container(),
        validation: () {}),
    CoolStep(
        title: "Add New Resource",
        subtitle: "Page 2",
        content: Container(),
        validation: () {}),
    CoolStep(
        title: "Add New Resource",
        subtitle: "Page 2",
        content: Container(),
        validation: () {}),
  ];

  Widget getStepper() {
    return CoolStepper(
        config: CoolStepperConfig(
            finalText: "Save Resource",
            backText: "Back",
            isHeaderEnabled: false,
            nextTextList: ["Additional Info", "Contact Info", "Save Resource"]),
        steps: steps,
        onCompleted: () {
          Navigator.pop(context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          title: const Text(
            "Onboarding",
          ),
          backgroundColor: const Color(0xFF2B2A2A),
          foregroundColor: Colors.white),
      body: getStepper(),
      bottomNavigationBar: customNav(context, 3),
    );
  }
}
