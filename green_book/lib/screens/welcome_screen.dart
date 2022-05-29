import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:green_book/components/forum_question_widget.dart';
import 'package:green_book/components/friend_request%20widget.dart';
import 'package:green_book/components/group_widget.dart';
import 'package:green_book/components/post_widget.dart';
import 'package:green_book/components/rounded_button.dart';
import 'package:green_book/components/tag_widget.dart';
import 'package:green_book/components/user_avatar_with_name_widget.dart';
import 'package:green_book/global/state.dart';
import 'package:green_book/models/forum_question.dart';
import 'package:green_book/models/user_detail.dart';
import 'package:green_book/models/g_book_user.dart';
import 'package:green_book/models/group.dart';
import 'package:green_book/screens/login_screen.dart';
import 'package:green_book/screens/user_profile_screen.dart';
import 'package:green_book/utilities/user_secure_storage.dart';

import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../components/friend_widget.dart';
import '../components/rounded_button_with_icon.dart';
import '../components/rounded_icon_button.dart';
import '../constants.dart';
import '../models/faculty.dart';
import '../models/friend.dart';
import '../models/tag.dart';




CollectionReference friendRef = FirebaseFirestore.instance.doc(GlobalState.gBookUser?.userRef?.path as String).collection('friends');
CollectionReference groupRef = FirebaseFirestore.instance.collection('groups');
late List<UserDetail> users;
List<UserDetail> getSuggestions(String query) {
  return users.where((user) {
    String nameLowerCase = user.username?.toLowerCase() as String;
    String queryLowerCase = query.toLowerCase();
    return nameLowerCase.contains(queryLowerCase);
  }).toList();
}

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

final _fireStore = FirebaseFirestore.instance;
class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    super.initState();
  }
  User? loggedInUser = GlobalState.user;
  GBookUser? currentUser;

  CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');

  static const List<Widget> _forumScreens = <Widget>[
    ForumStream(),
    AddForumQuestion()
  ];

  static final List<Widget> _postScreens = <Widget>[
    Container(
      color: kColorSecondaryLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          PostStream()
        ],
      ),
    ),
    const AddPost()
  ];


  int _selectedIndexPost = 0;
  int _selectedIndexForum = 0;





  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;


    final WelcomeScreenArgs args = ModalRoute.of(context)?.settings.arguments as WelcomeScreenArgs;
    users = args.users;


    String profilePicPath = Provider.of<String>(context);
    if(profilePicPath != "loading"){
      currentUser = GlobalState.gBookUser;
    }



    void _onItemTappedForum(int index) {
      setState(() {
        _selectedIndexForum = index;
      });
      print(index);
    }

    void _onItemTappedPost(int index) {
      setState(() {
        _selectedIndexPost = index;
      });
      print(index);
    }





    return DefaultTabController(
      length: 4,
      child: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kColorSecondary,
            actions:[
              IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white,),
                  onPressed: () async{
                    await _auth.signOut();
                    await UserSecureStorage.deleteAll();
                    Navigator.pushNamed(context, LoginScreen.id);
                  }),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Wall',),
                Tab(icon: Icon(Icons.supervised_user_circle), text: 'Friends',),
                Tab(icon: Icon(Icons.forum), text: 'Forums',),
                Tab(icon: Icon(Icons.group_work), text: 'Groups',)
              ],
            ),
            title: profilePicPath == 'loading' ? const Text(''):InkWell(onTap:(){
              print(profilePicPath);
              Navigator.pushNamed(
                  context, UserProfileScreen.id,
                  arguments: UserProfileScreenArgs(username: currentUser?.username as String, profilePicPath: profilePicPath));
              },
                child: Text(currentUser?.username as String, style: kHeadingStyleWhiteSmall.copyWith(fontSize: 20),)
            ),
            toolbarHeight: 100,
            leadingWidth: 120,
            leading: profilePicPath == 'loading' ?
                Container( child: Lottie.asset('assets/loading.json')) :
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: kColorPrimaryLight,
                foregroundColor: kColorSecondary,
                radius: 75,
                child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(profilePicPath)
                ),
              ),
            ),
          ),
          backgroundColor: kColorBackground,
          body: TabBarView(
            children: [
              Scaffold(
                backgroundColor: kColorSecondaryLight,
                body: _postScreens.elementAt(_selectedIndexPost),
                bottomNavigationBar: BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.list),
                      label: 'Wall',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: 'Add Post',
                    ),
                  ],
                  currentIndex: _selectedIndexPost,
                  onTap: _onItemTappedPost,
                  selectedItemColor: kColorSecondary,
                ),
              ),
              const SingleChildScrollView(child: FriendStream()),
              Scaffold(
                  backgroundColor: kColorSecondaryLight,
                  body: _forumScreens.elementAt(_selectedIndexForum),
                  bottomNavigationBar: BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.list),
                        label: 'Forum',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add),
                        label: 'Add Question',
                      ),
                    ],
                    currentIndex: _selectedIndexForum,
                    onTap: _onItemTappedForum,
                    selectedItemColor: kColorSecondary,
                  ),
              ),
              const GroupStream()
            ],
          )
        ),
      ),
    );
  }
}
class PostStream extends StatelessWidget {
  const PostStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('posts').where('ready', isEqualTo: true).orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot){
          List<PostWidget> postContainers = [];
          if(!snapshot.hasData){
            Container( child: Lottie.asset('assets/loading.json'));
          }else{
            final posts = snapshot.data!.docs;
            for(var post in posts){
              final path = post.reference.path;
              final description = post.get('description');
              final photoPath = post.get('image_path');
              DocumentReference userRef = post.get('user');
              final likeCount = post.get('like_count');
              final likes = post.get('likes');
              final commentCount = post.get('comment_count');
              final postContainer = PostWidget(
                description: description,
                photoPath: photoPath,
                user: userRef,
                likeCount: likeCount,
                documentPath: path,
                likes: likes,
                postReference: post.reference,
                commentCount: commentCount,
              );
              postContainers.add(postContainer);
            }
          }
          return Flexible(
            child: ListView(
              padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0) ,
              children: postContainers,
            ),
          );
        }
    );
  }
}

class FriendStream extends StatelessWidget {
  const FriendStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Search Friends', style: kHeadingStyleSecondary),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: TypeAheadField<UserDetail?>(
                textFieldConfiguration: kTypeAheadConfig,
                suggestionsCallback: getSuggestions,
                itemBuilder: (context, UserDetail? suggestion){
                  final user = suggestion;
                  bool requestSent = false;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(!(user?.isFriend as bool))
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              UserAvatarWithNameWidget(username: user?.username as String, profilePicPath: user?.profilePicImage as String,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RoundedIconButton(
                                  onClick: () async{
                                    await _fireStore.doc(user?.ref?.path as String).collection('friends').add({
                                      'accepted': false,
                                      'user': GlobalState.gBookUser?.userRef,
                                      'pending': true
                                    });

                                    await _fireStore.doc(GlobalState.gBookUser?.userRef?.path as String).collection('friends').add({
                                      'accepted': true,
                                      'user': user?.ref,
                                      'pending': true
                                    });
                                    requestSent = true;
                                  },
                                  color: kColorSecondary,
                                  icon: requestSent ? Icons.check :Icons.person_add,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              UserAvatarWithNameWidget(username: user?.username as String, profilePicPath: user?.profilePicImage as String,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(width: 2.0, color: kColorSecondary),
                                      left: BorderSide(width: 2.0, color: kColorSecondary),
                                      right: BorderSide(width: 2.0, color: kColorSecondary),
                                      bottom: BorderSide(width: 2.0, color: kColorSecondary),
                                    ),
                                    color: Color(0xFFBFBFBF),
                                  ),
                                  width: 50,
                                  height: 30,
                                  child: const Material(
                                    elevation: 5.0,
                                    child: SizedBox(
                                      width: 40,
                                      height: 20,
                                      child: Center(
                                          child: Text(
                                            'Friend',
                                            style: TextStyle(
                                                color: kColorSecondary
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  );
                },
                onSuggestionSelected: (UserDetail? suggestion){},
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Friend Requests', style: kHeadingStyleSecondary),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: friendRef.where('accepted', isEqualTo: false).snapshots(),
            builder: (context, snapshot){
              List<FriendRequestWidget> friendWidgets = [];
              if(!snapshot.hasData){
                const Text('No Friend Requests');
              }else {
                final friends = snapshot.data!.docs;
                for(var friend in friends){
                  final ref = friend.reference;
                  final user = friend.get('user');
                  Friend friendObj = Friend(user: user, ref: ref, chatRef: null);
                  final friendWidget = FriendRequestWidget(friend: friendObj);
                  friendWidgets.add(friendWidget);
                }
              }
              if(friendWidgets.isEmpty){
                return Container(
                  padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0) ,
                  child: const Text('No Friend Requests'),
                );
              }
              return Column(
                children: friendWidgets,
              );
            }
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Friends', style: kHeadingStyleSecondary,),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: friendRef.where('accepted', isEqualTo: true).where('pending', isEqualTo: false).snapshots(),
            builder: (context, snapshot){
              List<FriendWidget> friendWidgets = [];
              if(!snapshot.hasData){
                Container( child: Lottie.asset('assets/loading.json'));
              }else {
                final friends = snapshot.data!.docs;
                for(var friend in friends){
                  final ref = friend.reference;
                  final user = friend.get('user');
                  final DocumentReference chatRef = friend.get('chat_ref');
                  Friend friendObj = Friend(user: user, ref: ref, chatRef: chatRef);
                  final friendWidget = FriendWidget(friend: friendObj);
                  friendWidgets.add(friendWidget);
                }
              }
              if(friendWidgets.isEmpty){
                return Container(
                  padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0) ,
                  child: const Text('No Friends'),
                );
              }
              return Column(
                children: friendWidgets,
              );
            }
        ),
      ],
    );
  }
}

class ForumStream extends StatelessWidget {
  const ForumStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
            stream: _fireStore.collection('forum_questions').orderBy('timestamp').snapshots(),
            builder: (context, snapshot){
              List<ForumQuestionWidget> questionWidgets = [];
              if(!snapshot.hasData){
                return Container(
                    child: Lottie.asset('assets/loading.json')
                );
              }else{
                final questions = snapshot.data?.docs;
                for(var question in questions!){
                  DocumentReference ref = question.reference;
                  String? attachmentPath = question.get('attachment_path');
                  String forumQuestion = question.get('question');
                  DocumentReference faculty = question.get('faculty');
                  DocumentReference user = question.get('user');
                  List<dynamic> tagsObjs = question.get('tags');
                  List<DocumentReference> tags = [];
                  CollectionReference answers = ref.collection('answers');
                  for(var tag in tagsObjs){
                    tags.add(tag);
                  }
                  ForumQuestion questionObj = ForumQuestion(question: forumQuestion, attachmentPath: attachmentPath, faculty: faculty, user: user, reference: ref, answers: answers, tags: tags);
                  ForumQuestionWidget questionWidget = ForumQuestionWidget(question: questionObj);
                  questionWidgets.add(questionWidget);
                }
              }
              if(questionWidgets.isEmpty){
                return const Text('No Questions');
              }
              return Expanded(
                  child: ListView(
                    padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                    children: questionWidgets,
                  )
              );
            }
        ),
      ],
    );
  }
}

class GroupStream extends StatelessWidget {
  const GroupStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children:  [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Groups'),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: groupRef.snapshots(),
            builder: (context, snapshot){
              List<GroupWidget> groupWidgets = [];
              if(!snapshot.hasData){
                const Text('No Friend Requests');
              }else{
                final groups = snapshot.data?.docs;
                for(var group in groups!){
                  String name = group.get('name');
                  String imagePath  = group.get('image_path');
                  List<dynamic> users = group.get('users');
                  List<DocumentReference> userRefs = [];
                  DocumentReference adminref = group.get('admin');
                  for(var user in users){
                    userRefs.add(user);
                  }
                  DocumentReference ref = group.reference;
                  Group gBookGroup = Group(name: name, imagePath: imagePath, users: userRefs, ref: ref, adminRef: adminref);
                  GroupWidget groupWidget = GroupWidget(group: gBookGroup);
                  groupWidgets.add(groupWidget);
                }
              }
              if(groupWidgets.isEmpty){
                return Flexible(
                  child: Container(
                    padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0) ,
                    child: const Text('No Friend Requests'),
                  ),
                );
              }
              return Flexible(
                child: ListView(
                  padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0) ,
                  children: groupWidgets,
                ),
              );
            }
        )
      ],
    );
  }
}

class AddForumQuestion extends StatefulWidget {
  const AddForumQuestion({Key? key}) : super(key: key);

  @override
  State<AddForumQuestion> createState() => _AddForumQuestionState();
}

class _AddForumQuestionState extends State<AddForumQuestion> {

  String? selectedFaculty;
  String question = '';
  late Faculty faculty;
  List<Tag> tagObjects = [];
  List<TagWidget> selectedTags = [];
  TextEditingController questionController = TextEditingController();
  PlatformFile? pickedFile;
  File? file;

  List<Tag> getTagSuggestions(String query) {
    return tagObjects.where((tag) {
      String nameLowerCase = tag.name.toLowerCase();
      String queryLowerCase = query.toLowerCase();
      return nameLowerCase.contains(queryLowerCase);
    }).toList();
  }
  bool loading = false;
  bool questionError = false;
  bool tagError = false;

  @override
  Widget build(BuildContext context) {

    if(selectedFaculty == null) {
      return ModalProgressHUD(
        inAsyncCall: loading,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Select Faculty that you want to direct the question', style: kHeadingStyleSecondary.copyWith(fontSize: 20), textAlign: TextAlign.center,),
            ),
            Expanded(
              child: InkWell(
                onTap: () async{
                  setState(() {
                    loading = true;
                  });

                  faculty = await getFaculty('FOB');
                  tagObjects = (await getTags(faculty))!;

                  setState(() {
                    loading = false;
                    selectedFaculty = 'FOB';
                  });

                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                      elevation: 5,
                      child: SizedBox(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset('images/business.jpg', fit: BoxFit.cover),
                            ClipRRect( // Clip it cleanly.
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  color: Colors.black.withOpacity(0.4),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'FOB',
                                        style: kHeadingStyleWhiteSmall.copyWith(fontSize: 40, fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        'Faculty of Business',
                                        style: kHeadingStyleWhiteSmall.copyWith(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                )
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async{
                  setState(() {
                    loading = true;
                  });
                  faculty = await getFaculty('FOC');
                  tagObjects = (await getTags(faculty))!;
                  setState(() {
                    loading = false;
                    selectedFaculty = 'FOC';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                      elevation: 5,
                      child: SizedBox(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset('images/computing.jpg', fit: BoxFit.cover),
                            ClipRRect( // Clip it cleanly.
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  color: Colors.black.withOpacity(0.4),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'FOC',
                                        style: kHeadingStyleWhiteSmall.copyWith(fontSize: 40, fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        'Faculty of Computing',
                                        style: kHeadingStyleWhiteSmall.copyWith(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                )
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async{
                  setState(() {
                    loading = true;
                  });
                  faculty = await getFaculty('FOE');
                  tagObjects = (await getTags(faculty))!;
                  setState(() {
                    loading = false;
                    selectedFaculty = 'FOE';
                  });
                },
                child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 5,
                    child: SizedBox(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('images/engineering.jpg', fit: BoxFit.cover),
                          ClipRRect( // Clip it cleanly.
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                color: Colors.black.withOpacity(0.4),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'FOE',
                                      style: kHeadingStyleWhiteSmall.copyWith(fontSize: 40, fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      'Faculty of Engineering',
                                      style: kHeadingStyleWhiteSmall.copyWith(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                )
              ),
            ),
          ],
        ),
      );
    }else{
      return ModalProgressHUD(
        inAsyncCall: loading,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Faculty - ', style: kHeadingStyleBlackSmall,),
                          Text('${faculty.name} (${faculty.short})' ,style: kHeadingStyleBlackSmall,),
                        ],
                      ),
                      TypeAheadField(
                        suggestionsCallback: getTagSuggestions,
                        itemBuilder: (context, Tag? suggestion){
                          final tag = suggestion;
                          return ListTile(
                            title: Text(tag?.name as String),
                          );
                        },
                        onSuggestionSelected: (Tag? selected){
                            addDistinct(selected!);
                            print(selectedTags.length);
                        }
                      ),
                      tagError? Text('Must Select at least one tag', style: kHeadingStyleBlackSmall.copyWith(color: Colors.red),): const Text(''),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Tags - ', style: kHeadingStyleBlackSmall,),
                          ),

                          if(selectedTags.isEmpty)
                            const Text('No Tags Selected' ,style: kHeadingStyleBlackSmall,),

                        ],

                      ),
                      if(selectedTags.isNotEmpty)
                        SizedBox(
                          height: 60,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: selectedTags,
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Question - ', style: kHeadingStyleBlackSmall,),
                      ),
                      tagError? Text('Question cannot be empty', style: kHeadingStyleBlackSmall.copyWith(color: Colors.red),): const Text(''),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: questionController,
                              minLines: 1, // any number you need (It works as the rows for the textarea)
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              onChanged: (value){
                                question = value;
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: pickedFile == null ? const Text('No attachments'): Text(pickedFile?.name as String),
                      ),
                      RoundedButtonWithIcon(
                          color: kColorPrimary,
                          title: 'Add Attachment',
                          icon: Icons.attach_file,
                          onClick: pickFile
                      ),
                      RoundedButton(
                          color: kColorSecondary,
                          title: 'Post Question',
                          onClick: ()async{
                            setState(() {
                              loading = true;
                            });
                            if(question.isNotEmpty && tagObjects.isNotEmpty){
                              List<DocumentReference> tagReferences = [];
                              for(TagWidget tag in selectedTags){
                                tagReferences.add(tag.tag.reference as DocumentReference);
                              }
                              if(pickedFile != null){
                                DocumentReference ref = await _fireStore.collection('forum_questions').add({
                                  'attachment_path': null,
                                  'faculty': faculty.ref,
                                  'question': question,
                                  'timestamp': DateTime.now().toIso8601String(),
                                  'user': GlobalState.gBookUser?.userRef,
                                  'tags': tagReferences,
                                  'ready': false
                                });
                                await uploadFile(ref.id);
                                await ref.update({
                                  'attachment_path': ref.id,
                                  'ready': true
                                });
                              }else{
                                await _fireStore.collection('forum_questions').add({
                                  'attachment_path': null,
                                  'faculty': faculty.ref,
                                  'question': question,
                                  'timestamp': DateTime.now().toIso8601String(),
                                  'user': GlobalState.gBookUser?.userRef,
                                  'tags': tagReferences,
                                  'ready': true
                                });
                              }

                            }else{
                              if(question.isEmpty){
                                setState(() {
                                  questionError = true;
                                });
                              }
                              if(tagObjects.isEmpty){
                                setState(() {
                                  tagError = true;
                                });
                              }
                              print('Not valid');
                            }

                          setState(() {
                            pickedFile = null;
                            questionController.clear();
                            question = '';
                            tagObjects.clear();
                            loading = false;
                          });


                      })
                    ],
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  Future<void> pickFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if(result != null){
      setState(() {
        pickedFile = result.files.first;
        file = File(result.files.single.path as String);
      });
    }
  }

  Future<void> uploadFile(String filename)async {
    if(file != null){
      final destination = 'questions/$filename';
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

  bool addDistinct(Tag selected){
    for(TagWidget tag in selectedTags){
      if(tag.tag.name == selected.name){
        return false;
      }
    }
    TagWidget tagWidget = TagWidget(tag: selected);
    setState(() {
      selectedTags.add(tagWidget);
    });
    return true;
  }

  Future<List<Tag>?> getTags(Faculty faculty) async => await faculty.tags?.get()
      .then((snapshot) => snapshot.docs
      .map((document) {
        Tag tag = Tag.fromJson(document.data() as Map<String, dynamic>);
        tag.reference = document.reference;
        return tag;
  }).toList());

  Future<Faculty> getFaculty(String faculty) async => await FirebaseFirestore.instance
      .collection('faculty')
      .where('short',isEqualTo: faculty)
      .get()
      .then((snapshot) {
          Faculty faculty = Faculty.fromJson(snapshot.docs.single.data());
          faculty.ref = snapshot.docs.single.reference;
          faculty.tags = snapshot.docs.single.reference.collection('tags');
          return faculty;
  });

}

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {

  String? description;
  PlatformFile? pickedFile;
  File? file;
  TextEditingController postController = TextEditingController();

  bool loading = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {

      return ModalProgressHUD(
        inAsyncCall: loading,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Add a Post', style: kHeadingStyleSecondary,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: pickedFile == null ?
                      const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'No Image Selected',
                              style: kHeadingStyleBlackSmall,),
                          )
                      ): SizedBox(
                        height: 200.0,
                        child: Image.file(
                          File(pickedFile?.path as String),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RoundedButtonWithIcon(
                          icon: Icons.image,
                          color: kColorPrimary,
                          title: 'Add Image',
                          onClick:  pickFile
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Description - ', style: kHeadingStyleBlackSmall,),
                    ),
                    error ? Text("Description can't be empty", style: kHeadingStyleBlackSmall.copyWith(color: Colors.red),) : const Text(''),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: postController,
                            minLines: 1, // any number you need (It works as the rows for the textarea)
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (value){
                              description = value;
                            },
                          ),
                        ),
                      ),
                    ),
                    RoundedButton(
                        color: kColorSecondary,
                        title: 'Post',
                        onClick: () async{

                          if(description == null){
                            setState(() {
                              error = true;
                            });
                          }else{
                            setState(() {
                              loading = true;
                            });
                            if(pickedFile != null){
                              DocumentReference ref = await _fireStore.collection('posts').add({
                                'description': description,
                                'image_path': null,
                                'like_count': 0,
                                'comment_count':0,
                                'likes': [],
                                'ready': false,
                                'timestamp': DateTime.now().toIso8601String(),
                                'user': GlobalState.gBookUser?.userRef
                              });
                              await uploadFile(ref.id);
                              await ref.update({
                                'image_path': ref.id,
                                'ready': true
                              });
                            }else{
                              await _fireStore.collection('posts').add({
                                'description': description,
                                'image_path': null,
                                'like_count': 0,
                                'comment_count':0,
                                'likes': [],
                                'ready': true,
                                'timestamp': DateTime.now().toIso8601String(),
                                'user': GlobalState.gBookUser?.userRef
                              });
                            }

                            postController.clear();
                            setState(() {
                              loading = false;
                              pickedFile = null;
                            });
                          }
                        }),
                  ],
                ),
              )
            ],
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

  Future<void> uploadFile(String filename)async {
    if(file != null){
      final destination = 'posts/$filename';
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







class WelcomeScreenArgs{
  List<UserDetail> users;
  WelcomeScreenArgs({required this.users});
}

