import 'package:flutter/material.dart';
//import 'package:tourism_guide/Screen/dashboard.dart';
import 'package:tourism_guide/Screen/login/login.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Tourist App',
        theme: ThemeData(
          // This is the theme of your application.
          //
          primarySwatch: Colors.blue,
        ),
        home: const Login());
  }
}
