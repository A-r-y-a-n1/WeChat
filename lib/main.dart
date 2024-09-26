import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/screens/splash_screen.dart';

import 'firebase_options.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.white));
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Let\'s Chat!!',
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.black),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarColor: Colors.white),
          centerTitle: true,
          elevation: 2.5,
          titleTextStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
