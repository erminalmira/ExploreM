import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_guide/Screen/login/login.dart'; // Import the Login page

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _userName = userDoc['name'] ?? 'User';
        _nameController.text = _userName!;
      });
    }
  }

  Future<void> _changePassword() async {
    try {
      await _user.updatePassword(_passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password successfully changed'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password change failed: $e'),
      ));
    }
  }

  Future<void> _updateUserName() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .update({'name': _nameController.text});
      setState(() {
        _userName = _nameController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Name successfully updated'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Name update failed: $e'),
      ));
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              color: Colors.lightBlue[50],
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    "assets/image/user.png",
                    height: 100, // Increase the height to make the image larger
                    width: 100, // Increase the width to make the image larger
                    fit: BoxFit.cover, // Ensure the image covers the space
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _userName ?? 'Loading...',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Edit Name'),
                                content: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await _updateUserName();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    _user.email!,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Change Password'),
                      content: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _changePassword();
                            Navigator.of(context).pop();
                          },
                          child: Text('Change'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _logout,
              child: Text('LOG OUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[50], // Button color
                padding: EdgeInsets.symmetric(
                    vertical: 15), // Add padding for height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Add border radius
                ),
                minimumSize:
                    Size(double.infinity, 50), // Ensure it takes full width
              ),
            ),
          ],
        ),
      ),
    );
  }
}
