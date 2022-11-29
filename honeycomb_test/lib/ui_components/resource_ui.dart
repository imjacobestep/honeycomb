import 'package:flutter/material.dart';

import '../model/resource.dart';

// Category label used on resource card
Widget compactCategoryLabel(BuildContext context, String category) {
  return Chip(
    labelPadding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
    labelStyle: Theme.of(context).textTheme.labelSmall,
    visualDensity: VisualDensity.compact,
    label: Text(
      category,
    ),
  );
}

// Category label used on resource details page
Widget mediumCategoryLabel(BuildContext context, String category) {
  return Chip(
    label: Text(
      category,
      style: Theme.of(context).textTheme.labelMedium,
    ),
  );
}

Widget resourceCard(
    BuildContext context, Resource resource, void Function() tapFunction) {
  List<Widget> categories = [];
  if (resource.categories != null) {
    for (String category in resource.categories!) {
      categories.add(compactCategoryLabel(context, category));
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
