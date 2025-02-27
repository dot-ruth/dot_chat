import 'package:dot_chat/models/chat_message_model.dart';
import 'package:dot_chat/models/chat_session_model.dart';
import 'package:dot_chat/providers/theme_provider.dart';
import 'package:dot_chat/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();

  Hive.registerAdapter(ChatMessageModelAdapter());
  Hive.registerAdapter(ChatSessionModelAdapter());

  await Hive.openBox<ChatSessionModel>('chatBox');

  Gemini.init(
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? ''
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
      ),
  );
}

final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: Colors.white
  );

  final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey,
);
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
     return MaterialApp(
      title: 'Dot',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: HomePage(),
    );
    }
   );
  }
}
