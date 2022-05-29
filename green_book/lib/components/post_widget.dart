import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/rounded_icon_button.dart';
import 'package:green_book/components/user_avatar_with_name_widget.dart';
import 'package:green_book/global/state.dart';
import 'package:green_book/models/g_book_user.dart';
import 'package:green_book/screens/post_screen.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';



class PostWidget extends StatelessWidget {


  final String description;
  final String? photoPath;
  final DocumentReference user;
  final int likeCount;
  final int commentCount;
  final String documentPath;
  final List<dynamic> likes;
  final DocumentReference postReference;


  const PostWidget({Key? key, required this.description, required this.photoPath, required this.user, required this.likeCount, required this.documentPath, required this.likes, required this.postReference, required this.commentCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, PostScreen.id, arguments: PostScreenArgs(description: description, user: user, likeCount: likeCount, documentPath: documentPath, likes: likes, postReference: postReference,photoPath: photoPath));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 5.0,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: kColorBackground),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: FutureBuilder<GBookUser>(
                          future: retrievePostUser(),
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
                              GBookUser? postUser = snapshot.data;
                              String profilePicPath = postUser?.profilePicImage as String;
                              return UserAvatarWithNameWidget(profilePicPath: profilePicPath, username: postUser?.username as String);
                            }
                          }
                      ),
                    ),
                    if(user == GlobalState.gBookUser?.userRef)
                      InkWell(
                        onTap: () async{
                          await FirebaseFirestore.instance.doc(postReference.path).delete();
                          await FirebaseStorage.instance.ref('posts/$photoPath').delete();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.delete),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                  child: Text(description),
                ),
                if(photoPath != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                        future: FirebaseStorage.instance.ref('posts/$photoPath').getDownloadURL(),
                        builder: (context, snapshot){
                          if(!snapshot.hasData){
                            return Container(
                                color: kColorBackground,
                                height: 200,
                                child: Lottie.asset('assets/loading.json')
                            );
                          }else{
                            return Container(
                                color: kColorBackground,
                                height: 200,
                                child: Image.network(snapshot.data as String)
                            );
                          }
                        }
                    ),
                  ),
                ReactionSection(likeCount: likeCount, documentPath: documentPath, likes: likes, postReference: postReference, commentCount: commentCount,),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<GBookUser> retrievePostUser() async => await FirebaseFirestore.instance.doc(user.path)
      .get()
      .then(
          (value) => GBookUser.fromJson(value.data() as Map<String, dynamic>)
  ).catchError((e) => print(e));
}

class CommentSection extends StatelessWidget {
  final DocumentReference postReference;
  final commentEditingController = TextEditingController();

  CommentSection({Key? key, required this.postReference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? comment;
    double deviceWidth = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            color: kColorBackground,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: deviceWidth * 0.6,
                    child: TextField(
                        controller: commentEditingController,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          comment = value;
                        },
                        decoration: kInputDecoration.copyWith(
                            hintText: 'Comment'
                        )
                    ),
                  ),
                  RoundedIconButton(
                      color: kColorPrimary,
                      icon: Icons.send,
                      onClick: () async{
                        commentEditingController.clear();
                        CollectionReference ref = FirebaseFirestore.instance.collection('${postReference.path}/comments');
                        await ref.add({
                          'content': comment,
                          'user': GlobalState.gBookUser?.userRef,
                          'time_stamp': DateTime.now().toIso8601String()
                        });
                      })
                ],
              ),
            ),
          ),
          Container(
            color: kColorSecondaryLight,
            height: 300,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('${postReference.path}/comments').orderBy('time_stamp').snapshots(),
              builder: (context, snapshot){
                List<CommentWidget> commentWidgets = [];
                if(!snapshot.hasData){
                  Container( child: Lottie.asset('assets/loading.json'));
                }else{
                  final comments = snapshot.data?.docs;
                  for(var comment in comments!){
                    final content = comment.get('content');
                    final user = comment.get('user');
                    final commentWidget = CommentWidget(content: content, userRef: user);
                    commentWidgets.add(commentWidget);
                  }

                }
                return ListView(
                  padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0) ,
                  children: commentWidgets,
                );
              },
            ),
          ),
        ],
      );








  }
}


class ReactionSection extends StatefulWidget {
  final int likeCount;
  final String documentPath;
  final List<dynamic> likes;
  final DocumentReference postReference;
  final int commentCount;





  const ReactionSection(
      {Key? key, required this.likeCount, required this.documentPath, required this.likes, required this.postReference, required this.commentCount}) : super(key: key);

  @override
  State<ReactionSection> createState() => _ReactionSectionState();
}

class _ReactionSectionState extends State<ReactionSection> {

  bool commentToggle = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:  [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:  [
                  LikeButton(documentPath: widget.documentPath, likeCount: widget.likeCount, likes: widget.likes),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Text(widget.likeCount.toString()),
                  ),
                ],
              ),
              Row(
                children:  [
                  const Icon(
                    Icons.comment,
                    color: Colors.grey
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Text(widget.commentCount.toString()),
                  ),
                ],
              ),
            ],
          ),
        ),
        commentToggle? CommentSection(postReference: widget.postReference) : Container(height: 0,)

      ],
    );
  }
}





class LikeButton extends StatefulWidget {
  final String documentPath;
  final int likeCount;
  final List<dynamic> likes;


  const LikeButton({required this.documentPath, required this.likeCount, required this.likes});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}
class _LikeButtonState extends State<LikeButton> {

  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.likes.contains(GlobalState.gBookUser?.userRef);
    return TextButton(
        child: Icon(Icons.thumb_up, color: isLiked ?  kColorPrimary : Colors.grey),
        onPressed: () async{
          var item = [GlobalState.gBookUser?.userRef];

              if(isLiked){
                setState(() {
                });
                FirebaseFirestore.instance.doc(widget.documentPath).update({
                  "like_count": widget.likeCount - 1,
                  'likes': FieldValue.arrayRemove(item)
                });
              }else{
                setState(() {
                });
                FirebaseFirestore.instance.doc(widget.documentPath).update({
                  "like_count": widget.likeCount + 1,
                  'likes': FieldValue.arrayUnion(item)
                });

              }
        }
    );
  }
}


class CommentWidget extends StatelessWidget {
  final String content;
  final DocumentReference userRef;


  const CommentWidget({required this.content, required this.userRef});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 5.0,
        child: Container(
          color: kColorBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<GBookUser>(
                  future: retrieveCommentUser(),
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
                      GBookUser? commentUser = snapshot.data;
                      String profilePicPath = commentUser?.profilePicImage as String;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 30,
                            child: Row(
                              children: [
                                FutureBuilder<String>(
                                    future: FirebaseStorage.instance.ref('profile_pics/$profilePicPath').getDownloadURL(),
                                    builder: (context ,snapshot){
                                      if(!snapshot.hasData){
                                        return const CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey,
                                        );
                                      }else{
                                        String url = snapshot.data as String;
                                        return CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(url),
                                        );
                                      }
                                    }
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      constraints: const BoxConstraints(maxHeight: 80),
                                      child: Text(commentUser?.username as String)),
                                )
                              ],
                            )
                        ),
                      );
                    }
                  }
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: kColorBackground,
                    child: Text(content),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future<GBookUser> retrieveCommentUser() async => await FirebaseFirestore.instance.doc(userRef.path)
      .get()
      .then(
          (value) => GBookUser.fromJson(value.data() as Map<String, dynamic>)
  ).catchError((e) => print(e));
}




