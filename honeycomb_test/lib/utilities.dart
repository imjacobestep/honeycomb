import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:honeycomb_test/model/resource.dart';

Widget getSpacer(double size) {
  return SizedBox(
    width: size,
    height: size,
  );
}

Widget getDivider(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      getSpacer(8),
      Divider(
        color: Colors.black.withAlpha(10),
        height: 8,
        thickness: 2,
        indent: 8,
        endIndent: 8,
      ),
      getSpacer(8)
    ],
  );
}

Map<String, Map<String, bool>> filters = {
  "Categories": {
    "Shelter": false,
    "Domestic Violence": false,
    "Housing": false,
    "Food": false,
    "Medical": false,
    "Mental Health": false,
    "Clothing": false,
    "Education": false,
    "Translation": false,
    "Legal": false,
    "Employment": false,
    "Childcare": false,
    "Community": false,
    "Transportation": false,
    "Re-entry": false,
    "Other": false,
  },
  "Eligibility": {
    "Open to All": false,
    "Women Only": false,
    "Minors Only": false,
    "Adult Only": false,
    "Family": false,
    "Individual": false
  },
  "Other Filters": {
    "Multilingual": false,
    "Active": false,
    "Accessibility": false
  },
};

Resource makeNewResource(String userName) {
  return Resource(
      phoneNumbers: {},
      categories: [],
      multilingual: false,
      eligibility: ["open to all"],
      accessibility: false,
      isActive: true,
      createdBy: (userName != "") ? userName : "unknown",
      createdStamp: DateTime.now());
}

Widget helperText(
    String error, String helper, BuildContext context, bool fullScreen) {
  Widget content = Column(mainAxisSize: MainAxisSize.min, children: [
    Text(
      error,
      style: Theme.of(context).textTheme.headlineSmall,
    ),
    Text(helper),
  ]);

  return fullScreen
      ? Center(child: content)
      : Padding(
          padding: const EdgeInsets.all(48),
          child: content,
        );
}

Widget getLoader() {
  return const LoadingIndicator(size: 40, borderWidth: 8);
}

Map<String, dynamic> getFilterQuery() {
  Map<String, dynamic> query = {};
  List<String> categoriesSelected = [];
  List<String> eligibilitySelected = [];
  filters.forEach((filterType, filtersOfType) {
    filtersOfType.forEach((filterLabel, filterValue) {
      if (filterType == "Categories" && filterValue) {
        categoriesSelected.add(filterLabel.toLowerCase());
      } else if (filterType == "Eligibility" && filterValue) {
        eligibilitySelected.add(filterLabel.toLowerCase());
      } else if (filterType == "Other Filters" && filterValue) {
        query[filterLabel.toLowerCase()] = filterValue;
      }
    });
  });
  if (categoriesSelected.isNotEmpty) {
    query["categories"] = categoriesSelected;
  }
  if (eligibilitySelected.isNotEmpty) {
    query["eligibility"] = eligibilitySelected;
  }
  return query;
}

String getPlural(int num) {
  return num == 1 ? "" : "s";
}

int howManyFilters() {
  int ret = 0;
  filters.forEach((key, value) {
    value.forEach((key2, value2) {
      if (value2) {
        ret++;
      }
    });
  });
  return ret;
}

void setFilter(String inKey, bool inVal) {
  filters.forEach((key, value) {
    if (value.containsKey(inKey)) {
      value[inKey] = inVal;
    }
  });
}

void resetFilters() {
  filters.forEach((key, value) {
    setFilter(key, false);
  });
}

void showToast(String message, Color background) {
  Fluttertoast.showToast(
      msg: message,
      backgroundColor: background,
      textColor: background == Colors.black ? Colors.white : Colors.black);
}
