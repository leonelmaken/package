import 'package:flutter/material.dart';
import 'package:flutter_media_storage/flutter_media_storage.dart'; // Importer la bibliothèque créée
import 'src/services/media_service.dart';  // Importer le service de gestion des médias
import 'src/widgets/media_widget.dart';    // Importer le widget d'affichage des médias

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialiser Flutter

  // Initialiser Hive et les dossiers de stockage
  await MediaService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Media Storage',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MediaWidget(), // Afficher le widget principal
    );
  }
}