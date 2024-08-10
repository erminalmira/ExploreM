import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_guide/Screen/dashboard/dashboard.dart';
import 'package:tourism_guide/Screen/login/signup.dart';
import 'package:tourism_guide/Screen/login/forgot_password.dart'; // Import forgot_password

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text,
        password: passCtrl.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DashBoardPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code}');
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }
      });
    } catch (e) {
      log('Exception: $e');
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
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
          // Image and Title in Blue Section
          Positioned(
            top: MediaQuery.of(context).size.height * 0.002,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  "assets/image/login.jpg",
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 3),
                const Text(
                  "ExploreM",
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 113, 49, 130),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Login Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height *
                      0.25), // Adjust this value to move the card lower
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
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
                      const SizedBox(height: 60),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          hintText: "Enter Your Email",
                          labelText: "Email Address",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: emailCtrl,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
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
                      Row(
                        children: [
                          Checkbox(value: true, onChanged: (value) {}),
                          const Text("Remember Me"),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPassword(),
                                ),
                              );
                            },
                            child: const Text("Forgot Password?"),
                          ),
                        ],
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
                        onPressed: login,
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Signup(),
                                ),
                              );
                            },
                            child: const Text("Create an account"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
