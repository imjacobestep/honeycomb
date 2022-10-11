import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String? id;
  final String name;
  final String provider;
  final String category;
  final String phone;
  final String email;
  final String address;
  final String zipcode;

  Service({
    this.id,
    this.name = '',
    this.provider = '',
    this.category = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.zipcode = '',
  });

  factory Service.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // print(snapshot.id);
    return Service(
      id: snapshot.id,
      name: data?['name'],
      provider: data?['provider'],
      category: data?['category'],
      phone: data?['phone'],
      email: data?['email'],
      address: data?['address'],
      zipcode: data?['zipcode'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "provider": provider,
      "category": category,
      "phone": phone,
      "email": email,
      "address": address,
      "zipcode": zipcode,
    };
  }
}
// [END add_data_custom_objects]