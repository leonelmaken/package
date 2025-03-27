import 'package:chat_app/services/permission_service.dart'; // Service de gestion des permissionss // Service de gestion des médias
import 'package:flutter/material.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter_media_storage/flutter_media_storage.dart'; // Écran principal de l'application

void main() async {
  // 🔥 Initialiser les widgets Flutter avant d'exécuter des opérations asynchrones
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Demander les permissions de stockage
  print('[main] Demande des permissions de stockage...');
  final bool isPermissionGranted = await PermissionService.requestStoragePermission();
  if (!isPermissionGranted) {
    print('[main] Échec de l\'obtention des permissions. Arrêt de l\'initialisation.');
    return; // Arrête l'initialisation si les permissions ne sont pas accordées
  }

  // 🔥 Initialiser MediaService (Hive et les dossiers de stockage)
  print('[main] Initialisation de MediaService...');
  try {
    await MediaService.init(); // Initialise Hive et crée les dossiers publics
  } catch (e) {
    print('[main] Erreur lors de l\'initialisation de MediaService : $e');
    return; // Arrête l'initialisation en cas d'erreur
  }

  // Lancer l'application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App', // Titre de l'application
      theme: ThemeData(
        primarySwatch: Colors.blue, // Thème principal
        visualDensity: VisualDensity.adaptivePlatformDensity, // Optimisation pour différents appareils
      ),
      home: const ChatScreen(), // Écran principal de l'application
      debugShowCheckedModeBanner: false, // Désactiver la bannière de débogage
    );
  }
}