

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_book/components/notification_badge.dart';
import 'package:green_book/global/state.dart';
import 'package:green_book/models/user_detail.dart';
import 'package:green_book/models/g_book_user.dart';
import '../components/message_bubble.dart';
import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
GBookUser? currentUser = GlobalState.gBookUser;
PlatformFile? pickedFile;
File? file;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({Key? key}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();

  String? messageText;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    final ChatScreenArgs args = ModalRoute.of(context)?.settings.arguments as ChatScreenArgs;




    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions:[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // messagesStream();
                Navigator.pop(context);
              }),
        ],
        title: Text(args.friendDetail.username as String),
        backgroundColor: kColorSecondary,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessagesStream(chatRef: args.chatRef),
            if(pickedFile != null)
              Container(
                color: kColorSecondaryLight,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 150.0,
                    child: Image.file(
                      File(pickedFile?.path as String),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  InkWell(
                      onTap:() async{
                        await pickFile();
                      },
                      child: const Icon(Icons.image)
                  ),
                  FlatButton(
                    onPressed: () async{
                      if(pickedFile != null && messageText != null){
                        DocumentReference ref = await _firestore.doc(args.chatRef.path).collection('messages').add({
                          'text': messageText,
                          'sender': currentUser?.userRef,
                          'timestamp': DateTime.now().toIso8601String(),
                          'ready': false
                        });
                        await uploadFile(ref.path);
                        await ref.update({
                          'image_path': ref.path,
                          'ready': true
                        });
                      }else if(pickedFile == null && messageText != null){
                        await _firestore.doc(args.chatRef.path).collection('messages').add({
                          'text': messageText,
                          'sender': currentUser?.userRef,
                          'timestamp': DateTime.now().toIso8601String(),
                          'ready': true,
                          'image_path': null
                        });
                      }else if(pickedFile != null && messageText ==null){
                        DocumentReference ref = await _firestore.doc(args.chatRef.path).collection('messages').add({
                          'text': '',
                          'sender': currentUser?.userRef,
                          'timestamp': DateTime.now().toIso8601String(),
                          'ready': false
                        });
                        await uploadFile(ref.path);
                        await ref.update({
                          'image_path': ref.path,
                          'ready': true
                        });
                      }
                      messageTextController.clear();
                      setState((){
                        pickedFile = null;
                        messageText = null;
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> pickFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if(result != null){
      setState(() {
        pickedFile = result.files.first;
        file = File(result.files.single.path as String);
      });
    }
  }

  Future<void> uploadFile(String filename)async {
    if(file != null){
      final destination = filename;
      try{
        final ref = FirebaseStorage.instance.ref(destination);
        await ref.putFile(file!);
      }on FirebaseException catch(e){
        if (kDebugMode) {
          print(e);
        }
      }

    }
  }
}

class MessagesStream extends StatelessWidget {
  final DocumentReference chatRef;


  const MessagesStream({Key? key, required this.chatRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.doc(chatRef.path).collection('messages').where('ready', isEqualTo: true).orderBy('timestamp').snapshots(),
        builder: (context, snapshot){
          List<MessageBubble> messageWidgets = [];
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: kColorPrimaryLight ,
              ),
            );
          }
          final messages = snapshot.data!.docs;
          for(var message in messages){
            final messageText = message.get('text');
            DocumentReference messageSender = message.get('sender');
            final isSender = GlobalState.gBookUser?.userRef?.id == messageSender.id ? true:false;
            if(!isSender){
              const NotificationBadge(totalNotificationValue: 0,);
            }
            final time = message.get('timestamp');
            String? imagePath = message.get('image_path');
            String timeString = time.toString();
            print(timeString);
            final messageBubble = MessageBubble(time: timeString,text: messageText, isSender: isSender,imagePath: imagePath,);
            messageWidgets.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
              children: messageWidgets,
            ),
          );
        }
    );
  }
}

class ChatScreenArgs{
  DocumentReference friendRef;
  DocumentReference userRef;
  UserDetail friendDetail;
  DocumentReference chatRef;
  ChatScreenArgs({required this.friendRef, required this.userRef, required this.friendDetail, required this.chatRef});
}




