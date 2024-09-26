import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/screens/view_profile_screen.dart';
import 'package:lets_chat/widgets/message_card.dart';
import '../api/api.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        // ignore: deprecated_member_use
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle:
                  const SystemUiOverlayStyle(statusBarColor: Colors.white),
              backgroundColor: Colors.white70,
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            // backgroundColor: Colors.black,
            body: Container(
              decoration: const BoxDecoration(
                  gradient: RadialGradient(
                colors: [
                  Color.fromARGB(255, 146, 199, 241),
                  Color.fromARGB(255, 193, 220, 232),
                ],
              )),
              child: Column(children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index]);
                                });
                          } else {
                            return Center(
                                child: DefaultTextStyle(
                                    style: const TextStyle(
                                        fontSize: 22,
                                        letterSpacing: 1.6,
                                        color: Colors.black,
                                        fontFamily: 'Agne',
                                        fontWeight: FontWeight.bold),
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                            'For extra features about text'),
                                        TypewriterAnimatedText(
                                            'Remove keyboard and then'),
                                        TypewriterAnimatedText(
                                            'Long press on it'),
                                        TypewriterAnimatedText('Say Hii 👋👋'),
                                      ],
                                      totalRepeatCount: 1,
                                    )));
                          }
                      }
                    },
                  ),
                ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            return Row(children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    color: Colors.black54,
                  )),
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.width * .1),
                child: CachedNetworkImage(
                  height: mq.height * .05,
                  width: mq.width * .11,
                  fit: BoxFit.cover,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              const SizedBox(
                width: 9,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  )
                ],
              )
            ]);
          }),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Color.fromARGB(255, 15, 161, 246),
                      size: 26,
                    )),
                Expanded(
                    child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: TextField(
                        controller: _textController,
                        scrollController: scrollController,
                        keyboardType: TextInputType.multiline,
                        onTap: () {
                          if (_showEmoji) {
                            setState(() {
                              _showEmoji = !_showEmoji;
                            });
                          }
                        },
                        maxLines: 5,
                        minLines: 1,
                        decoration: const InputDecoration(
                            hintText: "Type your message",
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 15, 161, 246)))),
                  ),
                )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        await APIs.sendChatImage(widget.user, File(image.path));
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color.fromARGB(255, 15, 161, 246),
                      size: 26,
                    )),
                SizedBox(width: mq.width * 0.02)
              ]),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                _textController.text = _textController.text.trim();
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                } else {
                  APIs.sendMessage(
                      widget.user, _textController.text, Type.text);
                }
                _textController.text = '';
              }
            },
            minWidth: 0,
            shape: const CircleBorder(),
            padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
            color: const Color.fromARGB(255, 190, 239, 137),
            child: const Icon(
              Icons.send,
              color: Color.fromARGB(255, 15, 161, 246),
              size: 26,
            ),
          )
        ],
      ),
    );
  }
}
