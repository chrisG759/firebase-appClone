import 'package:flutter/material.dart';
import 'package:firebase_app_clone/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'signup.dart';
import 'login.dart';// Make sure this exists from flutterfire configure!
import 'projects.dart';

const Color backgroundColor = Color(0xFF7D8DE2);
const Color backgroundColor2 = Color(0xFF00A1FF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(),
    )
  );
}

class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          spacing: 200,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: Align(
                  child: Column(
                    children: [
                      Text("Project Manager", style: TextStyle(fontSize: 50, color: Colors.white),),
                      Text("Organize your life, today!", style: TextStyle(color: Colors.white, fontSize: 25),)
                    ],
                  ),
                )
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                  spacing: 30,
                  children: [
                    MaterialButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpPage())
                        );
                      },
                      color: Colors.white,
                      height: 75,
                      elevation: 12,
                      minWidth: 200,
                      child: Text("Signup", style: TextStyle(color: Colors.blue, fontSize: 25),),
                    ),
                    Text("Already Have an account?", style: TextStyle(color: Colors.white, fontSize: 25)),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage())
                        );
                      },
                      color: Colors.blue,
                      height: 75,
                      elevation: 12,
                      minWidth: 200,
                      child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 25),),
                    )
                  ]
              ),
            ),
          ],
        ),
      )
    );
  }
}
