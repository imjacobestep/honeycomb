import 'package:cool_stepper/cool_stepper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
  }

  Widget selectionChip(String label, String type, bool value) {
    return InkWell(
        borderRadius: BorderRadius.circular(35),
        enableFeedback: true,
        onTap: () {
          Haptic.onSelection;
          switch (type) {
            case "category":
              if (value) {
                widget.resource.categories!.remove(label.toLowerCase());
              } else {
                widget.resource.categories![label.toLowerCase()] = true;
              }
              break;
            case "language":
              if (label == "English Only") {
                widget.resource.multilingual = false;
              } else {
                widget.resource.multilingual = true;
              }
              break;
            case "eligibility":
              if (value) {
                widget.resource.eligibility!.remove(label.toLowerCase());
              } else {
                widget.resource.eligibility![label.toLowerCase()] = true;
              }
              break;
            case "accessibility":
              if (label == "Yes") {
                widget.resource.accessibility = true;
              } else {
                widget.resource.accessibility = false;
              }
              break;
            default:
          }
          setState(() {});
        },
        child: !value
            ? Chip(
                label: Text(label, style: TextStyle(fontSize: 14)),
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.black12, width: 1),
              )
            : Chip(
                side: const BorderSide(color: Colors.transparent, width: 1),
                backgroundColor: Colors.black,
                label: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ));
  }

  Widget languageBuilder() {
    widget.resource.multilingual ??= false;
    return Wrap(
      spacing: 4,
      children: [
        selectionChip(
            "English Only", "language", !widget.resource.multilingual!),
        selectionChip("MultiLingual", "language", widget.resource.multilingual!)
      ],
    );
  }

  Widget accessBuilder() {
    widget.resource.accessibility ??= false;
    return Wrap(
      spacing: 4,
      children: [
        selectionChip("Yes", "accessibility", widget.resource.accessibility!),
        selectionChip("No", "accessibility", !widget.resource.accessibility!)
      ],
    );
  }

  Widget eligibilityBuilder() {
    widget.resource.eligibility ??= {};
    List<Widget> children = [];
    filters["Eligibility"]!.forEach((key, value) {
      widget.resource.eligibility ??= {};
      if (widget.resource.eligibility!.containsKey(key.toLowerCase())) {
        children.add(selectionChip(key, 'eligibility', true));
      } else {
        children.add(selectionChip(key, 'eligibility', false));
      }
    });
    return Wrap(
      spacing: 4,
      children: children,
    );
  }

  Widget categoriesBuilder() {
    widget.resource.categories ??= {};
    List<Widget> children = [];
    filters["Categories"]!.forEach((key, value) {
      widget.resource.categories ??= {};
      if (widget.resource.categories!.containsKey(key.toLowerCase())) {
        children.add(selectionChip(key, 'category', true));
      } else {
        children.add(selectionChip(key, 'category', false));
      }
    });
    return Wrap(
      spacing: 4,
      children: children,
    );
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

  Step stepOne() {
    return Step(
      title: const Text("Critical Info"),
      content: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text(
            "Resource Name",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextField(
            onChanged: (text) {
              widget.resource.name = text;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: widget.resource.name != null
                  ? widget.resource.name!
                  : "eg. [organization][service]",
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(24),
          Text(
            "Pick all applicable Categories",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          categoriesBuilder(),
        ],
      ),
      isActive: currentStep >= 0,
      state: currentStep >= 0 ? StepState.complete : StepState.disabled,
    );
  }

  Step stepTwo() {
    return Step(
      title: const Text("Additional Info"),
      content: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text(
            "Language",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          languageBuilder(),
          getSpacer(24),
          Text(
            "Eligibility Requirements",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          eligibilityBuilder(),
          getSpacer(24),
          Text(
            "Wheelchair Accessible?",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          accessBuilder(),
        ],
      ),
      isActive: currentStep >= 1,
      state: currentStep >= 1 ? StepState.complete : StepState.disabled,
    );
  }

  Step stepThree() {
    return Step(
      title: const Text("Contact Info"),
      content: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text(
            "Phone Number",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextField(
            onChanged: (text) {
              widget.resource.phoneNumbers ??= {};
              widget.resource.phoneNumbers!["primary"] = text;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: widget.resource.phoneNumbers!["primary"] != null
                  ? widget.resource.phoneNumbers!["primary"]!
                  : "primary number",
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(24),
          Text(
            "Email",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextField(
            onChanged: (text) {
              widget.resource.email = text;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: widget.resource.email != null
                  ? widget.resource.email!
                  : "eg. email@example.org",
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(24),
          Text(
            "Website",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextField(
            onChanged: (text) {
              widget.resource.website = text;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: widget.resource.website != null
                  ? widget.resource.website!
                  : "eg. example.org",
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(24),
          Text(
            "Address",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextField(
            onChanged: (text) {
              widget.resource.address = text;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: widget.resource.address != null
                  ? widget.resource.address!
                  : "eg. 123 Example St",
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(24),
          Text(
            "Zip Code",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextField(
            onChanged: (text) {
              widget.resource.zipCode = text;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: widget.resource.zipCode != null
                  ? widget.resource.zipCode!
                  : "eg. 12345",
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(24),
          Text(
            "Notes",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextField(
            onChanged: (text) {
              widget.resource.notes = text;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: widget.resource.notes != null
                  ? widget.resource.notes!
                  : "eg. Type any extra details...",
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
        ],
      ),
      isActive: currentStep >= 2,
      state: currentStep >= 2 ? StepState.complete : StepState.disabled,
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
        config: const CoolStepperConfig(
            finalText: "Save Resource",
            backText: "Back",
            isHeaderEnabled: false,
            nextTextList: ["Additional Info", "Contact Info", "Save Resource"]),
        steps: steps,
        onCompleted: () {
          Navigator.pop(context);
        });
  }

  tapped(int step) {
    setState(() {
      currentStep = step;
    });
  }

  continued() {
    currentStep < 2 ? setState(() => currentStep += 1) : null;
  }

  cancel() {
    currentStep > 0 ? setState(() => currentStep -= 1) : Navigator.pop(context);
  }

  Widget getStepper2() {
    return Stepper(
      steps: [stepOne(), stepTwo(), stepThree()],
      type: StepperType.vertical,
      onStepCancel: () {
        cancel();
      },
      onStepTapped: (step) {
        tapped(step);
      },
      onStepContinue: () {
        continued();
      },
      currentStep: currentStep,
    );
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
      body: getStepper2(),
      //bottomNavigationBar: customNav(context, 3),
    );
  }
}
