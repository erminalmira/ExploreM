import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tourism_guide/database/database_helper.dart';
import 'package:tourism_guide/Screen/category/destination_information_page.dart';

class NearbyDestinationSection extends StatelessWidget {
  final Position currentPosition;

  const NearbyDestinationSection({
    Key? key,
    required this.currentPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper _dbHelper = DatabaseHelper();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Recommended Places Nearby',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            height: 200.0,
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _dbHelper.getNearbyPlaces(
                currentPosition.latitude,
                currentPosition.longitude,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No places found'));
                }

                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: snapshot.data!.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var imageURL = data['imageURL'] ?? '';
                    var name = data['name'] ?? 'No Name';
                    var fullName = data['full_name'] ?? 'No Full Name';
                    var category = data['category'] ?? '';
                    var documentId = doc.id;
                    var description =
                        data['description'] ?? 'No description available';
                    var address = data['address'] ?? 'No address available';
                    var coordinates = data['coordinates'] as GeoPoint;

                    return _buildPlaceCard(
                      context,
                      imageURL,
                      name,
                      fullName,
                      category,
                      documentId,
                      description,
                      address,
                      coordinates,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(
    BuildContext context,
    String imageURL,
    String name,
    String fullName,
    String category,
    String documentId,
    String description,
    String address,
    GeoPoint coordinates,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationInformationPage(
              category: category,
              documentId: documentId,
              full_name: fullName,
              description: description,
              address: address,
              imageURL: imageURL,
              coordinates: coordinates,
            ),
          ),
        );
      },
      child: Container(
        width: 160.0,
        margin: const EdgeInsets.only(right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            imageURL.isNotEmpty
                ? Image.network(
                    imageURL,
                    width: 160.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 160.0,
                    height: 100.0,
                    color: Colors.grey,
                    child: const Icon(Icons.image_not_supported),
                  ),
            const SizedBox(height: 8.0),
            Text(
              name,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
