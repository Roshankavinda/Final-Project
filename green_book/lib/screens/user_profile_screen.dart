import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:green_book/constants.dart';
import 'package:green_book/models/g_book_user.dart';
import 'package:lottie/lottie.dart';

import '../components/post_widget.dart';
import '../models/faculty.dart';
import '../models/user_detail.dart';

class UserProfileScreen extends StatefulWidget {
  static const String id = 'user_profile_screen';
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? username;

  @override
  Widget build(BuildContext context) {


    final UserProfileScreenArgs args = ModalRoute.of(context)?.settings.arguments as UserProfileScreenArgs;
    username = args.username;
    return Scaffold(
      backgroundColor: kColorBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(args.profilePicPath),
                  ),
                  FutureBuilder(
                    future: retrieveUser(),
                    builder: (context, snapshot){
                      if(!snapshot.hasData){
                        return Container( child: Lottie.asset('assets/loading.json'));
                      }else{
                        GBookUser user = snapshot.data as GBookUser;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Name - ', style: kHeadingStyleBlackSmall,),
                                Text(user.username as String, style: kHeadingStyleBlackSmall,),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Email - ', style: kHeadingStyleBlackSmall,),
                                Text(user.email as String, style: kHeadingStyleBlackSmall,),
                              ],
                            ),
                            FutureBuilder(
                                future: getFaculty(user.faculty as DocumentReference),
                                builder: (context, snapshot){
                                  if(!snapshot.hasData){
                                    return Container( child: Lottie.asset('assets/loading.json'));
                                  }else{
                                    Faculty faculty = snapshot.data as Faculty;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Faculty - ', style: kHeadingStyleBlackSmall,),
                                        Text(faculty.name, style: kHeadingStyleBlackSmall,),
                                        Text(' (${faculty.short})', style: kHeadingStyleBlackSmall,)
                                      ],
                                    );
                                  }
                                }
                             ),
                            PostStream(userRef: user.userRef as DocumentReference),
                          ],
                        );
                      }
                    },
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
  Future<GBookUser> retrieveUser() async => await FirebaseFirestore.instance.collection('users')
      .where('username', isEqualTo: username)
      .get()
      .then(
          (value) {
            GBookUser userDetail = GBookUser.fromJson(value.docs.single.data());
            userDetail.userRef = value.docs.single.reference;
            userDetail.faculty = value.docs.single.get('faculty');
            return userDetail;
          }
  ).catchError((e) => print(e));

  Future<Faculty> getFaculty(DocumentReference facultyRef) async => await FirebaseFirestore.instance
      .doc(facultyRef.path)
      .get()
      .then((snapshot) {
    Faculty faculty = Faculty.fromJson(snapshot.data() as Map<String, dynamic>);
    faculty.ref = snapshot.reference;
    faculty.tags = snapshot.reference.collection('tags');
    return faculty;
  });
}


class PostStream extends StatelessWidget {
  final DocumentReference userRef;
  const PostStream({Key? key, required this.userRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('ready', isEqualTo: true)
            .where('user', isEqualTo: userRef)
            .orderBy('timestamp').snapshots(),
        builder: (context, snapshot){
          List<PostWidget> postContainers = [];
          if(!snapshot.hasData){
            Container( child: Lottie.asset('assets/loading.json'));
          }else{
            final posts = snapshot.data!.docs;
            for(var post in posts){
              final path = post.reference.path;
              final description = post.get('description');
              final photoPath = post.get('image_path');
              DocumentReference userRef = post.get('user');
              final likeCount = post.get('like_count');
              final likes = post.get('likes');
              final commentCount = post.get('comment_count');
              final postContainer = PostWidget(
                description: description,
                photoPath: photoPath,
                user: userRef,
                likeCount: likeCount,
                documentPath: path,
                likes: likes,
                postReference: post.reference,
                commentCount: commentCount,
              );
              postContainers.add(postContainer);
            }
          }
          return Column(
            children: postContainers,
          );
        }
    );
  }
}

class UserProfileScreenArgs{
  final String username;
  final String profilePicPath;

  UserProfileScreenArgs({required this.username, required this.profilePicPath});
}
