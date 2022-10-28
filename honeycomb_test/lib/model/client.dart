import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String? id;
  String? alias;
  String? agencyId;
  int? size;
  List<String>? resources;
  String? notes;
  DateTime? createdStamp;
  DateTime? updatedStamp;

  Client({
    this.id,
    this.alias,
    this.agencyId,
    this.size,
    this.resources,
    this.notes,
    this.createdStamp,
    this.updatedStamp,
  });

  factory Client.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // print(snapshot.id);
    return Client(
      id: snapshot.id,
      alias: data?['alias'],
      agencyId: data?['agencyId'],
      size: data?['size'],
      resources:
          data?['resources'] is Iterable ? List.from(data?['resources']) : null,
      notes: data?['notes'],
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
      if (alias != null) "alias": alias?.toLowerCase(),
      if (agencyId != null) "agencyId": agencyId?.toLowerCase(),
      if (size != null) "size": size,
      if (resources != null)
        "resources": resources?.map((s) => s.toLowerCase()).toSet().toList(),
      if (notes != null) "notes": notes,
      if (createdStamp != null) "createdStamp": createdStamp,
      "updatedStamp": DateTime.now(),
    };
  }
}
// [END add_data_custom_objects]