import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_book/models/g_book_user.dart';

class GlobalState{
  static User? user;
  static GBookUser? gBookUser;
}