import 'package:flutter/material.dart';
import 'package:flutter_media_storage/flutter_media_storage.dart'; // Importer la bibliothèque créée
import 'src/services/media_service.dart';  // Importer le service de gestion des médias
import 'src/widgets/media_widget.dart';    // Importer le widget d'affichage des médias

void main() async {
  // Assurez-vous que les widgets Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive et le service de médias
  await MediaService.init();

  // Lancer l'application
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Media Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediaWidget(), // Utilisez le widget que vous avez créé pour afficher les médias
    );
  }
}
