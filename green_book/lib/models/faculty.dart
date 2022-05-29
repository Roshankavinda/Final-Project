import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty{
  String name;
  String description;
  String short;
  CollectionReference? tags;
  DocumentReference? ref;

  Faculty({required this.name, required this.description, required this.short});

  factory Faculty.fromJson(Map<String, dynamic> json) => Faculty(
      name: json['name'],
      description: json['description'],
      short: json['short']
  );
}