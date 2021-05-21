import 'package:flutter/material.dart';
import 'home.dart';
import 'video.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Color(0XFF8FDADD),
            onPrimary: Color(0XFF565B64),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Home.id,
      routes: {
        Home.id: (context) => Home(),
        VideoPage.id: (context) => VideoPage()
      },
    );
  }
}
