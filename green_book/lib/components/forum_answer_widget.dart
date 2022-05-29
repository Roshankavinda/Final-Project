import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/rounded_button_with_icon.dart';

import 'package:green_book/components/user_avatar_with_name_widget.dart';
import 'package:green_book/models/faculty.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';
import '../models/forum_answer.dart';
import '../models/user_detail.dart';


class ForumAnswerWidget extends StatelessWidget {

  final ForumAnswer answer;

  const ForumAnswerWidget({Key? key, required this.answer}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    Future downloadFile({required String storagePath, required String filename}) async{
      Reference ref = FirebaseStorage.instance.ref('$storagePath/$filename');
      final url = await ref.getDownloadURL();
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/${ref.name}';
      print(path);
      // print(await ref.getMetadata().then((value) => value.contentType.toString())))
      await Dio().download(url, path);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded ${ref.name}')));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                            future: getFaculty(friendDetail?.faculty as DocumentReference),
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
              Text(answer.answer, style: kHeadingStyleSecondary.copyWith(fontSize: 20),),
              if(answer.attachmentPath != null)
                RoundedButtonWithIcon(color: kColorPrimary, title: 'Download Attachment', onClick:() => downloadFile(storagePath: 'answers',filename: answer.attachmentPath as String), icon: Icons.download,),
            ],
          ),
        ),
      ),
    );
  }

  Future<Faculty> getFaculty(DocumentReference faculty) async => await FirebaseFirestore.instance.doc(faculty.path)
      .get()
      .then((snapshot){
          Faculty faculty = Faculty.fromJson(snapshot.data() as Map<String, dynamic>);
          faculty.ref = snapshot.reference;
          faculty.tags = snapshot.reference.collection('tags');
          return faculty;
      });



  Future<UserDetail> retrieveFriends() async => await FirebaseFirestore.instance.doc(answer.user.path)
      .get()
      .then(
          (value) => UserDetail.fromJson(value.data() as Map<String, dynamic>)
  ).catchError((e) => print(e));

}
