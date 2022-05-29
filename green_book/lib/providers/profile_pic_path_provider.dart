import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:green_book/global/state.dart';

import '../models/g_book_user.dart';


class ProfilePicPathProvider{

  final _fireStore = FirebaseFirestore.instance;

  User? loggedInUser = GlobalState.user;

  Future<GBookUser> retrieveUser() async => await _fireStore
      .collection('users')
      .where('email', isEqualTo: loggedInUser?.email)
      .get()
      .then(
          (value) {
            GBookUser gBookUser = GBookUser.fromJson(value.docs.single.data());
            gBookUser.userRef = value.docs.single.reference;
            gBookUser.faculty = value.docs.single.get('faculty');
            return gBookUser;
          }
  ).catchError((e) => print(e));

  Future<String> retrieveProfilePic() async{
    GBookUser currentUser = await retrieveUser();
    GlobalState.gBookUser = currentUser;
    String picPath = currentUser.profilePicImage as String;
    final ref = FirebaseStorage.instance.ref('profile_pics/$picPath');
    return await ref.getDownloadURL();
  }
}