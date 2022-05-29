import 'package:cloud_firestore/cloud_firestore.dart';

class Friend{
  DocumentReference user;
  DocumentReference ref;
  DocumentReference? chatRef;

  Friend({required this.user, required this.ref, required this.chatRef});
}