import 'package:cloud_firestore/cloud_firestore.dart';
import '_base.dart';

class Resource extends BaseModal {
  String? name;
  String? phone;
  String? address;
  String? religion;

  // Resource():

  Resource({
    id,
    name = '',
    phone = '',
    address,
    religion,
  }) : super(id, 'resources');

  factory Resource.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // print(snapshot.id);
    return Resource(
      id: snapshot.id,
      name: data?['name'],
      phone: data?['phone'],
      address: data?['address'],
      religion: data?['religion'],
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "phone": phone,
      if (address != null) "address": address,
      if (religion != null) "religion": religion,
    };
  }
}
// [END add_data_custom_objects]
