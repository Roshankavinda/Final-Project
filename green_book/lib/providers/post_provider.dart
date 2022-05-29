import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_book/models/post.dart';

class PostProvider{
  final _fireStore = FirebaseFirestore.instance;
  
  Stream<List<Post>> getPosts(){
      return _fireStore.collection('posts')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => Post.fromJson(document.data()))
        .toList());
  }
}