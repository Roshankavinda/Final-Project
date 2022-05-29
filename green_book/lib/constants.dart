import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

const kColorBackground = Colors.white;
const kColorPrimary = Color(0xff10569a);
const kColorPrimaryLight = Color(0xffa2cafc);
const kColorSecondary = Color(0xff3ab54a);
const kColorSecondaryLight = Color(0xffe2ffce);

const kSendButtonTextStyle = TextStyle(
  color: kColorPrimary,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kColorPrimary, width: 2.0),
  ),
);

const kTypeAheadConfig = TextFieldConfiguration(style: TextStyle(
  fontSize: 20,
  backgroundColor: kColorPrimaryLight,
));

const kHeadingStyleSecondary = TextStyle(
  color: kColorSecondary,
  fontSize: 30,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w100,
);

const kHeadingStyleWhiteSmall = TextStyle(
  color: Colors.white,
  fontSize: 15,
  fontFamily: 'Poppins',
);

const kHeadingStyleBlackSmall = TextStyle(
  color: Colors.black,
  fontSize: 15,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w100
);

const kInputDecoration = InputDecoration(
  hintText: 'Enter something',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: kColorPrimary, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: kColorPrimary, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
);
