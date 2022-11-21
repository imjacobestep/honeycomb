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
        query = query.where(key, arrayContainsAny: value);
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

  Iterable<dynamic> sort(
      Iterable<dynamic> items, String field, bool ascending) {
    if (ascending) {
      if (field == 'name') {
        return items.toList()..sort((a, b) => a.name!.compareTo(b.name!));
      } else if (field == 'createdStamp') {
        return items.toList()
          ..sort((a, b) => a.createdStamp!.compareTo(b.createdStamp!));
      } else if (field == 'updatedStamp') {
        return items.toList()
          ..sort((a, b) => a.updatedStamp!.compareTo(b.updatedStamp!));
      } else {
        throw Exception('Unknown field');
      }
    } else {
      if (field == 'name') {
        return items.toList()..sort((a, b) => b.name!.compareTo(a.name!));
      } else if (field == 'createdStamp') {
        return items.toList()
          ..sort((a, b) => b.createdStamp!.compareTo(a.createdStamp!));
      } else if (field == 'updatedStamp') {
        return items.toList()
          ..sort((a, b) => a.updatedStamp!.compareTo(b.updatedStamp!));
      } else {
        throw Exception('Unknown field');
      }
    }
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

  Future<dynamic> delFromList(dynamic subject, dynamic item) async {
    if (subject is MPUser) {
      if (item is Resource) {
        subject.favorites!.remove(item.id);
      } else if (item is Client) {
        subject.clients!.remove(item.id);
      }
    } else if (subject is Client) {
      if (item is Resource) {
        subject.resources!.remove(item.id);
      }
    }

    return await upsert(subject);
  }

  Future<dynamic> addToList(dynamic subject, dynamic item) async {
    if (subject is MPUser) {
      if (item is Resource) {
        if (subject.favorites!.contains(item.id)) {
          return subject;
        } else {
          subject.favorites!.add(item.id!);
          return await upsert(subject);
        }
      } else if (item is Client) {
        if (subject.clients!.contains(item.id)) {
          return subject;
        } else {
          subject.clients!.add(item.id!);
          return await upsert(subject);
        }
      } else {
        throw Exception('Unknown type');
      }
    } else if (subject is Client) {
      if (item is Resource) {
        if (subject.resources!.contains(item.id)) {
          return subject;
        } else {
          subject.resources!.add(item.id!);
          return await upsert(subject);
        }
      } else {
        throw Exception('Unknown type');
      }
    } else {
      throw Exception('Unknown type');
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
