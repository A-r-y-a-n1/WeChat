import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/api/api.dart';
import 'package:lets_chat/screens/auth/login_screen.dart';
import 'package:lets_chat/screens/home_screen.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3550), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));
      if (APIs.auth.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
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
          Positioned(
              top: mq.height * .17,
              left: mq.width * .22,
              width: mq.width * .6,
              child: Image.asset('images/chat.png')),
          Positioned(
            top: mq.height * .08,
            left: mq.width * .80,
            child: const AnimatedEmoji(size: 35, AnimatedEmojis.smile),
          ),
          Positioned(
            top: mq.height * .19,
            left: mq.width * .03,
            child: const AnimatedEmoji(size: 45, AnimatedEmojis.clapLight),
          ),
          Positioned(
            top: mq.height * .26,
            left: mq.width * .83,
            child: const AnimatedEmoji(size: 40, AnimatedEmojis.redHeart),
          ),
          Positioned(
            top: mq.height * .38,
            left: mq.width * .14,
            child: const AnimatedEmoji(size: 39, AnimatedEmojis.wink),
          ),
          Positioned(
            top: mq.height * .54,
            left: mq.width * .20,
            child: const AnimatedEmoji(size: 49, AnimatedEmojis.astonished),
          ),
          Positioned(
            top: mq.height * .04,
            left: mq.width * .27,
            child: const AnimatedEmoji(size: 50, AnimatedEmojis.ghost),
          ),
          Positioned(
            top: mq.height * .48,
            left: mq.width * .55,
            child: const AnimatedEmoji(size: 46, AnimatedEmojis.sunglassesFace),
          ),
          Positioned(
            top: mq.height * .58,
            left: mq.width * .79,
            child: const AnimatedEmoji(size: 38, AnimatedEmojis.crossedFingers),
          ),
          Positioned(
            top: mq.height * .75,
            left: mq.width * .80,
            child: const AnimatedEmoji(size: 39, AnimatedEmojis.birthdayCake),
          ),
          Positioned(
            top: mq.height * .74,
            left: mq.width * .12,
            child: const AnimatedEmoji(size: 36, AnimatedEmojis.foldedHands),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: Align(
              alignment: Alignment.center,
              child: DefaultTextStyle(
                  style: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 1.6,
                      color: Colors.black,
                      fontFamily: 'Agne',
                      fontWeight: FontWeight.bold),
                  child: AnimatedTextKit(
                    animatedTexts: [TypewriterAnimatedText('Make In India')],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
