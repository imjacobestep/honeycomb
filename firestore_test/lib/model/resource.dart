import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Resource {
  final String? id;
  String? name;
  Map? phoneNumbers;
  String? email;
  String? address;
  String? zipCode;
  LatLng? coords;
  String? website;
  //LIST ATTRIBUTES
  List<String>? categories;
  bool? multilingual;
  List<String>? eligibility;
  bool? accessibility;
  //EXTRA ATTRIBUTES
  String? notes;
  bool? isActive;
  //SYSTEM ATTRIBUTES
  String? createdBy;
  DateTime? createdStamp;
  String? updatedBy;
  DateTime? updatedStamp;

  Resource({
    this.id,
    this.name,
    this.phoneNumbers,
    this.email,
    this.address,
    this.zipCode,
    this.coords,
    this.website,
    this.categories,
    this.multilingual,
    this.eligibility,
    this.accessibility,
    this.notes,
    this.isActive,
    this.createdBy,
    this.createdStamp,
    this.updatedBy,
    this.updatedStamp,
  });

  factory Resource.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // print(snapshot.id);
    return Resource(
      id: snapshot.id,
      name: data?['name'],
      phoneNumbers: data?['phoneNumbers'],
      email: data?['email'],
      address: data?['address'],
      zipCode: data?['zipCode'],
      coords: data?['coords'] is GeoPoint
          ? LatLng(data?['coords'].latitude, data?['coords'].longitude)
          : null,
      website: data?['website'],
      categories: data?['categories'] is Iterable
          ? List.from(data?['categories'])
          : null,
      multilingual: data?['multilingual'],
      eligibility: data?['eligibility'] is Iterable
          ? List.from(data?['eligibility'])
          : null,
      accessibility: data?['accessibility'],
      notes: data?['notes'],
      isActive: data?['isActive'],
      createdBy: data?['createdBy'],
      createdStamp: data?['createdStamp'] is Timestamp
          ? (data?['createdStamp']).toDate()
          : null,
      updatedBy: data?['updatedBy'],
      updatedStamp: data?['updatedStamp'] is Timestamp
          ? (data?['updatedStamp']).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (phoneNumbers != null) "phoneNumbers": phoneNumbers,
      if (email != null) "email": email?.toLowerCase(),
      if (address != null) "address": address,
      if (zipCode != null) "zipCode": zipCode,
      if (coords != null)
        "coords": GeoPoint(coords!.latitude, coords!.longitude),
      if (website != null) "website": website?.toLowerCase(),
      if (categories != null) "resources": categories?.toSet().toList(),
      if (multilingual != null) "multilingual": multilingual,
      if (eligibility != null) "resources": eligibility?.toSet().toList(),
      if (accessibility != null) "accessibility": accessibility,
      if (notes != null) "notes": notes,
      if (isActive != null) "isActive": isActive,
      if (createdBy != null) "createdBy": createdBy,
      if (createdStamp != null) "createdStamp": createdStamp,
      if (updatedBy != null) "updatedBy": updatedBy,
      "updatedStamp": DateTime.now(),
    };
  }
}
// [END add_data_custom_objects]