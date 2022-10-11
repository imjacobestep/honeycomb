import 'package:cloud_firestore/cloud_firestore.dart';

class Provider {
  String? id;
  String name;
  String phone;
  String? address;
  String? religion;

  Provider({
    this.id,
    this.name = '',
    this.phone = '',
    this.address,
    this.religion,
  });

  factory Provider.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // print(snapshot.id);
    return Provider(
      id: snapshot.id,
      name: data?['name'],
      phone: data?['phone'],
      address: data?['address'],
      religion: data?['religion'],
    );
  }

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