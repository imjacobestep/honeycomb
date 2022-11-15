import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honeycomb_test/geo_helper.dart';
import 'package:honeycomb_test/model/client.dart';
import 'package:honeycomb_test/model/resource.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/utilities.dart';

class NewClient extends StatefulWidget {
  @override
  NewClientState createState() => NewClientState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  Client? client;
  MPUser? user;

  TextEditingController nameController = TextEditingController();
  TextEditingController agencyController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  NewClient({required this.client});
}

class NewClientState extends State<NewClient> {
  double listSpacing = 12;

  @override
  void initState() {
    writeControllers();
    super.initState();
  }

  @override
  void dispose() {
    widget.nameController.dispose();
    widget.agencyController.dispose();
    widget.sizeController.dispose();
    widget.notesController.dispose();
    super.dispose();
  }

  void writeControllers() {
    if (widget.client!.alias != null) {
      widget.nameController.text = widget.client!.alias!;
    }
    if (widget.client!.agencyId != null) {
      widget.agencyController.text = widget.client!.agencyId!;
    }
    if (widget.client!.familySize != null) {
      widget.sizeController.text = widget.client!.familySize!.toString();
    }
    if (widget.client!.notes != null) {
      widget.notesController.text = widget.client!.notes!;
    }
  }

  void writeClient() {
    if (widget.nameController.text != "") {
      widget.client!.alias = widget.nameController.text;
    }
    if (widget.agencyController.text != "") {
      widget.client!.agencyId = widget.agencyController.text;
    }
    if (widget.sizeController.text != "") {
      widget.client!.familySize = int.tryParse(widget.sizeController.text);
    }
    if (widget.notesController.text != "") {
      widget.client!.notes = widget.notesController.text;
    }
    widget.client!.updatedStamp = DateTime.now();
  }

  Widget getLabel(String label, bool required) {
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

  Widget getStepLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget buildForm() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      children: [
        getLabel("Client Alias", true),
        TextField(
          controller: widget.nameController,
          onSubmitted: (text) {
            setState(() {
              widget.nameController.text = text;
            });
          },
          keyboardType: TextInputType.name,
          autofocus: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            hintStyle: TextStyle(color: Colors.black26),
            hintText: "eg. client 1111",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
        getSpacer(listSpacing),
        getLabel("Agency ID", false),
        TextField(
          controller: widget.agencyController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            hintStyle: TextStyle(color: Colors.black26),
            hintText: "eg. 1111",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
        getSpacer(listSpacing),
        getLabel("Family Size", false),
        TextField(
          controller: widget.sizeController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            hintStyle: TextStyle(color: Colors.black26),
            hintText: "eg. 5",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
        getSpacer(listSpacing),
        getLabel("Notes", false),
        TextField(
          controller: widget.notesController,
          keyboardType: TextInputType.name,
          autofocus: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            hintStyle: TextStyle(color: Colors.black26),
            hintText: "Type any extra details...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
        getSpacer(listSpacing),
      ],
    );
  }

  Widget cancelButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
        child: Row(children: [
          const Icon(Icons.cancel),
          getSpacer(8),
          const Text("Cancel")
        ]),
      ),
    );
  }

  Widget userBuilder(String buttonType) {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          widget.user = snapshot.data;
          if (buttonType == "save") {
            return saveButton();
          } else {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: deleteButton(),
            );
          }
        } else {
          return const Center(
            child: LoadingIndicator(size: 40, borderWidth: 3),
          );
        }
      },
    );
  }

  Widget saveButton() {
    return ElevatedButton(
      onPressed: widget.nameController.text == ''
          ? null
          : () async {
              writeClient();
              if (widget.client!.id == null) {
                dynamic newClient =
                    await widget.proxyModel.upsert(widget.client);
                widget.client!.id = newClient.id;
              }
              widget.proxyModel.addToList(widget.user, widget.client);
              Navigator.pop(context);
            },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
        child: Row(children: [
          Text("Save Client"),
          getSpacer(8),
          Icon(Icons.check_circle)
        ]),
      ),
    );
  }

  Widget deleteButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          widget.proxyModel.delFromList(widget.user, widget.client);
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Delete"),
            getSpacer(8),
            const Icon(Icons.delete),
          ],
        ));
  }

  Widget BottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [cancelButton(), getSpacer(8), userBuilder("save")],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          leading: const BackButton(color: Colors.white),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          title: Text(
            widget.client!.id != null ? "Edit Client" : "New Client",
          ),
          actions: widget.client!.id != null ? [userBuilder("delete")] : null,
          backgroundColor: const Color(0xFF2B2A2A),
          foregroundColor: Colors.white),
      body: buildForm(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BottomButtons(),
      //bottomNavigationBar: customNav(context, 3),
    );
  }
}
