import 'package:cloud_firestore/cloud_firestore.dart';

class ForumQuestion{
  String question;
  DocumentReference user;
  List<DocumentReference> tags;
  DocumentReference faculty;
  String? attachmentPath;
  CollectionReference answers;
  DocumentReference reference;

  ForumQuestion(
      {required this.question, required this.user, required this.tags, required this.faculty,required this.attachmentPath, required this.answers, required this.reference});
}