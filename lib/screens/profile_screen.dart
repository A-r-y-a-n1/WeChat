import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'auth/login_screen.dart';

import 'package:lets_chat/helper/dialoges.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Profile Screen"),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              dialogs.showProgressBar(context);

              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding progress dialog
                  Navigator.pop(context);

                  //for moving to home screen
                  Navigator.pop(context);

                  //replacing home screen with login screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.login_outlined),
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: mq.width * .2,
                      height: mq.height * .03,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover))
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .15),
                                child: CachedNetworkImage(
                                  height: mq.height * .14,
                                  width: mq.width * .3,
                                  fit: BoxFit.fill,
                                  imageUrl: widget.user.image,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: -22,
                          child: MaterialButton(
                            onPressed: () {
                              _showBottomSheet();
                            },
                            color: Colors.white,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: mq.height * .02,
                    ),
                    Text(
                      widget.user.email,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    SizedBox(
                      height: mq.height * .015,
                    ),
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_2_sharp),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: "e.g. Aryan Rohela",
                          label: const Text("Name")),
                    ),
                    SizedBox(
                      height: mq.height * .015,
                    ),
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: " e.g. Feeling Happy",
                          label: const Text("About")),
                    ),
                    SizedBox(
                      height: mq.height * .02,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * .5, mq.height * .058)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 700),
                          content: const Text(
                            "Profile Updated Successfully",
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.blue.withOpacity(.7),
                          behavior: SnackBarBehavior.floating,
                        ));
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {});
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(
                        "UPDATE",
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          // log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        }
                      },
                      child: Image.asset('images/gallery.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
