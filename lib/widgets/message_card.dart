import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:lets_chat/api/api.dart';
import 'package:lets_chat/helper/dialoges.dart';
import 'package:lets_chat/helper/my_date_util.dart';

import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.02
                : mq.width * 0.03),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color.fromARGB(255, 64, 164, 246))),
            child: widget.message.type == Type.text
                ? Text(widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.03),
          child: Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.04,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
            const SizedBox(
              width: 2,
            ),
            Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.02
                : mq.width * 0.03),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green)),
            child: widget.message.type == Type.text
                ? Text(widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: mq.height * .05),
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.02, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
              ),
              if (widget.message.type == Type.text)
                _OptionItem(
                    icon: const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        if (mounted) {
                          Navigator.of(context).pop(mounted);

                          dialogs.showSnackbar(context, 'Text Copied!');
                        }
                      });
                    })
              else
                _OptionItem(
                    icon: const Icon(Icons.download,
                        color: Colors.blue, size: 26),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'Let\'s Chat')
                            .then((success) {
                          if (mounted) {
                            Navigator.of(context).pop(mounted);
                            if (success != null && success) {
                              dialogs.showSnackbar(
                                  context, 'Image Successfully Saved');
                            }
                          }
                        });
                      } catch (e) {
                        log("while image saving : $e");
                      }
                    }),
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      if (mounted) {
                        Navigator.of(context).pop(mounted);
                        _showMessageUpdateDialog();
                      }
                    }),
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever_outlined,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        Navigator.of(context).pop(mounted);
                      });
                    }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye,
                      color: Colors.blue, size: 26),
                  name:
                      'Sent At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye,
                      color: Colors.green, size: 26),
                  name: widget.message.read.isEmpty
                      ? 'Read At : Not Seen Yet'
                      : 'Read At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(children: [
                Icon(
                  Icons.message,
                  color: Colors.blue,
                  size: 28,
                ),
                Text(" Update Message")
              ]),
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              actions: [
                MaterialButton(
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                MaterialButton(
                  child: const Text('Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16)),
                  onPressed: () {
                    APIs.updateMessage(widget.message, updatedMsg)
                        .then((value) {
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            bottom: mq.height * .015,
            top: mq.height * .015),
        child: Row(children: [
          icon,
          Flexible(
              child: Text('  $name',
                  style: const TextStyle(
                      letterSpacing: 0.5, color: Colors.black87, fontSize: 15)))
        ]),
      ),
    );
  }
}
