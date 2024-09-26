import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: SizedBox(
        width: mq.width,
        height: mq.height * .5,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                child: CachedNetworkImage(
                  filterQuality: FilterQuality.high,
                  width: mq.height * .3,
                  height: mq.height * .3,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
