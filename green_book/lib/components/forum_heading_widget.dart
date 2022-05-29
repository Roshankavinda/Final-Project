
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/rounded_button_with_icon.dart';

import 'package:green_book/components/user_avatar_with_name_widget.dart';
import 'package:green_book/models/faculty.dart';
import 'package:green_book/models/forum_question.dart';
import 'package:path_provider/path_provider.dart';


import '../constants.dart';
import '../models/user_detail.dart';
import '../models/tag.dart';

class ForumHeadingWidget extends StatelessWidget {

  final ForumQuestion question;

  const ForumHeadingWidget({Key? key, required this.question}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    Future downloadFile({required String storagePath, required String filename}) async{
      Reference ref = FirebaseStorage.instance.ref('$storagePath/$filename');
      final url = await ref.getDownloadURL();
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/${ref.name}';
      print(path);
      await Dio().download(url, path);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded ${ref.name}')));
    }

    return Material(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder<UserDetail>(
              future: retrieveFriends(),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        color: kColorBackground,
                        height: 40,
                        child: Row(
                          children: const [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
                            ),
                            Text('loading')
                          ],
                        )
                    ),
                  );
                }else{
                  UserDetail? friendDetail = snapshot.data;
                  String profilePicPath = friendDetail?.profilePicImage as String;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UserAvatarWithNameWidget(
                        profilePicPath: profilePicPath,
                        username: friendDetail?.username as String,
                      ),
                      FutureBuilder<Faculty>(
                          future: getFaculty(),
                          builder: (context, snapshot){
                            Faculty? faculty;
                            if(!snapshot.hasData){
                              return const Text("Loading.....");
                            }else{
                              faculty = snapshot.data;
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child:
                              Material(
                                borderRadius: BorderRadius.circular(30.0),
                                color: kColorSecondary,
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: Text(faculty?.short as String, style: kHeadingStyleWhiteSmall,)),
                                ),
                              ),
                            );
                          }
                      )
                    ],
                  );

                }
              },
            ),
            Text(question.question, style: kHeadingStyleSecondary,),
            FutureBuilder<List<Tag>>(
                future: getTags(),
                builder: (context, snapshot){
                  List<Padding> tagWidgets = [];
                  if(!snapshot.hasData){
                    return const SizedBox(
                        height: 60,
                        child: Text("Loading....")
                    );
                  }else{
                    List<Tag>? tags = snapshot.data;
                    for(var tag in tags!){
                      final tagWidget = Padding(
                        padding: const EdgeInsets.all(8),
                        child:
                        Material(
                          borderRadius: BorderRadius.circular(30.0),
                          color: kColorSecondary,
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(tag.name, style: kHeadingStyleWhiteSmall,)),
                          ),
                        ),
                      );
                      tagWidgets.add(tagWidget);
                    }
                  }
                  return SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: tagWidgets,
                      )
                  );
                }
            ),
            if(question.attachmentPath != null)
              RoundedButtonWithIcon(color: kColorPrimary, title: 'Download Attachment', onClick:() => downloadFile(storagePath: 'questions',filename: question.attachmentPath as String), icon: Icons.download,),
          ],
        ),
      ),
    );

  }



  Future<Faculty> getFaculty() async => await FirebaseFirestore.instance.doc(question.faculty.path)
      .get()
      .then((snapshot){
          Faculty faculty = Faculty.fromJson(snapshot.data() as Map<String, dynamic>);
          faculty.ref = snapshot.reference;
          faculty.tags = snapshot.reference.collection('tags');
          return faculty;
      });

  Future<List<Tag>> getTags() async {
    List<Tag> tags = [];
    for(DocumentReference tag in question.tags) {
      Tag tagObj = await FirebaseFirestore.instance.doc(tag.path).get().then((snapshot) => Tag.fromJson(snapshot.data() as Map<String, dynamic>));
      tags.add(tagObj);
    }
    return tags;
  }

  Future<UserDetail> retrieveFriends() async => await FirebaseFirestore.instance.doc(question.user.path)
      .get()
      .then(
          (value) => UserDetail.fromJson(value.data() as Map<String, dynamic>)
  ).catchError((e) => print(e));

  Future<void> wait() async{
    await retrieveFriends();
    await getTags();
}
}
