import 'dart:async';
import 'package:codemtask/FbLogin/login_view.dart';
import 'package:codemtask/HomeScreen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String pass = 'login';

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((userpass) {
      if (userpass == null) {
        print('user pass in null is ------$userpass');
        pass = "login";
      } else {
        print('user pass is ------$userpass');
        pass = "s";
      }
    });
    Timer(const Duration(seconds: 3), () {
      if (pass == "login") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginView()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Image.network('https://images.unsplash.com/photo-1589802829985-817e51171b92?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NXx8fGVufDB8fHx8fA%3D%3D'
                ,fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              ),
              const Positioned(
                top: 130,
                bottom: 0,
                left: 20,
                right: 0,
                child:  Text(
                'CodeMountain\nTask',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                    color: Colors.teal),
              ),)
            ],
          ),
        ));
  }
}
