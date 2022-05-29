import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/tag.dart';
class TagWidget extends StatelessWidget {
  const TagWidget({
    Key? key,
    required this.tag,
  }) : super(key: key);

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child:
      Material(
        borderRadius: BorderRadius.circular(30.0),
        color: kColorSecondary,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(tag.name, style: kHeadingStyleWhiteSmall,)),
        ),
      ),
    );
  }
}