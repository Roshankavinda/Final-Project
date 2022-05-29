import 'package:cloud_firestore/cloud_firestore.dart';

class ForumAnswer{
  String answer;
  DocumentReference user;
  String? attachmentPath;
  DocumentReference reference;

  ForumAnswer({required this.answer, required this.user, required this.attachmentPath, required this.reference});
}