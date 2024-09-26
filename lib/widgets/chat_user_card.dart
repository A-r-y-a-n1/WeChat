import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/api/api.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/models/message.dart';
import 'package:lets_chat/screens/chat_screen.dart';
import 'package:lets_chat/widgets/dialogs/profile_dialog.dart';

import '../main.dart';
import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black45),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }
                return ListTile(
                    // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(user: widget.user));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.width * .1),
                        child: CachedNetworkImage(
                          height: mq.height * .1,
                          width: mq.width * .15,
                          fit: BoxFit.fill,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                        ),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'image'
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1,
                    ),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ? Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: const TextStyle(color: Colors.black54),
                              ));
              })),
    );
  }
}
