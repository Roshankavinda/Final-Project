import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:green_book/constants.dart';
import 'package:green_book/models/g_book_user.dart';
import 'package:green_book/screens/set_up_screen.dart';
import 'package:green_book/screens/welcome_screen.dart';
import 'package:green_book/utilities/user_secure_storage.dart';
import 'package:lottie/lottie.dart';

import '../global/state.dart';
import '../models/faculty.dart';
import '../models/user_detail.dart';

class MainLoadingScreen extends StatefulWidget {
  static const String id = 'main_loading_screen';
  const MainLoadingScreen({Key? key}) : super(key: key);

  @override
  State<MainLoadingScreen> createState() => _MainLoadingScreenState();
}

class _MainLoadingScreenState extends State<MainLoadingScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  User? loggedInUser = GlobalState.user;
  List<UserDetail> users = [];
  GBookUser? currentUser;

  @override
  void initState() {
    checkUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      color: kColorBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Image.asset('images/logo_short.png'),
            Container(
              child: Lottie.asset('assets/main_loading.json'),
            ),
        ],

      ),
    );
  }
  Future checkUser() async => await _fireStore
      .collection('users')
      .where('email', isEqualTo: loggedInUser?.email)
      .get()
      .then(
          (value) async{
            if(loggedInUser == null){
              String? email = await UserSecureStorage.getUsername();
              String? password = await UserSecureStorage.getPassword();
              await _auth.signInWithEmailAndPassword(email: email as String, password: password as String);
              GlobalState.user = _auth.currentUser as User;
              loggedInUser = GlobalState.user;
            }
            if(value.size == 0){
              List<Faculty> faculties = await getFaculties();
              Navigator.pushNamed(context, SetUpScreen.id, arguments: SetUpScreenArgs(faculties: faculties));
            }else{
              currentUser = await retrieveUser();
              List<DocumentReference> friends = await getFriends();
              users = await getUsers(friends);
              Navigator.pushNamed(context, WelcomeScreen.id, arguments: WelcomeScreenArgs(users: users));
            }
          }
  ).catchError((e) => print(e));

  Future<List<Faculty>> getFaculties() async => await FirebaseFirestore.instance
      .collection('faculty')
      .get()
      .then((snapshot) => snapshot.docs
      .map((document){
    Faculty faculty = Faculty.fromJson(document.data());
    faculty.ref = document.reference;
    faculty.tags = document.reference.collection('tags');
    return faculty;
  }).toList());

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


  Future<GBookUser> retrieveUser() async => await _fireStore
      .collection('users')
      .where('email', isEqualTo: loggedInUser?.email)
      .get()
      .then(
          (value) {
        GBookUser gBookUser = GBookUser.fromJson(value.docs.single.data());
        gBookUser.userRef = value.docs.single.reference;
        return gBookUser;
      }
  ).catchError((e) => print(e));


}




