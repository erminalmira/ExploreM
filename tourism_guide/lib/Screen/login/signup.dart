import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  Future<void> signup() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text,
        password: passCtrl.text,
      );

      // Add user details to Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': nameCtrl.text,
        'email': emailCtrl.text,
      });

      // Navigate to the dashboard or home page after successful sign up
      Navigator.pop(context); // Return to the login page
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width / 1.2;
    return Scaffold(
      body: Stack(
        children: [
          // Blue Background
          Container(
            color: Colors.lightBlue[50],
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
          ),
          // Signup Card
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Create new Account",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color.fromARGB(255, 113, 49, 130),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Already Registered? Log in here.",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        hintText: "Enter Your Name",
                        labelText: "Name",
                      ),
                      keyboardType: TextInputType.text,
                      controller: nameCtrl,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        hintText: "Enter Your Email",
                        labelText: "Email",
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: emailCtrl,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        hintText: "Enter Your Password",
                        labelText: "Password",
                      ),
                      keyboardType: TextInputType.text,
                      controller: passCtrl,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[50],
                        fixedSize: Size(screenwidth, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: signup,
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
