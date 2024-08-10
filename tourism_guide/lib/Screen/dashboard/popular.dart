import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_guide/database/database_helper.dart';
import 'package:tourism_guide/Screen/category/destination_information_page.dart';

class PopularDestinationSection extends StatefulWidget {
  const PopularDestinationSection({super.key});

  @override
  _PopularDestinationSectionState createState() =>
      _PopularDestinationSectionState();
}

class _PopularDestinationSectionState extends State<PopularDestinationSection> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Popular Destination',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            height: 200.0,
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _dbHelper.getAttractions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No destinations found'));
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
                    var coordinates = data['coordinates'] as GeoPoint;

                    return _buildPlaceCard(
                      imageURL,
                      name,
                      fullName,
                      category,
                      documentId,
                      coordinates,
                      data['description'],
                      data['address'],
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
    String imageURL,
    String name,
    String fullName,
    String category,
    String documentId,
    GeoPoint coordinates,
    String? description,
    String? address,
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
              description: description ?? 'No description available',
              address: address ?? 'No address available',
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
