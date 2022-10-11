import 'package:cloud_firestore/cloud_firestore.dart';

class Test {
  final String? id;
  final String? a;
  final String? b;
  final List<String>? c;

  Test({
    this.id,
    this.a,
    this.b,
    this.c,
  });

  factory Test.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // print(snapshot.id);
    return Test(
      id: snapshot.id,
      a: data?['a'],
      b: data?['b'],
      c: data?['c'] is Iterable ? List.from(data?['c']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (a != null) "a": a,
      if (b != null) "b": b,
      if (c != null) "c": c,
    };
  }
}
// [END add_data_custom_objects]