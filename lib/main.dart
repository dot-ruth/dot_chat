import 'package:dot_chat/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
   await dotenv.load(fileName: ".env");
  Gemini.init(
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? ''
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal.shade50),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
