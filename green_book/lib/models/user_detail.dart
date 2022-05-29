import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetail{
  String? profilePicImage;
  String? username;
  DocumentReference faculty;
  DocumentReference? ref;
  bool? isFriend;

  UserDetail( {required this.profilePicImage, required this.username, required this.faculty});

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
      profilePicImage: json['profile_pic_img'],
      username: json['username'],
      faculty: json['faculty']
  );

  Map<String, dynamic> toJson() => {
    'profile_pic_img': profilePicImage,
    'username': username
  };

}