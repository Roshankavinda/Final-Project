import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/rounded_button_with_icon.dart';
import 'package:green_book/components/rounded_icon_button.dart';
import 'package:green_book/components/user_avatar_with_name_widget.dart';
import 'package:green_book/screens/chat_screen.dart';

import '../constants.dart';
import '../models/friend.dart';
import '../models/user_detail.dart';
import '../screens/profile_screen.dart';

class FriendWidget extends StatelessWidget {
  final Friend friend;


  const FriendWidget({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 5,
        child: Container(
          color: kColorSecondaryLight,
          child: Padding(
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
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UserAvatarWithNameWidget(profilePicPath: profilePicPath, username: friendDetail?.username as String,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedIconButton(
                            color: kColorSecondary,
                            icon: Icons.message,
                            onClick: (){
                              Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArgs(friendRef: friend.ref, userRef: friend.user, friendDetail: friendDetail as UserDetail, chatRef: friend.chatRef as DocumentReference));
                            }),
                      )
                    ],
                  );

                }
              },
            ),
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


