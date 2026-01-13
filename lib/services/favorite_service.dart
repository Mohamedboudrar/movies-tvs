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

  /// ADD favourite
  Future<void> addFavourite({
    required int id,
    required String title,
    required String posterPath,
    required String type, // "movie" or "tv"
  }) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favourites')
        .doc(id.toString()) // prevents duplicates
        .set({
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// REMOVE favourite
  Future<void> removeFavourite(int id) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favourites')
        .doc(id.toString())
        .delete();
  }

  /// CHECK if favourite (live)
  Stream<bool> isFavourite(int id) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('favourites')
        .doc(id.toString())
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// GET all favourites
  Stream<QuerySnapshot> getFavourites() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('favourites')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
