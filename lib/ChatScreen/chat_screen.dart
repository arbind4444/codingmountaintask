import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemtask/FbLogin/login_view.dart';
import 'package:codemtask/Providers/google_signing_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/chat_argument_model.dart';
import '../Models/message_chat_model.dart';
import '../Providers/chat_providers.dart';
import '../Utilities/ColorX.dart';
import '../Utilities/firebase_constants.dart';
import '../Utilities/user_loading.dart';




class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.arguments}) : super(key: key);

  final ChatPageArguments arguments;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late String currentUserId;
  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = "";
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late ChatProvider chatProvider;
  late GoogleSigningAuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<GoogleSigningAuthProvider>();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginView()),
        (Route<dynamic> route) => false,
      );
    }
    String peerId = widget.arguments.peerId;
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





  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(
          content, type, groupChatId, currentUserId, widget.arguments.peerId);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      //Fluttertoast.showToast(msg: 'message send', backgroundColor: Colors.grey);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    print('document uis   ----->>>$document');
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
             messageChat.type == TypeMessage.text ?
            Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                    child: Text(
                      messageChat.content,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ):Container()
          ],
        );
      } else {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? messageChat.type == TypeMessage.text
                      ? Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                      messageChat.content,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                      : Container()
                      : Container(width: 35),
                ],
              ),
              // Time
              // isLastMessageLeft(index)
              //     ? Container(
              //         margin:
              //             const EdgeInsets.only(left: 50, top: 5, bottom: 5),
              //         child:  Text(
              //           //messageChat.timestamp
              //           DateFormat('dd MMM kk:mm').format(
              //               DateTime.fromMillisecondsSinceEpoch(
              //                   int.parse(messageChat.timestamp)))
              //           ,
              //           style: TextStyle(
              //               color: ColorConstants.greyColor,
              //               fontSize: 12,
              //               fontStyle: FontStyle.italic),
              //         ),
              //       )
              //     : const SizedBox.shrink()
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.arguments.peerNickname,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            )),
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  buildListMessage(),
                  buildInput(),
                ],
              ),
              buildLoading()
            ],
          ),
        ),
      ),
    );
  }



  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const LoadingView() : const SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.teal, width: 0.5)),
          color: Colors.teal),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, TypeMessage.text);
                },
                style: const TextStyle(
                    color: Colors.white, fontSize: 15),
                controller: textEditingController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: ColorConstants.greyColor),
                ),
                focusNode: focusNode,
                autofocus: true,
              ),
            ),
            Container(
              color: Colors.teal,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                  color: ColorConstants.primaryColor,
                onPressed: () {
                  setState(() {
                    onSendMessage(textEditingController.text, TypeMessage.text);
                  });
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  print('last message is --->>$listMessage');
                 if(listMessage.isNotEmpty){
                   MessageChat.fromDocument(listMessage.first);
                 }
                  if (listMessage.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return const Center(child: Text("No message here yet..."));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.themeColor,
                    ),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
    );
  }
}
