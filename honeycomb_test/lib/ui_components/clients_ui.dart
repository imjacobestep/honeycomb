import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/client.dart';

import '../pages/client_details.dart';

Widget clientCard(BuildContext context, Client client) {
  return Card(
    child: InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClientDetails(
                    client: client,
                  ))),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              client.alias!,
              style: const TextStyle(fontSize: 20),
            ),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.chevron_right_sharp))
          ],
        ),
      ),
    ),
  );
}
