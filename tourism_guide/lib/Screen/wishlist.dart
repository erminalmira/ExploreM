import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_guide/Screen/category/destination_information_page.dart'; // Adjust the path as necessary

class WishlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.currentUser != null
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('wishlist')
                .snapshots()
            : null,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final wishlistItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final item = wishlistItems[index];
              final coordinates = item['coordinates'] as GeoPoint;
              return ListTile(
                leading: item['imageURL'] != null
                    ? Image.network(item['imageURL'],
                        width: 100, fit: BoxFit.cover)
                    : Container(width: 100, color: Colors.grey),
                title: Text(item['full_name'] ?? 'No name'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DestinationInformationPage(
                        category: item['category'],
                        documentId: item['documentId'],
                        full_name: item['full_name'],
                        description: item['description'],
                        imageURL: item['imageURL'],
                        address: item['address'],
                        coordinates: coordinates,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
