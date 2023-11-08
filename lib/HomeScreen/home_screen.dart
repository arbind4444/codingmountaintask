import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemtask/FbLogin/login_view.dart';
import 'package:codemtask/Providers/google_signing_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../ChatScreen/chat_screen.dart';
import '../Models/chat_argument_model.dart';
import '../Models/user_chat_model.dart';
import '../Providers/chat_providers.dart';
import '../Providers/home_screen_providers.dart';
import '../Utilities/ColorX.dart';
import '../Utilities/dBouncer.dart';
import '../Utilities/firebase_constants.dart';
import '../Utilities/popup_choice.dart';
import '../Utilities/user_loading.dart';
import '../Utilities/utils.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key? key});
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;
  late GoogleSigningAuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  DBouncer searchDebouncer = DBouncer(milliseconds: 300);
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();


  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<GoogleSigningAuthProvider>();
    homeProvider = context.read<HomeProvider>();
    chatProvider = context.read<ChatProvider>();

    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginView()),
            (Route<dynamic> route) => false,
      );
    }
    listScrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }


  void scrollListener() {
    if (listScrollController.offset >=
        listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginView()));
    }
  }


  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: Colors.teal,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.check_circle,
                       // color: ColorConstants.primaryColor,
                      ),
                    ),
                    const Text(
                      'Yes',
                      style: TextStyle(
                         // color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  Future<void> handleSignOut() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signOut().then((value) {
        authProvider.googleSignOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
              (Route<dynamic> route) => false,
        );
      });
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          "CodeMountainChat",
          style: TextStyle(color:Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions:  <Widget>[
          GestureDetector(
            onTap: (){
              logOut();

            },
            child: const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.login_outlined,
              color: Colors.white,
            ),
                    ),
          ),],
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: <Widget>[
              // List
              Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: homeProvider.getStreamFireStore(
                          FirestoreConstants.pathUserCollection,
                          _limit,
                          _textSearch),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if ((snapshot.data?.docs.length ?? 0) > 0) {
                            return ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemBuilder: (context, index) => buildItem(
                                  context, snapshot.data?.docs[index]),
                              itemCount: snapshot.data?.docs.length,
                              controller: listScrollController,
                            );
                          } else {
                            return const Center(
                              child: Text("No users"),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                             // color: ColorConstants.primaryColor,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              // Loading
              Positioned(
                child:
                isLoading ? const LoadingView() : const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }

  String groupChatId =
      "PDtD2QgDy5d5zgwJgKR3m7McHAB3-22chF89dnJViIUyYOs7a3A5JhaS2";
  // List<QueryDocumentSnapshot> listMessage = [];
  List<QueryDocumentSnapshot> message = [];





  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginView()),
            (Route<dynamic> route) => false,
      );
    }
    String peerId = currentUserId;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  String chatiddd = "";

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      chatiddd = userChat.id;
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return Container(
          margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
          child: TextButton(
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }
              print('data is' + userChat.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    arguments: ChatPageArguments(
                      peerId: userChat.id,
                      peerAvatar: userChat.photoUrl,
                      peerNickname: userChat.nickname,
                    ),
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(Colors.teal),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                    userChat.photoUrl,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorConstants.primaryColor,
                            value: loadingProgress.expectedTotalBytes !=
                                null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(
                        Icons.account_circle,
                        size: 50,
                        color: ColorConstants.primaryColor,
                      );
                    },
                  )
                      : const Icon(
                    Icons.account_circle,
                    size: 50,
                    color: ColorConstants.primaryColor,
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text(
                            'Nickname: ${userChat.nickname}',
                            maxLines: 1,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            'About me: ${userChat.aboutMe}',
                            maxLines: 1,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                //Text('dr' + userChat.id),
                // userChat.id.isNotEmpty
                //     ? StreamBuilder<QuerySnapshot>(
                //         stream: chatProvider.getChatStream(userChat.id, _limit),
                //         builder: (BuildContext context,
                //             AsyncSnapshot<QuerySnapshot> snapshot) {
                //           if (snapshot.hasData) {
                //             message = snapshot.data!.docs;
                //
                //             MessageXChat messageChat =
                //                 MessageXChat.fromDocument(message.first);
                //             print('mess amit:' + messageChat.content);
                //             // print('mess' + listMessage.first.toString());
                //             if (message.isNotEmpty) {
                //               return Text(messageChat.content);
                //             } else {
                //               return const Center(
                //                   child: Text("No message here yet..."));
                //             }
                //           } else {
                //             return const Center(
                //               child: CircularProgressIndicator(
                //                 color: ColorConstants.themeColor,
                //               ),
                //             );
                //           }
                //         },
                //       )
                //     : const Center(
                //         child: CircularProgressIndicator(
                //           color: ColorConstants.themeColor,
                //         ),
                //       ),

////delete

                // StreamBuilder<QuerySnapshot>(
                //   stream: chatProvider.getChatStream(userChat.id, _limit),
                //   builder: (BuildContext context,
                //       AsyncSnapshot<QuerySnapshot> snapshot) {
                //     if (snapshot.hasData) {
                //       listMessage = snapshot.data!.docs;
                //       if (listMessage.isNotEmpty) {
                //         return Text('data');
                //         // ListView.builder(
                //         //   padding: const EdgeInsets.all(10),
                //         //   itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                //         //   itemCount: snapshot.data?.docs.length,
                //         //   reverse: true,
                //         //   controller: listScrollController,
                //         // );
                //       } else {
                //         return const Center(
                //             child: Text("No message here yet..."));
                //       }
                //     } else {
                //       return const Center(
                //         child: CircularProgressIndicator(
                //           color: ColorConstants.themeColor,
                //         ),
                //       );
                //     }
                //   },
                // )
                // StreamBuilder<QuerySnapshot>(
                //   stream: homeProvider.getStreamFireStore(
                //       FirestoreConstants.pathUserCollection,
                //       _limit,
                //       _textSearch),
                //   builder: (BuildContext context,
                //       AsyncSnapshot<QuerySnapshot> snapshot) {
                //     if (snapshot.hasData) {
                //       if ((snapshot.data?.docs.length ?? 0) > 0) {
                //         return Text(snapshot.data!.docs.length.toString());
                //         // ListView.builder(
                //         //   padding: const EdgeInsets.all(10),
                //         //   itemBuilder: (context, index) {
                //         //     return Text('data');
                //         //   },
                //         //   //  =>
                //         //   //     buildItem(context, snapshot.data?.docs[index]),
                //         //   itemCount: snapshot.data?.docs.length,
                //         //   controller: listScrollController,
                //         // );
                //       } else {
                //         return const Center(
                //           child: Text("No users"),
                //         );
                //       }
                //     } else {
                //       return const Center(
                //         child: CircularProgressIndicator(
                //           color: ColorConstants.primaryColor,
                //         ),
                //       );
                //     }
                //   },
                // ),
                // Text(userChat.id)
              ],
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
  Future<void> logOut() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: Colors.teal,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const Icon(
                        Icons.logout,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Log Out',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Are you sure to Log Out?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  handleSignOut();
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.check_circle,
                        // color: ColorConstants.primaryColor,
                      ),
                    ),
                    const Text(
                      'Yes',
                      style: TextStyle(
                        // color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }
}

