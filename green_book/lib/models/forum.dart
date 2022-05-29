import 'package:green_book/models/faculty.dart';
import 'package:green_book/models/forum_question.dart';
import 'package:green_book/models/tag.dart';

class Forum{
  ForumQuestion question;
  Faculty faculty;
  List<Tag> tags;

  Forum({required this.question, required this.faculty, required this.tags});
}