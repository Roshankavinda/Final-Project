import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:green_book/components/notification_badge.dart';
import 'package:green_book/models/push_notification.dart';
import 'package:green_book/providers/profile_pic_path_provider.dart';
import 'package:green_book/screens/chat_screen.dart';
import 'package:green_book/screens/first_loading_screen.dart';
import 'package:green_book/screens/forum_screen.dart';
import 'package:green_book/screens/group_screen.dart';
import 'package:green_book/screens/login_screen.dart';
import 'package:green_book/screens/main_loading_screen.dart';
import 'package:green_book/screens/post_screen.dart';
import 'package:green_book/screens/profile_screen.dart';
import 'package:green_book/screens/set_up_screen.dart';
import 'package:green_book/screens/user_profile_screen.dart';
import 'package:green_book/screens/welcome_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';





Future<void> _backgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
  print('A big message just showed up : ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FlashChat());
}

class FlashChat extends StatelessWidget {
  const FlashChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(create: (BuildContext context) =>
            ProfilePicPathProvider().retrieveProfilePic(),
            initialData: 'loading'),
      ],
      child: OverlaySupport(
        child: MaterialApp(
          initialRoute: FirstLoadingScreen.id,
          routes: {
            FirstLoadingScreen.id: (context) => const FirstLoadingScreen(),
            MessageHandler.id: (context) => const MessageHandler(),
            LoginScreen.id: (context) => LoginScreen(),
            MainLoadingScreen.id: (context) => const MainLoadingScreen(),
            ChatScreen.id: (context) => const ChatScreen(),
            WelcomeScreen.id: (context) => const WelcomeScreen(),
            SetUpScreen.id: (context) => const SetUpScreen(),
            GroupScreen.id: (context) => const GroupScreen(),
            ForumScreen.id: (context) => const ForumScreen(),
            PostScreen.id: (context) => const PostScreen(),
            ProfileScreen.id: (context) => const ProfileScreen(),
            UserProfileScreen.id: (context) => const UserProfileScreen()

          },
        ),
      ),
    );
  }
}

class MessageHandler extends StatefulWidget {
  static const String id = 'message_handler';
  const MessageHandler({Key? key}) : super(key: key);

  @override
  State<MessageHandler> createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  late final FirebaseMessaging _messaging;
  late int _totalNotificationCounter;
  PushNotification? _notificationInfo;


  void registerNotification() async{
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('User granted permission');
    }else{
      print('Permission Declined');
    }

    FirebaseMessaging.onMessage.listen((message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body']
      );
      setState((){
        _totalNotificationCounter ++;
        _notificationInfo = notification;
      });

      if(notification != null){
        showSimpleNotification(
          Text(_notificationInfo!.title!),
          leading: NotificationBadge(totalNotificationValue: _totalNotificationCounter),
          subtitle: Text(_notificationInfo!.body!),
          background: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    });
  }

  @override
  void initState() {
    registerNotification();
    _totalNotificationCounter = 0;
    super.initState();
    }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push Notification'),),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Flutter Push Notification', textAlign: TextAlign.center,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: NotificationBadge(totalNotificationValue: _totalNotificationCounter),
            ),
            _notificationInfo != null? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Title: ${_notificationInfo?.dataTitle ?? _notificationInfo?.title}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                Text("Title: ${_notificationInfo?.dataBody ?? _notificationInfo?.body}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
              ],
            ): Container()
          ],
        ),
      ),
    );
  }
}



