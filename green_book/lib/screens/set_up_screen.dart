import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/rounded_button.dart';
import 'package:green_book/components/rounded_button_with_icon.dart';
import 'package:green_book/global/state.dart';
import 'package:green_book/models/g_book_user.dart';
import 'package:green_book/screens/welcome_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../constants.dart';
import '../models/faculty.dart';
import '../models/user_detail.dart';

final _fireStore = FirebaseFirestore.instance;

class SetUpScreen extends StatefulWidget {
  static const String id = 'ste_up_screen';
  const SetUpScreen({Key? key}) : super(key: key);

  @override
  State<SetUpScreen> createState() => _SetUpScreenState();
}

class _SetUpScreenState extends State<SetUpScreen> {
  User loggedInUser = GlobalState.user as User;
  List<UserDetail> users = [];
  GBookUser? currentUser;
  String? username;
  PlatformFile? pickedFile;
  Faculty? faculty;
  File? file;
  String profilePicPath = 'default.jpg';
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {

    final SetUpScreenArgs args = ModalRoute.of(context)?.settings.arguments as SetUpScreenArgs;
    bool loading = false;

    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        backgroundColor: kColorBackground,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: Text("It seems this is the first time visiting your account.", style: kHeadingStyleSecondary, textAlign: TextAlign.center,)),
              Text("Please set up your account.", style: kHeadingStyleBlackSmall.copyWith(fontSize: 20)),
              Text("Profile picture", style: kHeadingStyleBlackSmall.copyWith(fontSize: 25)),
              pickedFile == null ? const Text('No profile picture selected' , style: kHeadingStyleBlackSmall): const Text(''),
              if(pickedFile != null)
                SizedBox(
                  height: 200.0,
                  child: Image.file(
                      File(pickedFile?.path as String),
                      width: double.infinity,
                      fit: BoxFit.cover,
                  ),
                ),
              RoundedButtonWithIcon(
                  icon: Icons.image,
                  color: kColorSecondary,
                  title: 'Select Profile picture',
                  onClick: pickFile
              ),

              TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    username = value;
                  },
                  decoration: kInputDecoration.copyWith(
                      hintText: 'Enter your username'
                  )
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Please select your faculty", style: kHeadingStyleBlackSmall.copyWith(fontSize: 20),),
              ),

              ListTile(
                title: Text('${args.faculties[0].name} (${args.faculties[0].short})'),
                leading: Radio(
                  value: args.faculties[0],
                  groupValue: faculty,
                  onChanged: (Faculty? value) {
                    setState(() {
                      faculty = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('${args.faculties[1].name} (${args.faculties[1].short})'),
                leading: Radio(
                  value: args.faculties[1],
                  groupValue: faculty,
                  onChanged: (Faculty? value) {
                    setState(() {
                      faculty = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('${args.faculties[2].name} (${args.faculties[2].short})'),
                leading: Radio(
                  value: args.faculties[2],
                  groupValue: faculty,
                  onChanged: (Faculty? value) {
                    setState(() {
                      faculty = value;
                    });
                  },
                ),
              ),

              RoundedButton(
                  color: kColorPrimary,
                  title: 'Set Up',
                  onClick: () async{
                    setState(() {
                     loading = true;
                    });
                    uploadFile();
                    String? token = await saveToken();
                    GBookUser user = GBookUser(email: loggedInUser.email, profilePicImage: profilePicPath, username: username);
                    DocumentReference ref = await usersRef.add(user.toJson());
                    ref.update({
                      'faculty': faculty?.ref
                    });
                    if(token != null){
                      ref.update({
                        'device_token': token
                      });
                    }

                    currentUser = await retrieveUser();
                    List<DocumentReference> friends = await getFriends();
                    print('......................................................');
                    print(friends.length);
                    users = await getUsers(friends);
                    Navigator.pushNamed(context, WelcomeScreen.id, arguments: WelcomeScreenArgs(users: users));
                    setState(() {
                      loading = false;
                    });

                  })
            ],
          ),
        ),
      ),
    );
  }
  Future<String?> saveToken() async{
    return await FirebaseMessaging.instance.getToken();
  }
  
  Future<void> pickFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if(result != null){
      setState(() {
        final filename = loggedInUser.email;
        pickedFile = result.files.first;
        file = File(result.files.single.path as String);
        profilePicPath = '$filename';
      });
    }
  }

  Future<void> uploadFile()async {
    if(file != null){
      final filename = loggedInUser.email;
      final destination = 'profile_pics/$filename';
      try{
        final ref = FirebaseStorage.instance.ref(destination);
        await ref.putFile(file!);
      }on FirebaseException catch(e){
        print(e);
      }

    }
  }

  Future<List<DocumentReference>> getFriends() async => await _fireStore.doc(currentUser?.userRef?.path as String)
      .collection('friends').get().then((value) => value.docs.map((e) => e.get('user') as DocumentReference).toList());

  Future<List<UserDetail>> getUsers(List<DocumentReference> friends) async => await _fireStore
      .collection('users')
      .get()
      .then((snapshot) => snapshot.docs
      .map((document){
    UserDetail friendDetail = UserDetail.fromJson(document.data());
    friendDetail.ref = document.reference;
    friendDetail.isFriend = friends.contains(document.reference);
    print(friendDetail.isFriend);
    return friendDetail;
  }).where((friend) => friend.ref != currentUser?.userRef).toList());

  Future<List<UserDetail>> getUsersNoFriends() async => await _fireStore
      .collection('users')
      .get()
      .then((snapshot) => snapshot.docs
      .map((document){
    UserDetail friendDetail = UserDetail.fromJson(document.data());
    friendDetail.ref = document.reference;
    friendDetail.isFriend = false;
    return friendDetail;
  }).where((friend) => friend.ref != currentUser?.userRef).toList());


  Future<GBookUser> retrieveUser() async => await _fireStore
      .collection('users')
      .where('email', isEqualTo: loggedInUser.email)
      .get()
      .then(
          (value) {
        GBookUser gBookUser = GBookUser.fromJson(value.docs.single.data());
        gBookUser.userRef = value.docs.single.reference;
        return gBookUser;
      }
  ).catchError((e) => print(e));


}

class SetUpScreenArgs{
  List<Faculty> faculties;

  SetUpScreenArgs({required this.faculties});
}
