// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/geo_helper.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/utilities.dart';

class NewResource extends StatefulWidget {
  @override
  NewResourceState createState() => NewResourceState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  GeoHelper geo = GeoHelper();
  Resource? resource;
  TextEditingController nameController = TextEditingController();
  Map<TextEditingController, TextEditingController> phoneController = {};
  TextEditingController emailController = TextEditingController();
  TextEditingController webController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  List<String> categoriesController = [];
  List<String> eligibilityController = [];
  bool multilingualController = false;
  bool accessibleController = false;
  bool addressValid = false;

  NewResource({required this.resource});
}

class NewResourceState extends State<NewResource> {
  @override
  void initState() {
    resourceToTextController();
    super.initState();
  }

  @override
  void dispose() {
    widget.nameController.dispose();
    widget.emailController.dispose();
    widget.webController.dispose();
    widget.addressController.dispose();
    widget.notesController.dispose();
    super.dispose();
  }

  // VARIABLES

  int currentStep = 0;
  double listSpacing = 12;

  // FUNCTIONS

  bool isFirstPageComplete() {
    return ((widget.nameController.text != "") &&
        (widget.resource!.categories != null &&
            widget.resource!.categories!.isNotEmpty));
  }

  void resourceToTextController() {
    if (widget.resource!.name != null) {
      widget.nameController.text = widget.resource!.name!;
    }
    if (widget.resource!.phoneNumbers != null &&
        widget.resource!.phoneNumbers!.isNotEmpty) {
      widget.resource!.phoneNumbers!.forEach((key, value) {
        widget.phoneController[
                TextEditingController.fromValue(TextEditingValue(text: key))] =
            TextEditingController.fromValue(TextEditingValue(text: value));
      });
    } else {
      widget.phoneController[TextEditingController.fromValue(
          const TextEditingValue(text: 'primary'))] = TextEditingController();
    }
    if (widget.resource!.email != null) {
      widget.emailController.text = widget.resource!.email!;
    }
    if (widget.resource!.website != null) {
      widget.webController.text = widget.resource!.website!;
    }
    if (widget.resource!.address != null) {
      widget.addressController.text = widget.resource!.address!;
    }
    if (widget.resource!.notes != null) {
      widget.notesController.text = widget.resource!.notes!;
    }
    if (widget.resource!.categories != null) {
      widget.categoriesController = widget.resource!.categories!;
    }
    if (widget.resource!.eligibility != null) {
      widget.eligibilityController = widget.resource!.eligibility!;
    }
    if (widget.resource!.multilingual != null) {
      widget.multilingualController = widget.resource!.multilingual!;
    }
    if (widget.resource!.accessibility != null) {
      widget.accessibleController = widget.resource!.accessibility!;
    }
  }

  Future<void> textControllerToResource() async {
    if (widget.nameController.text != "") {
      widget.resource!.name = widget.nameController.text;
    }
    if (widget.phoneController.isNotEmpty) {
      widget.phoneController.forEach((key, value) {
        widget.resource!.phoneNumbers![key.text] = value.text;
      });
    }
    if (widget.emailController.text != "") {
      widget.resource!.email = widget.emailController.text;
    }
    if (widget.webController.text != "") {
      widget.resource!.website = widget.webController.text;
    }
    if (widget.addressController.text != "") {
      widget.resource!.address =
          widget.addressController.text.replaceAll("#", "Apt ");
      Map<dynamic, dynamic> coords =
          await GeoHelper().parseAddress(widget.resource!.address!, '');
      widget.resource!.coords = LatLng(coords['lat'], coords['lng']);
    }
    if (widget.notesController.text != "") {
      widget.resource!.notes = widget.notesController.text;
    }
    if (widget.categoriesController.isNotEmpty) {
      widget.resource!.categories = widget.categoriesController;
    }
    if (widget.eligibilityController.isNotEmpty) {
      widget.resource!.eligibility = widget.eligibilityController;
    }
    widget.resource!.multilingual = widget.multilingualController;
    widget.resource!.accessibility = widget.accessibleController;
    if (FirebaseAuth.instance.currentUser != null) {
      if (FirebaseAuth.instance.currentUser!.displayName != null) {
        widget.resource!.createdBy =
            FirebaseAuth.instance.currentUser!.displayName!;
        widget.resource!.updatedBy =
            FirebaseAuth.instance.currentUser!.displayName!;
      } else if (FirebaseAuth.instance.currentUser!.email != null) {
        widget.resource!.createdBy = FirebaseAuth.instance.currentUser!.email!;
        widget.resource!.updatedBy = FirebaseAuth.instance.currentUser!.email!;
      }
    }
  }

  Future<bool> checkAddress(String address) async {
    address = address.replaceAll("#", "Apt ");
    Map<dynamic, dynamic> data = await widget.geo.parseAddress(address, "");
    bool ret = (data['lat'] != null && data['lng'] != null);
    if (ret) {
      widget.addressController.text.replaceAll(RegExp(r'#'), "Apt ");
    }
    return ret;
  }

  stepTapped(int step) {
    setState(() {
      currentStep = step;
    });
  }

  stepContinue() {
    currentStep < 2 ? setState(() => currentStep += 1) : null;
  }

  stepBack() {
    currentStep > 0 ? setState(() => currentStep -= 1) : Navigator.pop(context);
  }

  // FORM STEPS

  Step stepOne() {
    return Step(
      title: formStepLabel("Critical Info"),
      content: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          inputLabel("Resource Name", true),
          TextField(
            controller: widget.nameController,
            onSubmitted: (text) {
              setState(() {
                widget.nameController.text = text;
              });
            },
            keyboardType: TextInputType.multiline,
            autofocus: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: "eg. [organization][service]",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(listSpacing),
          inputLabel("Pick all applicable Categories", true),
          categoriesSection(),
        ],
      ),
      isActive: currentStep >= 0,
      state: currentStep >= 0 ? StepState.complete : StepState.disabled,
    );
  }

  Step stepTwo() {
    return Step(
      title: formStepLabel("Additional Info"),
      content: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          inputLabel("Language", false),
          languageSection(),
          getSpacer(listSpacing),
          inputLabel("Eligibility Requirements", false),
          eligibilitySection(),
          getSpacer(listSpacing),
          inputLabel("Wheelchair Accessible", false),
          accessibilitySection(),
        ],
      ),
      isActive: currentStep >= 1,
      state: currentStep >= 1 ? StepState.complete : StepState.disabled,
    );
  }

  Step stepThree() {
    return Step(
      title: formStepLabel("Contact Info"),
      content: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          phoneSection(),
          getSpacer(listSpacing),
          inputLabel("Email", false),
          TextField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: "eg. email@example.org",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(listSpacing),
          inputLabel("Website", false),
          TextField(
            controller: widget.webController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: "eg. example.org",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          getSpacer(listSpacing),
          inputLabel("Street Address", false),
          addressBuilder(),
          getSpacer(listSpacing),
          inputLabel("Notes", false),
          TextField(
            maxLines: null,
            controller: widget.notesController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              hintStyle: TextStyle(color: Colors.black26),
              hintText: "eg. open hours...",
              border: OutlineInputBorder(
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

  // UI WIDGETS

  Widget validationPopup(String error, String suggestion) {
    return AlertDialog(
      title: Text(error),
      content: Text(suggestion),
      actions: [
        ElevatedButton(
          //style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Ok"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget inputLabel(String label, bool required) {
    List<Widget> children = [];
    children.add(Text(
      label,
      style: Theme.of(context).textTheme.titleSmall,
    ));
    if (required) {
      children.add(getSpacer(8));
      children.add(const Text(
        "required",
        style: TextStyle(
            color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12),
      ));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget formStepLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget selectionChip(String label, String type, bool value) {
    return InkWell(
        borderRadius: BorderRadius.circular(35),
        onTap: () {
          Haptic.onSelection;
          switch (type) {
            case "category":
              if (value) {
                widget.categoriesController.remove(label.toLowerCase());
              } else {
                widget.categoriesController.add(label.toLowerCase());
              }
              break;
            case "language":
              if (label == "English Only") {
                widget.multilingualController = false;
              } else {
                widget.multilingualController = true;
              }
              break;
            case "eligibility":
              if (value) {
                widget.eligibilityController.remove(label.toLowerCase());
              } else {
                widget.eligibilityController.add(label.toLowerCase());
              }
              break;
            case "accessibility":
              if (label == "Yes") {
                widget.accessibleController = true;
              } else {
                widget.accessibleController = false;
              }
              break;
            default:
          }
          setState(() {});
        },
        child: !value
            ? Chip(
                label: Text(label, style: const TextStyle(fontSize: 14)),
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.black12, width: 1),
              )
            : Chip(
                side: const BorderSide(color: Colors.transparent, width: 1),
                backgroundColor: Colors.black,
                label: Text(
                  label,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          Theme.of(context).textTheme.labelLarge!.fontSize,
                      fontStyle:
                          Theme.of(context).textTheme.labelLarge!.fontStyle),
                ),
              ));
  }

  Widget languageSection() {
    return Wrap(
      spacing: 4,
      children: [
        selectionChip(
            "English Only", "language", !widget.multilingualController),
        selectionChip("MultiLingual", "language", widget.multilingualController)
      ],
    );
  }

  Widget accessibilitySection() {
    widget.resource!.accessibility ??= false;
    return Wrap(
      spacing: 4,
      children: [
        selectionChip("Yes", "accessibility", widget.accessibleController),
        selectionChip("No", "accessibility", !widget.accessibleController)
      ],
    );
  }

  Widget eligibilitySection() {
    List<Widget> children = [];
    filters["Eligibility"]!.forEach((key, value) {
      if (widget.eligibilityController.contains(key.toLowerCase())) {
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

  Widget categoriesSection() {
    List<Widget> children = [];
    filters["Categories"]!.forEach((key, value) {
      widget.resource!.categories ??= [];
      if (widget.categoriesController.contains(key.toLowerCase())) {
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

  Widget phoneInputBoxes(
      TextEditingController name, TextEditingController number) {
    Widget delete = name.text == "primary"
        ? Container()
        : IconButton(
            onPressed: () {
              setState(() {
                widget.phoneController.remove(name);
              });
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ));
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [inputLabel("Contact Name", false), delete],
        ),
        TextField(
          enabled: name.text == "primary" ? false : true,
          controller: name,
          keyboardType: TextInputType.name,
          autofocus: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            hintStyle: TextStyle(color: Colors.black26),
            hintText: "eg. secretary",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
        getSpacer(4),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: inputLabel("Phone Number", false),
            ),
            TextField(
              controller: number,
              keyboardType: TextInputType.phone,
              autofocus: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.subdirectory_arrow_right_outlined),
                contentPadding: EdgeInsets.all(8),
                hintStyle: TextStyle(color: Colors.black26),
                hintText: "eg. 111-111-1111",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
            getSpacer(4)
          ],
        )
      ],
    );
  }

  Widget phoneSection() {
    List<Widget> children = [];
    widget.phoneController.forEach((key, value) {
      //String val = value != null ? value : '';
      children.add(phoneInputBoxes(key, value));
    });
    children.add(ElevatedButton(
        onPressed: () {
          setState(() {
            widget.phoneController[TextEditingController()] =
                TextEditingController();
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [Icon(Icons.add), Text("Add Number")],
        )));
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  Widget addressInputBox(bool hasError, bool isVerified) {
    bool showIcon = (hasError || isVerified);
    Icon verifiedIcon;
    if (hasError) {
      verifiedIcon = const Icon(
        Icons.error_outline_outlined,
        color: Colors.red,
      );
    } else {
      verifiedIcon = const Icon(
        Icons.verified_outlined,
        color: Colors.green,
      );
    }
    return TextField(
      onSubmitted: (text) {
        setState(() {
          widget.addressController.text = text.replaceAll("#", "Apt ");
        });
      },
      controller: widget.addressController,
      keyboardType: TextInputType.streetAddress,
      decoration: InputDecoration(
        helperText: "Include city and state or zip code",
        prefixIcon: showIcon ? verifiedIcon : null,
        errorText: hasError ? "Improper Address" : null,
        contentPadding: const EdgeInsets.all(8),
        hintStyle: const TextStyle(color: Colors.black26),
        hintText: "eg. 123 Example St",
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }

  Widget addressBuilder() {
    if (widget.addressController.text == "") {
      return addressInputBox(false, false);
    } else {
      return FutureBuilder(
        future: widget.geo.parseAddress(
            widget.addressController.text.replaceAll(RegExp(r'#'), "Apt "), ""),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            //print(loc.data);
            if (snapshot.data!['lat'] != null &&
                snapshot.data!['lng'] != null) {
              widget.addressValid = true;
              return addressInputBox(false, true);
            } else {
              widget.addressValid = false;

              return addressInputBox(true, false);
            }
          } else {
            return LoadingIndicator(
              size: 50,
              borderWidth: 5,
              color: Theme.of(context).colorScheme.primary,
            );
          }
        },
      );
    }
  }

  Widget backButton(ControlsDetails details) {
    String backText = currentStep == 0 ? "Cancel" : "Back";
    Icon backIcon = currentStep == 0
        ? const Icon(Icons.cancel)
        : const Icon(Icons.arrow_upward_outlined);
    return ElevatedButton(
      onPressed: details.onStepCancel,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
        child: Row(children: [backIcon, getSpacer(8), Text(backText)]),
      ),
    );
  }

  Widget nextButton(ControlsDetails details) {
    bool firstIncomplete = (currentStep == 0 && !isFirstPageComplete());

    Icon nextIcon = currentStep == 2
        ? const Icon(Icons.check_circle)
        : const Icon(Icons.arrow_downward_outlined);
    String nextText = currentStep == 2 ? "Save Resource" : "Next";
    return ElevatedButton(
      onPressed: (firstIncomplete)
          ? null
          : (currentStep == 2)
              ? () async {
                  bool validated =
                      await checkAddress(widget.addressController.text);

                  bool addressValidated =
                      (validated || (widget.addressController.text == ""));

                  bool emailValid =
                      (widget.emailController.text.contains("@") ||
                          (widget.emailController.text == ""));

                  if (addressValidated && emailValid) {
                    await textControllerToResource();
                    if (widget.resource!.id == null ||
                        widget.resource!.id == "") {
                      Haptic.onSuccess();
                      showToast("Resource created", Colors.black);
                    } else {
                      Haptic.onSuccess();
                      showToast("Resource updated", Colors.black);
                    }
                    widget.proxyModel.upsert(widget.resource);
                    Navigator.pop(context);
                  } else {
                    if (!addressValidated) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return validationPopup("Invalid Address",
                                "This address isn't valid. You might need to add information or change the formatting.");
                          });
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return validationPopup("Invalid Email Address",
                                "This email isn't valid. You might be missing an '@' symbol.");
                          });
                    }
                  }
                }
              : details.onStepContinue,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
        child: Row(children: [Text(nextText), getSpacer(8), nextIcon]),
      ),
    );
  }

  Widget pageBody() {
    return Stepper(
      steps: [stepOne(), stepTwo(), stepThree()],
      type: StepperType.vertical,
      onStepCancel: () {
        stepBack();
      },
      onStepTapped: (step) {
        stepTapped(step);
      },
      onStepContinue: () {
        stepContinue();
      },
      currentStep: currentStep,
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Row(
            children: <Widget>[
              backButton(details),
              getSpacer(8),
              nextButton(details)
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget pageHeader() {
    return AppBar(
      leading: BackButton(color: Theme.of(context).appBarTheme.foregroundColor),
      title: Text(
        widget.resource!.id != null ? "Edit Resource" : "New Resource",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: pageHeader(),
      body: pageBody(),
    );
  }
}
