import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'popular.dart';
import 'nearby.dart';
import 'package:tourism_guide/Screen/category/category_page.dart';
import 'package:tourism_guide/Screen/wishlist.dart'; // Import the WishlistPage
import 'package:tourism_guide/Screen/profile.dart'; // Import the ProfilePage
import 'package:tourism_guide/Screen/search.dart'; // Import the SearchPage

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  DashBoardPageState createState() => DashBoardPageState();
}

class DashBoardPageState extends State<DashBoardPage> {
  int _selectedIndex = 0;
  Position? _currentPosition;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchUserName();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ?? 'User';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WishlistPage(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
        break;
    }
  }

  void _onCategorySelected(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: ListView(
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: 20.0),
          _buildCategorySection(),
          const SizedBox(height: 20.0),
          _buildPopularDestinationSection(),
          const SizedBox(height: 20.0),
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : _buildNearbyDestinationSection(_currentPosition!),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 25.0,
            backgroundImage: AssetImage('assets/image/user.png'),
          ),
          const SizedBox(width: 12.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome, ${_userName ?? 'Loading...'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
              const Text(
                'Explore tourist attractions in Malaysia!',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildCategoryItem(Icons.local_mall, 'Mall', 'mall'),
              _buildCategoryItem(Icons.park, 'Parks', 'parks'),
              _buildCategoryItem(Icons.beach_access, 'Beaches', 'beaches'),
              _buildCategoryItem(Icons.museum, 'Museums', 'museums'),
              _buildCategoryItem(Icons.pets, 'Wildlife', 'wildlife'),
              _buildCategoryItem(Icons.store, 'Markets', 'markets'),
              _buildCategoryItem(
                  Icons.emoji_events, 'Theme Park', 'theme park'),
              _buildCategoryItem(Icons.mosque, 'Mosque', 'mosque'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, String category) {
    return GestureDetector(
      onTap: () => _onCategorySelected(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.lightBlue.shade100,
            ),
            child: Icon(icon, size: 40, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildPopularDestinationSection() {
    return const PopularDestinationSection();
  }

  Widget _buildNearbyDestinationSection(Position position) {
    return NearbyDestinationSection(currentPosition: position);
  }
}
