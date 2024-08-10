import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_guide/Screen/category/destination_information_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

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

  void _searchDestination(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      List<DocumentSnapshot> results = [];

      for (String subCollection in subCollections) {
        QuerySnapshot searchSnapshot = await FirebaseFirestore.instance
            .collection('category')
            .doc('category_type')
            .collection(subCollection)
            .where('keyword', arrayContains: query)
            .get();

        results.addAll(searchSnapshot.docs);
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search for a destination',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchDestination('');
                  },
                ),
              ),
              onChanged: _searchDestination,
            ),
            _isLoading
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        final coordinates = item['coordinates'] as GeoPoint?;

                        if (coordinates == null) {
                          return ListTile(
                            title: Text('Invalid coordinates'),
                          );
                        }

                        return ListTile(
                          title: Text(item['full_name'] ?? 'No name'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DestinationInformationPage(
                                  category: item['category'],
                                  documentId: item.id,
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
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
