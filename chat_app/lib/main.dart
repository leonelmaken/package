import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_storage/flutter_media_storage.dart'; // Assurez-vous d'importer ce package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // 🔥 Important pour les appels asynchrones
  await MediaService.init();  // 🔥 Utilisation correcte de await
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),  // Remplacer le widget MyHomePage par ChatScreen
      debugShowCheckedModeBanner: false,  // Désactiver la bande de débogage
    );
  }
}
