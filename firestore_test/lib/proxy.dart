import './model/service.dart';
import './model/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Proxy {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Proxy();

  Future<void> addData(Provider provider) async {
    // [START add_data_custom_objects]
    await firestore.collection('providers').add(provider.toFirestore());
    // [END add_data_custom_objects]
  }

  Future<void> updateData(Provider provider) async {
    // [START add_data_custom_objects]
    await firestore
        .collection('providers')
        .doc(provider.id)
        .set(provider.toFirestore());
    // [END add_data_custom_objects]
  }

  Future<void> upsertData(dynamic item) async {
    // [START add_data_custom_objects]
    final String collection;
    switch (item.runtimeType) {
      case Provider:
        collection = 'providers';
        break;
      case Service:
        collection = 'services';
        break;
      default:
        throw Exception('Unknown type');
    }

    if (item.id == null) {
      await firestore.collection(collection).add(item.toFirestore());
    } else {
      await firestore
          .collection(collection)
          .doc(item.id)
          .set(item.toFirestore());
    }
  }

  Future<Iterable<Provider>> list() async {
    // [START add_data_custom_objects]
    final ref = firestore.collection("providers").withConverter(
          fromFirestore: Provider.fromFirestore,
          toFirestore: (Provider provider, _) => provider.toFirestore(),
        );
    final snapshot =
        await ref.get().then((value) => value.docs.map((e) => e.data()));

    return snapshot;
    // [END add_data_custom_objects]
  }
}
