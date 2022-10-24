import 'package:cloud_firestore/cloud_firestore.dart';

class BaseModal {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? id;
  final String collection;

  BaseModal(this.id, this.collection);

  Map<String, dynamic> toFirestore() {
    return {};
  }

  Future<void> upsert() async {
    // [START add_data_custom_objects]

    if (id == null) {
      await firestore.collection(collection).add(toFirestore());
    } else {
      await firestore.collection(collection).doc(id).set(toFirestore());
    }
  }
}
// [END add_data_custom_objects]

class Test extends BaseModal {
  Test() : super(null, 'test');
}
