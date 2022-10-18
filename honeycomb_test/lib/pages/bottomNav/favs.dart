import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/resource_list.dart';

class Favs {
  BuildContext context;

  Favs({required this.context});

  PreferredSizeWidget getAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit),
        )
      ],
      title: Text("Favorites"),
    );
  }

  Widget getBody(ResourceList favs) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: favs.resources.length,
      itemBuilder: (BuildContext context, int index) {
        return favs.resources[index].getServiceCard(context, "favs");
      },
    );
  }
}
