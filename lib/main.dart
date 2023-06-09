import 'package:flutter/material.dart';
import 'package:untitled/screens/splachScreen/splashScreen.dart';

import 'screens/authScreens/signUpScreen.dart';
import 'screens/servicesScreen/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => SignUpScreen(),
        '/reset-password': (context) => ResetPasswordScreen(),
        '/home': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
