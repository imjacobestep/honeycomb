import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/main.dart';
import 'package:honeycomb_test/models/resource_list.dart';

import '../../utilities.dart';

class Home {
  BuildContext context;

  Home({required this.context});

  Widget filterCard(IconData icon, String label) {
    return Card(
      child: InkWell(
        onTap: () {
          category_filters[label] = !category_filters[label]!;
        },
        onLongPress: () {
          resetFilters();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon),
              getSpacer(10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget getAppBar() {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    String? displayName = FirebaseAuth.instance.currentUser?.displayName;
    String userName = displayName != null ? displayName : "";

    return AppBar(
      centerTitle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      title: Text("Hello, $userName"),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle_outlined))
      ],
      //backgroundColor: const Color(0xFF2B2A2A),
      //foregroundColor: Colors.white,
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
        sectionHeader("Recent Clients", context),
        ListView.builder(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return resourceList.getCard(context);
          },
        ),
        getDivider(context),
        sectionHeader("Favorites", context),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          itemCount: resourceList.resources.length,
          itemBuilder: (BuildContext context, int index) {
            return resourceList.resources[index]
                .getServiceCard(context, "home");
          },
        ),
      ],
    );
  }
}
