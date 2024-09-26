import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lets_chat/api/api.dart';
import 'package:lets_chat/helper/dialoges.dart';
import 'package:lets_chat/screens/confetti_screen.dart';
import 'package:lets_chat/screens/home_screen.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        if (await APIs.userExists()) {
          if (!context.mounted) return;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ConfettiScreen()));
          });
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 1500),
          content: const Text(
            "Logged in successfully 😃😃",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          backgroundColor:
              const Color.fromARGB(255, 106, 208, 255).withOpacity(.7),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      dialogs.showSnackbar(
          context, 'Something went wrong (Check Internet Connection)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Welcome to Let's Chat!!")),
      body: Stack(
        children: [
          //app logo
          AnimatedPositioned(
              top: _isAnimate ? mq.height * .13 : -mq.height * .13,
              right: mq.width * .25,
              width: mq.width * .5,
              duration: const Duration(milliseconds: 500),
              child: Image.asset('images/chat.png')),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .03,
            // right: mq.width * .15,
            width: mq.width * .95,
            height: mq.height * .06,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade300,
                  shape: const StadiumBorder(),
                  elevation: 1.0),
              onPressed: () {
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                _handleGoogleBtnClick();
              },
              icon: Image.asset('images/google.png', width: mq.width * .1),
              label: RichText(
                text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    children: [
                      TextSpan(text: 'Log in with '),
                      TextSpan(
                          text: 'Google',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ]),
              ),
            ),
          )
        ],
      ),
    );
  }
}
