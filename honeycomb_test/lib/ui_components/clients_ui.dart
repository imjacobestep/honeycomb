import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/client.dart';

import '../pages/client_details.dart';

Widget clientCard(
    BuildContext context, Client client, void Function() tapFunction) {
  return Card(
    child: InkWell(
      onTap: tapFunction,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              client.alias!,
              style: const TextStyle(fontSize: 20),
            ),
            const Icon(Icons.chevron_right_sharp)
          ],
        ),
      ),
    ),
  );
}
