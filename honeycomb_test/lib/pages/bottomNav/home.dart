import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/models/resource_list.dart';

import '../../utilities.dart';

class Home {
  BuildContext context;

  Home({required this.context});

  PreferredSizeWidget getAppBar() {
    return AppBar(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      title: const Text(
        "Honeycomb",
      ),
      backgroundColor: const Color(0xFF2B2A2A),
      foregroundColor: Colors.white,
    );
  }

  Widget getBody(ResourceList resourceList) {
    return ListView(
      children: [
        sectionHeader("Find by Category", context),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          childAspectRatio: 2,
          children: [
            filterCard(Icons.home_work, "Shelter"),
            filterCard(Icons.sports_kabaddi, "Domestic Violence"),
            filterCard(Icons.psychology, "Mental Health"),
            filterCard(Icons.food_bank, "Food"),
            filterCard(Icons.medical_services, "Medical Help"),
            filterCard(Icons.gavel, "Legal"),
          ],
        ),
        getDivider(context),
        sectionHeader("Favorites", context),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          itemCount: resourceList.providerList.length,
          itemBuilder: (BuildContext context, int index) {
            return resourceList.providerList[index].getCard(context);
          },
        ),
        getDivider(context),
        sectionHeader("Recent Lists", context),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return resourceList.getCard(context);
          },
        ),
      ],
    );
  }
}
