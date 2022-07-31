import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator_app/pages/homepage.dart';
import 'package:geolocator_app/pages/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    Widget starterPage;

    if (firebaseUser != null) {
      starterPage = HomePage();
    } else {
      starterPage = SignIn();
    }
    return MaterialApp(
      title: 'Geolocator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: starterPage,
    );
  }
}
