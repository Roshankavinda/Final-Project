import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/tag_widget.dart';

import 'package:green_book/components/user_avatar_with_name_widget.dart';
import 'package:green_book/models/faculty.dart';
import 'package:green_book/models/forum_question.dart';
import 'package:green_book/screens/forum_screen.dart';

import '../constants.dart';
import '../models/user_detail.dart';
import '../models/tag.dart';

class ForumQuestionWidget extends StatelessWidget {

  final ForumQuestion question;

  const ForumQuestionWidget({Key? key, required this.question}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, ForumScreen.id, arguments: ForumScreenArgs(question: question));
      },
      child: Padding(
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
                            decoration: BoxDecoration(
                              color: kColorBackground,
                              borderRadius: BorderRadius.circular(10)
                            ),
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
                          Row(
                              children: [
                                if(question.attachmentPath != null)
                                  const Icon(Icons.attachment),
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
                                ),
                          ]
                          ),

                        ],
                      );

                    }
                  },
                ),
                Text(question.question, style: kHeadingStyleSecondary,),
                FutureBuilder<List<Tag>>(
                    future: getTags(),
                    builder: (context, snapshot){
                      List<TagWidget> tagWidgets = [];
                      if(!snapshot.hasData){
                        return const SizedBox(
                            height: 60,
                            child: Text("Loading....")
                        );
                      }else{
                        List<Tag>? tags = snapshot.data;
                        for(var tag in tags!){
                          final tagWidget = TagWidget(tag: tag);
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
                )
              ],
            ),
          ),
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
  );

  Future<void> wait() async{
    await retrieveFriends();
    await getTags();
}
}


