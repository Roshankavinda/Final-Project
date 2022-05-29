import 'package:cloud_firestore/cloud_firestore.dart';

class GBookUser{
  String? email;
  String? profilePicImage;
  String? username;
  DocumentReference? userRef;
  DocumentReference? faculty;

  GBookUser({required this.email, required this.profilePicImage, required this.username});

  factory GBookUser.fromJson(Map<String, dynamic> json) => GBookUser(
    email: json['email'],
    profilePicImage: json['profile_pic_img'],
    username: json['username']
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'profile_pic_img': profilePicImage,
    'username': username
  };

}