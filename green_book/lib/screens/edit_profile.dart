import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/rounded_button.dart';
import 'package:green_book/global/state.dart';
import 'package:green_book/models/g_book_user.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../components/rounded_button_with_icon.dart';
import '../constants.dart';

SnackBar snackBarSuccess = SnackBar(
  backgroundColor: kColorSecondary,
  content: Text('Changes saved successfully', style: kHeadingStyleWhiteSmall.copyWith(fontSize: 15),),
);
SnackBar snackBarFail = SnackBar(
  backgroundColor: Colors.red,
  content: Text('Fields are empty', style: kHeadingStyleWhiteSmall.copyWith(fontSize: 15),),
);

class EditProfile extends StatefulWidget {
  static const String id = 'edit_profile';
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool loading = false;
  bool changes = false;
  PlatformFile? pickedFile;
  File? file;
  String? username;
  GBookUser currentUser = GlobalState.gBookUser as GBookUser;



  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        backgroundColor: kColorBackground,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Edit Profile", style: kHeadingStyleSecondary),
              pickedFile != null? SizedBox(
                height: 200.0,
                child: Image.file(
                  File(pickedFile?.path as String),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ):
              FutureBuilder(
                  future: retrieveProfilePic(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return Container(
                          color: kColorBackground,
                          height: 200,
                          child: Lottie.asset('assets/loading.json')
                      );
                    }else{
                      return Container(
                          color: kColorBackground,
                          height: 200,
                          child: Image.network(snapshot.data as String)
                      );
                    }
                  }
              ),
              RoundedButtonWithIcon(
                  icon: Icons.image,
                  color: kColorPrimary,
                  title: 'Update Profile picture',
                  onClick: pickFile
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) async{
                      username = value;
                    },
                    decoration: kInputDecoration.copyWith(
                        hintText: currentUser.username
                    )
                ),
              ),
              RoundedButton(
                  color: kColorSecondary,
                  title: 'Save Changes',
                  onClick: () async{
                    setState((){
                      loading = true;
                    });

                    if(pickedFile != null){
                      Reference ref = FirebaseStorage.instance.ref('profile_pics/${currentUser.profilePicImage}');
                      await ref.delete();
                      await uploadFile(currentUser.profilePicImage as String);
                      ScaffoldMessenger.of(context).showSnackBar(snackBarSuccess);
                      setState((){
                        changes = true;
                      });

                    }
                    if(username != null && username != currentUser.username){
                      if(username?.length != 0){
                        await currentUser.userRef?.update({
                          'username': username
                        });
                        GlobalState.gBookUser?.username = username;
                        ScaffoldMessenger.of(context).showSnackBar(snackBarSuccess);
                        setState((){
                          changes = true;
                        });
                      }
                    }
                    if(!changes){
                      ScaffoldMessenger.of(context).showSnackBar(snackBarFail);
                    }
                    setState((){
                      loading = false;
                      username = null;
                      pickedFile = null;
                      file = null;
                      changes = false;
                    });
                  })
            ],
          ),
        ),
      ),
    );
  }
  Future<void> pickFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if(result != null){
      setState(() {
        pickedFile = result.files.first;
        file = File(result.files.single.path as String);
      });
    }
  }
  Future<String> retrieveProfilePic() async{
    String picPath = currentUser.profilePicImage as String;
    final ref = FirebaseStorage.instance.ref('profile_pics/$picPath');
    return await ref.getDownloadURL();
  }

  Future<void> uploadFile(String filename)async {
    if(file != null){
      final destination = 'profile_pics/$filename';
      try{
        final ref = FirebaseStorage.instance.ref(destination);
        await ref.putFile(file!);
      }on FirebaseException catch(e){
        if (kDebugMode) {
          print(e);
        }
      }

    }
  }
}
