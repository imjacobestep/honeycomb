import 'package:flutter/material.dart';

import '../model/resource.dart';
import '../pages/resource_details.dart';
import '../utilities.dart';

Widget showRecency(BuildContext context, Resource resource) {
  int diff = resource.updatedStamp!.difference(DateTime.now()).inDays;
  Color recencyColor;

  if (diff < 14) {
    recencyColor = Colors.greenAccent;
  } else if ((diff > 14) && (diff < 30)) {
    recencyColor = Colors.orangeAccent;
  } else {
    recencyColor = Colors.redAccent;
  }

  return Chip(
    labelPadding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
    labelStyle: Theme.of(context).textTheme.labelSmall,
    visualDensity: VisualDensity.compact,
    backgroundColor: recencyColor,
    label: Text(
      "$diff days",
    ),
  );
}

Widget cardCategoryLabel(BuildContext context, String category) {
  return Container(
    margin: const EdgeInsets.all(2),
    child: Chip(
      labelPadding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      visualDensity: VisualDensity.compact,
      label: Text(
        category,
      ),
    ),
  );
}

Widget detailsCategoryLabel(BuildContext context, String category) {
  return Container(
    margin: const EdgeInsets.all(0),
    child: Chip(
      label: Text(category),
    ),
  );
}

Widget resourceCard(
    BuildContext context, Resource resource, void Function() tapFunction) {
  List<Widget> categories = [];
  if (resource.categories != null) {
    for (String category in resource.categories!.keys) {
      categories.add(cardCategoryLabel(context, category));
    }
  } else {
    categories.add(Container());
  }
  return Card(
    child: InkWell(
      onTap: tapFunction,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name!,
                  style: const TextStyle(fontSize: 20),
                ),
                //getSpacer(2),
                Wrap(children: categories),
              ],
            ),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.chevron_right_sharp))
          ],
        ),
      ),
    ),
  );
}
