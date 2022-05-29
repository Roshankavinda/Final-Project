import 'package:cloud_firestore/cloud_firestore.dart';

class Group{
  DocumentReference ref;
  String name;
  String imagePath;
  List<DocumentReference> users;
  DocumentReference adminRef;

  Group({required this.ref,required this.name, required this.imagePath, required this.users, required this.adminRef});
}