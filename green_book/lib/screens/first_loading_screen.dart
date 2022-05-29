import 'package:flutter/material.dart';
import 'package:green_book/screens/main_loading_screen.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';
import '../utilities/user_secure_storage.dart';
import 'login_screen.dart';

class FirstLoadingScreen extends StatefulWidget {
  static const String id = 'first_loading_screen';
  const FirstLoadingScreen({Key? key}) : super(key: key);

  @override
  State<FirstLoadingScreen> createState() => _FirstLoadingScreenState();
}

class _FirstLoadingScreenState extends State<FirstLoadingScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kColorBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('images/logo_short.png'),
          Container(
            child: Lottie.asset('assets/main_loading.json'),
          ),
        ],

      ),
    );
  }
  Future checkLogin() async{
    String? email = await UserSecureStorage.getUsername();
    String? password = await UserSecureStorage.getPassword();
    print('....................................................................$email.......................................$password');
    if(email != null && password != null){
      Navigator.pushNamed(context, MainLoadingScreen.id);
    }else{
      Navigator.pushNamed(context, LoginScreen.id);
    }
  }


}

