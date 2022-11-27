// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:honeycomb_test/model/client.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/clients.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/animated_navigator.dart';
import 'package:honeycomb_test/utilities.dart';

class NewClient extends StatefulWidget {
  @override
  NewClientState createState() => NewClientState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  Client? client;
  MPUser? user;
  bool delete = false;

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

  confirmDelete() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Title"),
            content: const Text("content"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {},
              ),
              TextButton(
                child: const Text("Delete"),
                onPressed: () {},
              )
            ],
          );
        });
  }

  Widget buildForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
          maxLines: null,
          controller: widget.notesController,
          keyboardType: TextInputType.multiline,
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
        getSpacer(48),
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

                widget.client =
                    await widget.proxyModel.get('clients', newClient.id);
                widget.proxyModel.addToList(widget.user, widget.client);
                Haptic.onSuccess();
                showToast("Client created", Colors.black);
              } else {
                widget.proxyModel.upsert(widget.client);
                Haptic.onSuccess();
                showToast("Client updated", Colors.black);
              }

              Navigator.pop(context);
            },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
        child: Row(children: [
          const Text("Save Client"),
          getSpacer(8),
          const Icon(Icons.check_circle)
        ]),
      ),
    );
  }

  Widget confirmationPopup() {
    return AlertDialog(
      title: const Text("Are you sure you want to delete this client?"),
      content:
          const Text("You may have to contact your IT admin to restore it"),
      actions: [
        ElevatedButton(
          //style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Delete"),
          onPressed: () {
            widget.delete = true;
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Widget deleteButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          //widget.proxyModel.delFromList(widget.user, widget.client);
          //await confirmDelete();
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return confirmationPopup();
              });
          if (widget.delete) {
            Haptic.onSuccess();
            showToast("Client deleted", Colors.black);
            widget.proxyModel.delFromList(widget.user, widget.client);
            Navigator.pushReplacement(
              context,
              FadeInRoute(
                routeName: "/clients",
                page: ClientsPage(),
              ),
            );
          }
          //Navigator.pop(context);
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

  Widget bottomButtons() {
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
        leading:
            BackButton(color: Theme.of(context).appBarTheme.foregroundColor),
        title: Text(
          widget.client!.id != null ? "Edit Client" : "New Client",
        ),
        actions: widget.client!.id != null ? [userBuilder("delete")] : null,
      ),
      body: buildForm(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: bottomButtons(),
      //bottomNavigationBar: customNav(context, 3),
    );
  }
}
