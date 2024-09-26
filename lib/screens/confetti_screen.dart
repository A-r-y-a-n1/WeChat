import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lets_chat/main.dart';
import 'package:lets_chat/screens/home_screen.dart';

class ConfettiScreen extends StatefulWidget {
  const ConfettiScreen({super.key});

  @override
  State<ConfettiScreen> createState() => _ConfettiScreenState();
}

class _ConfettiScreenState extends State<ConfettiScreen> {
  late ConfettiController controller;
  @override
  void initState() {
    super.initState();
    controller = ConfettiController(duration: const Duration(seconds: 3));
    controller.play();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: controller,
                blastDirection: pi / 2,
                gravity: 0,
                maxBlastForce: 3,
                minBlastForce: 1,
                emissionFrequency: 0.02,
                numberOfParticles: 10,
              )),
          const SizedBox(
            height: 250,
          ),
          DefaultTextStyle(
            style: const TextStyle(
                color: Colors.black,
                fontFamily: "Comic Neue",
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
                wordSpacing: 1.2),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('Congratulations!!',
                    speed: const Duration(milliseconds: 200)),
                WavyAnimatedText('You Logged In Successfully',
                    speed: const Duration(milliseconds: 230)),
                TypewriterAnimatedText('Press Continue',
                    speed: const Duration(milliseconds: 150)),
              ],
              isRepeatingAnimation: false,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Positioned(
            width: mq.width / 2,
            height: mq.height * .66,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 132, 194, 244)),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                child: const Text(
                  "Continue To App",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                )),
          )
        ],
      ),
    ));
  }
}
