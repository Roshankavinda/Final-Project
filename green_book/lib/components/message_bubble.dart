import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';

class MessageBubble extends StatelessWidget {

  final String text;
  final String time;
  final bool isSender;
  final String? imagePath;

  const MessageBubble({Key? key, required this.text, required this.isSender, required this.time, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:  const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: isSender?CrossAxisAlignment.start:CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12.0
              ),
            ),
            Material(
              borderRadius:isSender? const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0), bottomLeft: Radius.zero, bottomRight: Radius.circular(30.0)):const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0), bottomLeft: Radius.circular(30.0), bottomRight: Radius.zero),
              elevation: 5.0,
              color: isSender? kColorSecondary:kColorPrimary,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.0
                      ),
                    ),
                    if(imagePath != null)
                      FutureBuilder<String>(
                          future: FirebaseStorage.instance.ref(imagePath).getDownloadURL(),
                          builder: (context, snapshot){
                            if(!snapshot.hasData){
                              return SizedBox(
                                height: 150.0,
                                child: Lottie.asset('assets/loading.json'),
                              );
                            }else{
                              return SizedBox(
                                height: 150.0,
                                child: Image.network(snapshot.data as String),
                              );
                            }
                          }),


                  ],
                ),
              ),
            ),
          ],
        )
    );

  }
}