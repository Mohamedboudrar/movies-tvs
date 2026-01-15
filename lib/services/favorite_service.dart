import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(_uid);

  CollectionReference get _favouritesCol =>
      _userDoc.collection('favourites');

  /// ADD favourite + increment count
  Future<void> addFavourite({
    required int id,
    required String title,
    required String posterPath,
    required String type,
  }) async {
    final favDoc = _favouritesCol.doc(id.toString());

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(favDoc);

      if (!snapshot.exists) {
        transaction.set(favDoc, {
          'id': id,
          'title': title,
          'posterPath': posterPath,
          'type': type,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(_userDoc, {
          'favouritesCount': FieldValue.increment(1),
        });
      }
    });
  }

  /// REMOVE favourite + decrement count
  Future<void> removeFavourite(int id) async {
    final favDoc = _favouritesCol.doc(id.toString());

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(favDoc);

      if (snapshot.exists) {
        transaction.delete(favDoc);
        transaction.update(_userDoc, {
          'favouritesCount': FieldValue.increment(-1),
        });
      }
    });
  }

  /// CHECK favourite
  Stream<bool> isFavourite(int id) {
    return _favouritesCol
        .doc(id.toString())
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// GET favourites
  Stream<QuerySnapshot> getFavourites() {
    return _favouritesCol
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
