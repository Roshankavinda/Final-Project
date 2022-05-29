import 'package:flutter/material.dart';
import 'package:green_book/components/group_avatar_with_name_widget.dart';
import 'package:green_book/models/group.dart';
import 'package:green_book/screens/group_screen.dart';

import '../constants.dart';

class GroupWidget extends StatelessWidget {
  final Group group;

  const GroupWidget({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, GroupScreen.id, arguments: GroupScreenArgs(group: group));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 5,
          child: Container(
            color: kColorSecondaryLight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GroupAvatarWithNameWidget(profilePicPath: group.imagePath, name: group.name, reference: group.ref,),
            ),
          ),
        ),
      ),
    );
  }
}
