import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:green_book/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_book/global/state.dart';
import 'package:green_book/screens/main_loading_screen.dart';
import 'package:green_book/utilities/user_secure_storage.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../components/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {



  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool showSpinner = false;
  bool emailPasswordWrong = false;
  bool rememberMe = false;
  @override
  Widget build(BuildContext context) {

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return kColorPrimary;
      }
      return kColorSecondary;
    }

    return WillPopScope(
      onWillPop: () async{ return false; },
      child: Scaffold(
        backgroundColor: kColorBackground,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  SizedBox(
                    child: Image.asset('images/logo_small.png'),
                    height: 60.0,
                  ),
                  DefaultTextStyle(
                    style: const TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black54
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText("Book"),
                      ],
                      onTap: (){

                      },
                    ),
                  ),
                ],
                ),
                const SizedBox(
                  height: 48.0,
                ),
                emailPasswordWrong ? Text('Email or Password Wrong', style: kHeadingStyleBlackSmall.copyWith(color: Colors.redAccent),):const Text(''),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kInputDecoration.copyWith(
                      hintText: 'Enter your email'
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kInputDecoration.copyWith(
                    hintText: 'Enter your password'
                  )
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Remember Me: ', style: kHeadingStyleBlackSmall,),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: rememberMe,
                      onChanged: (bool? value) {
                          setState(() {
                            rememberMe = value!;
                          });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                RoundedButton(
                    color: kColorSecondary,
                    title: 'Log In',
                    onClick:() async{
                      if(email!= null && password!= null){
                        setState(() {
                          showSpinner = true;
                        });
                        try{
                          await _auth.signInWithEmailAndPassword(email: email as String, password: password as String);
                          if(rememberMe){
                            await UserSecureStorage.setUsername(email as String);
                            await UserSecureStorage.setPassword(password as String);
                          }
                          GlobalState.user = _auth.currentUser as User;
                          Navigator.pushNamed(context, MainLoadingScreen.id);
                          setState(() {
                            showSpinner = false;
                          });
                        }catch(e){
                          print(e);
                          setState((){
                            emailPasswordWrong = true;
                          });
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
