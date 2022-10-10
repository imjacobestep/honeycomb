import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_list.dart';

//AIzaSyC1hEwGPXOck5HeY0ziBFtNGZ7GJGa5HAs

class Lists {
  BuildContext context;

  Lists({required this.context});

  PreferredSizeWidget getAppBar() {
    return AppBar(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      title: const Text(
        "Lists",
      ),
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
    );
  }

  Widget getBody(ResourceList resourceList) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return resourceList.getCard(context);
      },
    );
  }
}
