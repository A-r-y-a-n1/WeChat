import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/api/api.dart';
import 'package:lets_chat/helper/dialoges.dart';
import 'package:lets_chat/main.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/screens/profile_screen.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains('pause')) {
        APIs.updateActiveStatus(false);
      }
      if (message.toString().contains('resume')) {
        APIs.updateActiveStatus(true);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email,....'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 18, letterSpacing: 0.6),
                    onChanged: (val) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : const Align(
                    alignment: AlignmentDirectional(-1, 0),
                    child: Text(
                      "Let's Chat!!",
                      style: TextStyle(letterSpacing: 1.3),
                    ),
                  ),
            automaticallyImplyLeading: false,
            elevation: 3,
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIs.me,
                                )));
                  },
                  icon: const Icon(Icons.person_sharp)),
              const SizedBox(width: 9)
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog();
              },
              child: const Icon(Icons.add_rounded),
            ),
          ),
          body: AnimatedBackground(
            vsync: this,
            behaviour: RandomParticleBehaviour(
                options: const ParticleOptions(
                    baseColor: Colors.black,
                    spawnMaxSpeed: 40,
                    particleCount: 50,
                    maxOpacity: 0.9,
                    opacityChangeRate: 0.45,
                    spawnMinRadius: 4,
                    spawnMaxRadius: 5,
                    minOpacity: 0.8,
                    spawnMinSpeed: 10)),
            child: StreamBuilder(
              stream: APIs.getMyUsersId(),

              //get id of only known users
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  // return const Center(child: CircularProgressIndicator());

                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                      //get only those user, who's ids are provided
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                          // return const Center(
                          //     child: CircularProgressIndicator());

                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchList.length
                                      : _list.length,
                                  padding:
                                      EdgeInsets.only(top: mq.height * .01),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                        user: _isSearching
                                            ? _searchList[index]
                                            : _list[index]);
                                  });
                            } else {
                              return const Center(
                                child: Text('No Connections Found!',
                                    style: TextStyle(fontSize: 20)),
                              );
                            }
                        }
                      },
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(children: [
                Icon(
                  Icons.person_add,
                  color: Colors.blue,
                  size: 28,
                ),
                Text("Add User")
              ]),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16)),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          dialogs.showSnackbar(context, 'user does not exist');
                        }
                      });
                    }
                  },
                  child: const Text('Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16)),
                )
              ],
            ));
  }
}
