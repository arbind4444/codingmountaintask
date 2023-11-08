import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemtask/Providers/fb_auth_method_providers.dart';
import 'package:codemtask/SplashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Providers/chat_providers.dart';
import 'Providers/google_signing_providers.dart';
import 'Providers/home_screen_providers.dart';

Future main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp( CodeMountainTask(prefs: prefs));
}

class CodeMountainTask extends StatelessWidget {
  final SharedPreferences? prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CodeMountainTask({super.key,  this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GoogleSigningAuthProvider>(
          create: (_) => GoogleSigningAuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            prefs: prefs!,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        ChangeNotifierProvider(create: (_) => FBAuthMethod()),
        Provider<HomeProvider>(
          create: (_) => HomeProvider(
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
            prefs: prefs!,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}