import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationInformationPage extends StatefulWidget {
  final String? category;
  final String? documentId;
  final String? full_name;
  final String? description;
  final String? imageURL;
  final String? address;
  final GeoPoint? coordinates;

  const DestinationInformationPage({
    Key? key,
    this.category,
    this.documentId,
    this.full_name,
    this.description,
    this.imageURL,
    this.address,
    this.coordinates,
  }) : super(key: key);

  @override
  _DestinationInformationPageState createState() =>
      _DestinationInformationPageState();
}

class _DestinationInformationPageState
    extends State<DestinationInformationPage> {
  String? _mapStyle;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // Load map style from assets
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(widget.documentId);

      DocumentSnapshot doc = await wishlistRef.get();
      if (doc.exists) {
        setState(() {
          _isSaved = true;
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(widget.documentId);

      if (_isSaved) {
        await wishlistRef.delete();
        setState(() {
          _isSaved = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from Wishlist')),
        );
      } else {
        await wishlistRef.set({
          'category': widget.category,
          'documentId': widget.documentId,
          'full_name': widget.full_name,
          'description': widget.description,
          'imageURL': widget.imageURL,
          'address': widget.address,
          'coordinates': widget.coordinates,
        });
        setState(() {
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to Wishlist')),
        );
      }
    }
  }

  void _launchMaps(double latitude, double longitude) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destination Information'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.favorite : Icons.favorite_border,
              color: _isSaved ? Colors.red : null,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.imageURL != null && widget.imageURL!.isNotEmpty
                  ? Image.network(
                      widget.imageURL!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.image_not_supported),
                    ),
              const SizedBox(height: 16.0),
              Text(
                widget.full_name ?? 'No name available',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Address',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.address ?? 'No address available',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'About',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.description ?? 'No description available',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Location',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              widget.coordinates != null
                  ? Container(
                      width: double.infinity,
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(widget.coordinates!.latitude,
                              widget.coordinates!.longitude),
                          zoom: 15,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          controller.setMapStyle(_mapStyle);
                        },
                        markers: {
                          Marker(
                            markerId: MarkerId('destination'),
                            position: LatLng(widget.coordinates!.latitude,
                                widget.coordinates!.longitude),
                          ),
                        },
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.map),
                    ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.coordinates != null) {
                      _launchMaps(widget.coordinates!.latitude,
                          widget.coordinates!.longitude);
                    }
                  },
                  child: const Text('Show Route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
