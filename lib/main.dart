import 'package:flutter/material.dart';
import 'package:firebase_app_clone/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this exists from flutterfire configure!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      home: SignUpPage(),
    ),
  );
}
