import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/rounded_button.dart';
import 'package:green_book/constants.dart';
import 'package:green_book/global/state.dart';
import 'package:green_book/models/group.dart';
import 'package:green_book/screens/welcome_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../components/group_post_widget.dart';
import '../components/rounded_button_with_icon.dart';


final _fireStore = FirebaseFirestore.instance;


class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);
  static const String id = 'group_screen';

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    final GroupScreenArgs args = ModalRoute.of(context)?.settings.arguments as GroupScreenArgs;
    Group group = args.group;
    bool isMember = group.users.contains(GlobalState.gBookUser?.userRef);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 100,
          toolbarHeight: 70,
          backgroundColor: kColorSecondary,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<String>(
              future: FirebaseStorage.instance.ref('groups/${group.ref.id}/profile/${group.imagePath}').getDownloadURL(),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                  );
                }else{
                  String url = snapshot.data as String;
                  return CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(url),
                  );
               }
              }),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Wall',),
              Tab(icon: Icon(Icons.add), text: 'Add Post',)
            ],
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
          title: Text(group.name),
        ),
        body: TabBarView(
          children: [
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:  [
                if(isMember)
                  PostStream(group: group,)
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('You are not a member of this group', style: kHeadingStyleBlackSmall,),
                        RoundedButton(
                            color: kColorSecondary,
                            title: 'Join Group',
                            onClick: () async{
                              var item = [GlobalState.gBookUser?.userRef];
                              await group.ref.update({
                                'users': FieldValue.arrayUnion(item)
                              });
                              setState(() {
                                group.users.add(GlobalState.gBookUser?.userRef as DocumentReference);
                              });
                            }
                        )
                      ],
                    ),
                  ),

              ],
            ),
          ),
            AddPost(groupRef: args.group.ref),
          ]
        ),
      ),
    );
  }
}

class PostStream extends StatelessWidget {
  final Group group;
  const PostStream({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.doc(group.ref.path).collection('posts').where('ready', isEqualTo: true).orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot){
          List<GroupPostWidget> postContainers = [];
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
              bool deletePrivilege = false;
              if(group.adminRef == GlobalState.gBookUser?.userRef){
                deletePrivilege = true;
              }
              if(GlobalState.gBookUser?.userRef == userRef){
                deletePrivilege = true;
              }
              final postContainer = GroupPostWidget(
                description: description,
                photoPath: photoPath,
                user: userRef,
                likeCount: likeCount,
                documentPath: path,
                likes: likes,
                postReference: post.reference,
                group: group,
                deletePrivilege: deletePrivilege,
              );
              postContainers.add(postContainer);
            }
          }
          return Flexible(
            child: ListView(
              padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0) ,
              children: postContainers,
            ),
          );
        }
    );
  }
}

class AddPost extends StatefulWidget {
  final DocumentReference groupRef;
  const AddPost({required this.groupRef,Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {

  String? description;
  PlatformFile? pickedFile;
  File? file;
  TextEditingController postController = TextEditingController();
  

  bool loading = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {

    return ModalProgressHUD(
      inAsyncCall: loading,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Add a Post', style: kHeadingStyleSecondary,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: pickedFile == null ?
                    const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No Image Selected',
                            style: kHeadingStyleBlackSmall,),
                        )
                    ): SizedBox(
                      height: 200.0,
                      child: Image.file(
                        File(pickedFile?.path as String),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RoundedButtonWithIcon(
                        icon: Icons.image,
                        color: kColorPrimary,
                        title: 'Add Image',
                        onClick:  pickFile
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Description - ', style: kHeadingStyleBlackSmall,),
                  ),
                  error ? Text("Description can't be empty", style: kHeadingStyleBlackSmall.copyWith(color: Colors.red),) : const Text(''),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: postController,
                          minLines: 1, // any number you need (It works as the rows for the textarea)
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onChanged: (value){
                            description = value;
                          },
                        ),
                      ),
                    ),
                  ),
                  RoundedButton(
                      color: kColorSecondary,
                      title: 'Post',
                      onClick: () async{

                        if(description == null){
                          setState(() {
                            error = true;
                          });
                        }else{
                          setState(() {
                            loading = true;
                          });
                          if(pickedFile != null){
                            DocumentReference ref = await widget.groupRef.collection('posts').add({
                              'description': description,
                              'image_path': null,
                              'like_count': 0,
                              'comment_count':0,
                              'likes': [],
                              'ready': false,
                              'timestamp': DateTime.now().toIso8601String(),
                              'user': GlobalState.gBookUser?.userRef
                            });
                            await uploadFile(filename: ref.id, groupId: widget.groupRef.id);
                            await ref.update({
                              'image_path': ref.id,
                              'ready': true
                            });
                          }else{
                            await _fireStore.collection('posts').add({
                              'description': description,
                              'image_path': null,
                              'like_count': 0,
                              'comment_count':0,
                              'likes': [],
                              'ready': true,
                              'timestamp': DateTime.now().toIso8601String(),
                              'user': GlobalState.gBookUser?.userRef
                            });
                          }

                          postController.clear();
                          setState(() {
                            loading = false;
                            pickedFile = null;
                          });
                        }
                      }),
                ],
              ),
            )
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

  Future<void> uploadFile({required String filename, required String groupId})async {
    if(file != null){
      final destination = 'groups/$groupId/posts/$filename';
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

class GroupScreenArgs{
  Group group;

  GroupScreenArgs({required this.group});
}

