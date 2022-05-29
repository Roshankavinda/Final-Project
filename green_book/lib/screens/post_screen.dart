import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/post_widget_with_comment.dart';

import '../constants.dart';

class PostScreen extends StatefulWidget {
  static const String id = 'post_screen';
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {



  @override
  Widget build(BuildContext context) {

    final PostScreenArgs args = ModalRoute.of(context)?.settings.arguments as PostScreenArgs;

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
        backgroundColor: kColorSecondary,
      ),
      body: SingleChildScrollView(
        child: PostWidgetWithComment(
          description: args.description,
          photoPath: args.photoPath,
          user: args.user,
          likeCount: args.likeCount,
          likes: args.likes,
          postReference: args.postReference,
          documentPath: args.documentPath,
        ),
      ),
    );
  }
}

class PostScreenArgs{
  final String description;
  final String? photoPath;
  final DocumentReference user;
  final int likeCount;
  final String documentPath;
  final List<dynamic> likes;
  final DocumentReference postReference;


  PostScreenArgs(
      {required this.description,
      this.photoPath,
      required this.user,
      required this.likeCount,
      required this.documentPath,
      required this.likes,
      required this.postReference});
}
