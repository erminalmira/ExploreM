import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';

class DatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> subCollections = [
    'mall',
    'parks',
    'beaches',
    'museums',
    'wildlife',
    'markets',
    'theme park',
    'mosque'
  ];

  Future<void> addAttraction(Map<String, dynamic> attraction) async {
    await _firestore
        .collection('category')
        .doc('category_type')
        .collection(attraction['category'])
        .add(attraction);
  }

  Stream<List<DocumentSnapshot>> getAttractions() {
    List<Stream<QuerySnapshot>> streams = [];
    for (var subCollection in subCollections) {
      streams.add(
        _firestore
            .collection('category')
            .doc('category_type')
            .collection(subCollection)
            .where('review', isGreaterThan: 8)
            .snapshots(),
      );
    }

    return CombineLatestStream.list(streams).map((snapshots) {
      final allDocs = snapshots.expand((snapshot) => snapshot.docs).toList();
      return allDocs;
    });
  }

  Future<DocumentSnapshot> getDocument(String category, String documentId) {
    return _firestore
        .collection('category')
        .doc('category_type')
        .collection(category)
        .doc(documentId)
        .get();
  }

  Stream<List<DocumentSnapshot>> getNearbyPlaces(
      double userLat, double userLon) {
    List<Stream<List<DocumentSnapshot>>> streams = [];
    for (var subCollection in subCollections) {
      streams.add(
        _firestore
            .collection('category')
            .doc('category_type')
            .collection(subCollection)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.where((doc) {
            var data = doc.data();
            if (data.containsKey('coordinates') &&
                data['coordinates'] != null) {
              GeoPoint location = data['coordinates'];
              double distance = Geolocator.distanceBetween(
                userLat,
                userLon,
                location.latitude,
                location.longitude,
              );
              return distance <= 10000; // 10 km radius
            } else {
              return false;
            }
          }).toList();
        }),
      );
    }

    return Rx.combineLatest<List<DocumentSnapshot>, List<DocumentSnapshot>>(
        streams, (list) {
      return list.expand((x) => x).toList();
    });
  }

  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection('category').snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCategoryDocument(
      String category) {
    return _firestore.collection('category').doc('category_type').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategoryLists(
      String category) {
    return _firestore
        .collection('category')
        .doc('category_type')
        .collection(category)
        .snapshots();
  }
}
