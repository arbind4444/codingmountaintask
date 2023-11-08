import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../FbLogin/login_view.dart';
import '../Models/user_chat_model.dart';
import '../Utilities/firebase_constants.dart';

class FBAuthMethod extends ChangeNotifier{

  Future<User?> fbSignUp(String name, String email, String password) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print("Account created successfully");
      userCredential.user!.updateDisplayName(name);
      await firestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(auth.currentUser!.uid)
          .set({
        "nickname": name,
        "email": email,
        "status": "Unavailable",
        "id": auth.currentUser!.uid
      });
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      print(e);
      notifyListeners();
      return null;

    }

  }

  Future<User?> fbLogIn(String email, String password) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(credential);
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) => credential.user!.updateDisplayName(value['nickname']));

      print(credential.user!.uid);
      print('refreshtoken' + credential.user!.refreshToken.toString());

      if (credential != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: credential.user!.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(credential.user!.uid)
              .set({
            FirestoreConstants.nickname: credential.user!.displayName,
            FirestoreConstants.photoUrl: credential.user!.photoURL,
            FirestoreConstants.id: credential.user!.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });
          await prefs.setString(FirestoreConstants.id, credential.user!.uid);
          await prefs.setString(
              FirestoreConstants.nickname, credential.user!.displayName ?? "");
          await prefs.setString(
              FirestoreConstants.photoUrl, credential.user!.photoURL ?? "");
        } else {
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
        }
      } else {}
      return credential.user;
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

  Future<User?> fbLogOut(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signOut().then((value) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginView()));
      });
    } catch (e) {
      print('Error $e');
    }
    return null;
  }



}