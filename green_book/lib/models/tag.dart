import 'package:cloud_firestore/cloud_firestore.dart';

class Tag{
  String name;
  String description;
  DocumentReference faculty;
  DocumentReference? reference;


  Tag({required this.name, required this.description, required this.faculty});

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
      name: json['name'],
      description: json['description'],
      faculty: json['faculty'],
  );
}