import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:green_book/constants.dart';
import 'package:green_book/screens/profile_screen.dart';

class UserAvatarWithNameWidget extends StatelessWidget {
  const UserAvatarWithNameWidget({
    Key? key,
    required this.profilePicPath,
    required this.username,
  }) : super(key: key);

  final String profilePicPath;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kColorSecondary, width: 2)
        ),
        height: 60,
        child: InkWell(
          onTap: (){
            Navigator.pushNamed(context, ProfileScreen.id, arguments: ProfileScreenArgs(username: username, profilePicPath: profilePicPath));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                  child: Text(username, style: const TextStyle(
                    // color: Colors.white
                  ),),
                )
              ],
            ),
          ),
        )
    );
  }
}