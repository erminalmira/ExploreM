import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_guide/Screen/category/destination_information_page.dart';

class CategoryPage extends StatelessWidget {
  final String category;

  CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Category'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('category')
            .doc('category_type')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data available for this category'));
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('category')
                .doc('category_type')
                .collection(category)
                .snapshots(),
            builder: (context, listSnapshot) {
              if (listSnapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }

              if (listSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final data = listSnapshot.requireData;

              if (data.size == 0) {
                return Center(
                    child: Text('No data available for this category'));
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 2 / 2.5,
                ),
                itemCount: data.size,
                itemBuilder: (context, index) {
                  var item = data.docs[index];
                  var itemData = item.data();
                  var name = itemData['name'] ?? 'No name';
                  var fullName = itemData['full_name'] ?? 'No Full Name';
                  var imageUrl = itemData['imageURL'] ?? '';
                  var description =
                      itemData['description'] ?? 'No description available';
                  var address = itemData['address'] ?? 'No address available';
                  var coordinates = itemData['coordinates'] as GeoPoint?;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationInformationPage(
                            category: category,
                            documentId: item.id,
                            full_name: fullName,
                            description: description,
                            address: address,
                            imageURL: imageUrl,
                            coordinates: coordinates,
                          ),
                        ),
                      );
                    },
                    child: GridTile(
                      child: Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            Expanded(
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.error);
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey,
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
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
