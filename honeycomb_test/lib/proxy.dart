import './model/client.dart';
import './model/user.dart';
import './model/resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Proxy {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Proxy();

  Future<dynamic> upsert(dynamic item) async {
    // [START add_data_custom_objects]
    final String collection;
    switch (item.runtimeType) {
      case MPUser:
        collection = 'users';
        break;
      case Client:
        collection = 'clients';
        break;
      case Resource:
        collection = 'resources';
        break;
      default:
        throw Exception('Unknown type');
    }

    final ref = _getRef(collection);

    if (item.id == null) {
      item.createdStamp = DateTime.now();
      return await ref.add(item);
    } else {
      return await ref.doc(item.id).set(item);
    }
  }

  Future<dynamic> get(String collection, String id) async {
    final ref = _getRef(collection);
    final snapshot = await ref.doc(id).get();
    if (snapshot.exists) {
      return snapshot.data();
    } else {
      return null;
    }
  }

  CollectionReference<Object> _getRef(String collection) {
    return firestore.collection(collection).withConverter(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot,
              SnapshotOptions? options) {
            switch (collection) {
              case 'users':
                return MPUser.fromFirestore(snapshot, options);
              case 'clients':
                return Client.fromFirestore(snapshot, options);
              case 'resources':
                return Resource.fromFirestore(snapshot, options);
              default:
                throw Exception('Unknown type');
            }
          },
          toFirestore: (dynamic item, _) => item.toFirestore(),
        );
  }

  Future<Iterable<dynamic>> list(String collection) async {
    // [START add_data_custom_objects]
    final ref = _getRef(collection);

    final snapshot =
        await ref.get().then((value) => value.docs.map((e) => e.data()));

    return snapshot;
    // [END add_data_custom_objects]
  }

  Future<Iterable<dynamic>> filter(String collection, Map conditions) async {
    // [START add_data_custom_objects]
    var ref = _getRef(collection);
    var query = ref.where('id', isNotEqualTo: null);

    conditions.forEach((key, value) {
      if (value is List) {
        for (var mapKey in value) {
          query = query.where('$key.$mapKey', isEqualTo: true);
        }
      } else {
        query = query.where(key, isEqualTo: value);
      }
    });

    final snapshot =
        await query.get().then((value) => value.docs.map((e) => e.data()));

    return snapshot;
    // [END add_data_custom_objects]
  }

  Future<Iterable<dynamic>> listByIds(
      String collection, List<String> ids) async {
    List<dynamic> ret = [];

    for (var id in ids) {
      var item = await get(collection, id);
      if (item != null) {
        ret.add(item);
      }
    }

    return ret;
    // [END add_data_custom_objects]
  }

  Future<Iterable<dynamic>> listUserFavorites(MPUser user) async {
    return await listByIds('resources', user.favorites ?? []);
  }

  Future<Iterable<dynamic>> listUserClients(MPUser user) async {
    return await listByIds('clients', user.clients ?? []);
  }

  Future<Iterable<dynamic>> listClientResources(Client client) async {
    return await listByIds('resources', client.resources ?? []);
  }

  // Future<User> getUser(String id) async {
  //   final ref = firestore.collection('users');
  //   var rawUser = await ref.doc(id).get();
  //   if (rawUser.exists) {
  //     return User.fromFirestore(rawUser, null);
  //   } else {
  //     final user = User(id: id, favorites: [], clients: []);
  //     final ref = firestore.collection('users');
  //     await ref.doc(id).set(user.toFirestore());
  //     return user;
  //   }
  // }

  // Future<dynamic> getUser(String email) async {
  //   final users = await filter('users', {'email': email});

  //   if (users.isEmpty) {
  //     final user = User(email: email, favorites: [], clients: []);
  //     return await upsert(user);
  //   } else {
  //     return users.first;
  //   }
  // }

  Future<dynamic> getUser(String id) async {
    var users = await get('users', id);

    if (users == null) {
      final user = MPUser(id: id, favorites: [], clients: []);
      return await upsert(user);
    } else {
      return users;
    }
  }

  Future<Iterable<dynamic>> searchResources(String key) async {
    final resources = await list('resources');
    final keyLower = key.toLowerCase();

    return resources.where((resource) {
      final map = resource.toFirestore();

      for (var value in map.values) {
        if (value is String) {
          if (value.toLowerCase().contains(keyLower)) {
            return true;
          }
        } else if (value is Map) {
          for (var innerKey in value.keys) {
            if (value[innerKey] == true) {
              if (innerKey.toLowerCase().contains(keyLower)) {
                return true;
              }
            }
          }
        }
      }

      return false;
    });
  }
}