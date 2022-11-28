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
  return Chip(
    labelPadding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
    labelStyle: Theme.of(context).textTheme.labelSmall,
    visualDensity: VisualDensity.compact,
    label: Text(
      category,
    ),
  );
}

Widget detailsCategoryLabel(BuildContext context, String category) {
  return Chip(
    label: Text(
      category,
      style: Theme.of(context).textTheme.labelMedium,
    ),
  );
}

Widget mapCategoryLabel(BuildContext context, String category) {
  return cardCategoryLabel(context, category);
}

Widget resourceWindow(BuildContext context, Resource resource) {
  List<Widget> categories = [];
  if (resource.categories != null) {
    for (var element in resource.categories!) {
      categories.add(mapCategoryLabel(context, element));
    }
  }
  return InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResourceDetails(
                    resource: resource,
                  )));
    },
    child: Column(
      children: [
        Container(
          padding: const EdgeInsetsDirectional.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 1,
                    spreadRadius: 2,
                    offset: Offset.fromDirection(1, 1))
              ]),
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name!,
                  style: const TextStyle(fontSize: 20),
                ),
                Wrap(children: categories)
              ],
            ),
            getSpacer(4),
            const Icon(Icons.arrow_forward_ios)
          ]),
        ),
        /* Triangle.isosceles(
          edge: Edge.BOTTOM,
          child: Container(
            color: Colors.blue,
            width: 20.0,
            height: 10.0,
          ),
        ), */
      ],
    ),
  );
}

Widget resourceCard(
    BuildContext context, Resource resource, void Function() tapFunction) {
  List<Widget> categories = [];
  if (resource.categories != null) {
    for (String category in resource.categories!) {
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
            Expanded(
              flex: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  //getSpacer(2),
                  Wrap(
                    spacing: 2,
                    children: categories,
                  ),
                ],
              ),
            ),
            const Expanded(flex: 1, child: Icon(Icons.chevron_right_sharp))
          ],
        ),
      ),
    ),
  );
}
