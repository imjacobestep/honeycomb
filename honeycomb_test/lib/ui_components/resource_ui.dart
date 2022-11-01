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
    margin: const EdgeInsets.all(4),
    child: Chip(
      label: Text(category),
    ),
  );
}

Widget resourceCard(BuildContext context, Resource resource) {
  return Card(
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ServiceDetails(
                  resource: resource,
                )),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (String category in resource.categories!.keys)
                      cardCategoryLabel(context, category)
                  ],
                ),
                getSpacer(4),
                Row(
                  children: [
                    Text(
                      resource.name!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    getSpacer(4),
                    //showRecency(context, resource)
                  ],
                )
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
