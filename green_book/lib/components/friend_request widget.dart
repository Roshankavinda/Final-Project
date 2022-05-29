import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:green_book/components/rounded_icon_button.dart';
import 'package:green_book/global/state.dart';


import '../constants.dart';
import '../models/friend.dart';
import '../models/user_detail.dart';

class FriendRequestWidget extends StatelessWidget {
  final Friend friend;


  const FriendRequestWidget({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 5,
        child: Container(
          color: kColorSecondaryLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<UserDetail>(
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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 50,
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
                                  child: Text(friendDetail?.username as String),
                                )
                              ],
                            )
                        ),
                      );

                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 0, top: 8, bottom: 8),
                child: RoundedIconButton(
                    color: kColorSecondary,
                    icon: Icons.check,
                    onClick: () async{
                      DocumentReference ref = await FirebaseFirestore.instance.collection('chats').add({
                        'users': [friend.user, GlobalState.gBookUser?.userRef]
                      });
                      await friend.ref.update({
                        'accepted': true,
                        'chat_ref': ref,
                        'pending': false
                      });
                      await FirebaseFirestore.instance.doc(friend.user.path)
                          .collection('friends')
                          .where('user', isEqualTo: GlobalState.gBookUser?.userRef)
                          .get()
                          .then((snapshot) => snapshot.docs.single.reference
                          .update({
                            'chat_ref': ref,
                            'pending': false
                          }));
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
                child: RoundedIconButton(
                    color: Colors.red,
                    icon: Icons.close,
                    onClick: () async{
                      await friend.ref.delete();
                      await FirebaseFirestore.instance.doc(friend.user.path)
                          .collection('friends')
                          .where('user', isEqualTo: GlobalState.gBookUser?.userRef)
                          .get()
                          .then((snapshot) => snapshot.docs.single.reference.delete());
                    }
                  ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Future<UserDetail> retrieveFriends() async => await FirebaseFirestore.instance.doc(friend.user.path)
      .get()
      .then(
          (value) => UserDetail.fromJson(value.data() as Map<String, dynamic>)
  ).catchError((e) => print(e));
}