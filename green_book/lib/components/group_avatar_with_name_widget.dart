import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GroupAvatarWithNameWidget extends StatelessWidget {
  const GroupAvatarWithNameWidget({
    Key? key,
    required this.profilePicPath,
    required this.name,
    required this.reference,
  }) : super(key: key);

  final String profilePicPath;
  final String name;
  final DocumentReference reference;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          height: 50,
          child: Row(
            children: [
              FutureBuilder<String>(
                  future: FirebaseStorage.instance.ref('groups/${reference.id}/profile/$profilePicPath').getDownloadURL(),
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
                child: Text(name),
              )
            ],
          )
      ),
    );
  }
}