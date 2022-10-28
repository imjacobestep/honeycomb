import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  String? name;
  String? email;
  List<String>? favorites;
  List<String>? clients;
  DateTime? createdStamp;
  DateTime? updatedStamp;

  User({
    this.id,
    this.name,
    this.email,
    this.favorites,
    this.clients,
    this.createdStamp,
    this.updatedStamp,
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // print(snapshot.id);
    return User(
      id: snapshot.id,
      name: data?['name'],
      email: data?['email'],
      favorites:
          data?['favorites'] is Iterable ? List.from(data?['favorites']) : null,
      clients:
          data?['clients'] is Iterable ? List.from(data?['clients']) : null,
      createdStamp: data?['createdStamp'] is Timestamp
          ? (data?['createdStamp']).toDate()
          : null,
      updatedStamp: data?['updatedStamp'] is Timestamp
          ? (data?['updatedStamp']).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name?.toLowerCase(),
      if (email != null) "email": email?.toLowerCase(),
      if (favorites != null)
        "favorites": favorites?.map((s) => s.toLowerCase()).toSet().toList(),
      if (clients != null)
        "clients": clients?.map((s) => s.toLowerCase()).toSet().toList(),
      if (createdStamp != null) "createdStamp": createdStamp,
      "updatedStamp": DateTime.now(),
    };
  }
}
// [END add_data_custom_objects]