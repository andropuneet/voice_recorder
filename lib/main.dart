import 'package:flutter/material.dart';
import 'package:qoohoo_audio_recorder/ui/audio_chat_screen.dart';
import 'package:qoohoo_audio_recorder/utils/color_hex.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(getColorHex("#5fe187")),
        primaryColorDark: Color(getColorHex("#5fe187")),
        backgroundColor: Color(getColorHex("#E2E0DD")),
        accentColor: Colors.indigo,
        fontFamily: "SegoeUI",
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder()
        }),
      ),
      home: AudioChatScreen(title: 'Qoohoo Chat'),
    );
  }
}