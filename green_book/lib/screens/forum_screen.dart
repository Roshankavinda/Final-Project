import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/forum_answer_widget.dart';
import 'package:green_book/components/forum_heading_widget.dart';
import 'package:green_book/components/rounded_button.dart';
import 'package:green_book/components/rounded_button_with_icon.dart';
import 'package:green_book/constants.dart';
import 'package:green_book/global/state.dart';
import 'package:green_book/models/forum_answer.dart';
import 'package:green_book/models/forum_question.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ForumScreen extends StatefulWidget {
  static const String id = 'forum_screen';
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final answerTextController = TextEditingController();
  PlatformFile? pickedFile;
  File? file;

  @override
  Widget build(BuildContext context) {
    String answer = '';
    final ForumScreenArgs args = ModalRoute.of(context)?.settings.arguments as ForumScreenArgs;
    bool loading = false;
    return Scaffold(
      backgroundColor: kColorSecondaryLight,
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            color: kColorSecondaryLight,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: ForumHeadingWidget(question: args.question,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Answers', style: kHeadingStyleBlackSmall.copyWith(fontSize: 25),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: answerTextController,
                          minLines: 1, // any number you need (It works as the rows for the textarea)
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onChanged: (value){
                            answer = value;
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: pickedFile == null ? const Text('No attachments'): Text(pickedFile?.name as String),
                  ),
                  RoundedButtonWithIcon(
                      color: kColorPrimary,
                      title: 'Add Attachment',
                      icon: Icons.attach_file,
                      onClick: pickFile
                  ),
                  RoundedButton(
                      color: kColorSecondary,
                      title: 'Post Answer',
                      onClick: () async{
                        setState(() {
                          loading = true;
                        });
                        if(pickedFile != null){
                          DocumentReference ref = await args.question.answers.add({
                            'answer': answer,
                            'timestamp': DateTime.now().toIso8601String(),
                            'user': GlobalState.gBookUser?.userRef,
                            'ready': false
                          });
                          await uploadFile(ref.id);
                          await ref.update({
                            'attachment_path': ref.id,
                            'ready': true
                          });
                        }else{
                          await args.question.answers.add({
                            'answer': answer,
                            'timestamp': DateTime.now().toIso8601String(),
                            'user': GlobalState.gBookUser?.userRef,
                            'attachment_path': null,
                            'ready': true
                          });
                        }
                        setState(() {
                          pickedFile = null;
                          loading = false;
                        });
                        answerTextController.clear();
                      }
                  ),
                  AnswerStream(answersRef: args.question.answers)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> pickFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if(result != null){
      setState(() {
        pickedFile = result.files.first;
        file = File(result.files.single.path as String);
      });
    }
  }

  Future<void> uploadFile(String filename)async {
    if(file != null){
      final destination = 'answers/$filename';
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




class AnswerStream extends StatelessWidget {
  final CollectionReference answersRef;
  const AnswerStream({Key? key, required this.answersRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: answersRef.where('ready', isEqualTo: true).orderBy('timestamp').snapshots(),
        builder: (context, snapshot){
          List<ForumAnswerWidget> answerWidgets = [];
          if(!snapshot.hasData){
            return Container(
                child: Lottie.asset('assets/loading.json')
            );
          }else{
            final answers = snapshot.data?.docs;
            for(var answer in answers!){
              String answerText = answer.get('answer');
              String? attachmentPath = answer.get('attachment_path');
              DocumentReference user = answer.get('user');
              DocumentReference ref = answer.reference;
              ForumAnswer forumAnswer = ForumAnswer(answer: answerText, user: user, attachmentPath: attachmentPath, reference: ref);
              ForumAnswerWidget answerWidget  = ForumAnswerWidget(answer: forumAnswer);
              answerWidgets.add(answerWidget);
            }
          }
          if(answerWidgets.isEmpty){
            return const Center(child: Text('No Answers Yet.'));
          }
          return Column(
            children: answerWidgets,
          );
        }
    );
  }
}



class ForumScreenArgs{
  ForumQuestion question;

  ForumScreenArgs({required this.question});
}
