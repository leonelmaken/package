import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_gallery_saver/image_gallery_saver.dart'; // Pour ajouter les images à la galerie
import 'package:permission_handler/permission_handler.dart'; // Pour demander les permissions

import '../models/media_model.dart';

class MediaService {
  static late Box<MediaModel> mediaBox;

  /// Initialisation de Hive et création des dossiers de stockage
  static Future<void> init() async {
    try {
      // Vérifier et demander les permissions de stockage
      if (!(await _checkAndRequestPermissions())) {
        print('Permissions non accordées.');
        return;
      }

      // Récupérer le répertoire des documents de l'application (pour Hive)
      final dir = await getApplicationDocumentsDirectory();
      print('Répertoire local de Hive : ${dir.path}');

      // Initialiser Hive dans ce répertoire
      Hive.init(dir.path);

      // Enregistrer l'adaptateur Hive pour MediaModel
      Hive.registerAdapter(MediaModelAdapter());

      // Ouvrir la boîte Hive pour stocker les métadonnées des médias
      mediaBox = await Hive.openBox<MediaModel>('mediaBox');

      // Créer les dossiers publics nécessaires
      await _createPublicMediaDirectories();
    } catch (e) {
      print('Erreur lors de l\'initialisation : $e');
    }
  }

  /// Demande et vérifie les permissions de stockage
  static Future<bool> _checkAndRequestPermissions() async {
    if (await Permission.storage.isGranted) {
      print('[Permissions] Permissions déjà accordées.');
      return true;
    }

    final status = await Permission.storage.request();
    if (status.isGranted) {
      print('[Permissions] Permissions accordées.');
      return true;
    } else if (status.isPermanentlyDenied) {
      print('[Permissions] Permissions refusées de manière permanente.');
      await openAppSettings(); // Ouvre les paramètres de l'application
      return false;
    } else {
      print('[Permissions] Permissions refusées.');
      return false;
    }
  }

  /// Création des dossiers `ChatApp/ChatAppMedia/images` et `ChatApp/ChatAppMedia/videos`
  static Future<void> _createPublicMediaDirectories() async {
    try {
      // Chemin racine pour les médias publics
      final rootDir = Directory('/storage/emulated/0/ChatApp');
      final mediaDir = Directory('${rootDir.path}/ChatAppMedia');
      final imageDir = Directory('${mediaDir.path}/images');
      final videoDir = Directory('${mediaDir.path}/videos');

      // Vérifier et créer le dossier principal `ChatApp`
      if (!rootDir.existsSync()) {
        await rootDir.create(recursive: true);
        print('Création du dossier public : ${rootDir.path}');
      } else {
        print('Dossier public déjà existant : ${rootDir.path}');
      }

      // Vérifier et créer le sous-dossier `ChatAppMedia`
      if (!mediaDir.existsSync()) {
        await mediaDir.create(recursive: true);
        print('Création du dossier public : ${mediaDir.path}');
      } else {
        print('Dossier public déjà existant : ${mediaDir.path}');
      }

      // Vérifier et créer le sous-dossier `images`
      if (!imageDir.existsSync()) {
        await imageDir.create();
        print('Création du dossier public : ${imageDir.path}');
      } else {
        print('Dossier public déjà existant : ${imageDir.path}');
      }

      // Vérifier et créer le sous-dossier `videos`
      if (!videoDir.existsSync()) {
        await videoDir.create();
        print('Création du dossier public : ${videoDir.path}');
      } else {
        print('Dossier public déjà existant : ${videoDir.path}');
      }
    } catch (e) {
      print('Erreur lors de la création des dossiers publics : $e');
    }
  }

  /// Télécharge et stocke un média localement dans le répertoire public
  static Future<String> saveMedia(File file, String type) async {
    try {
      // Récupérer le répertoire externe public
      final mediaDir = Directory('/storage/emulated/0/ChatApp/ChatAppMedia/$type');

      // Créer le dossier s'il n'existe pas
      if (!mediaDir.existsSync()) {
        await mediaDir.create(recursive: true);
        print('Création du dossier public : ${mediaDir.path}');
      } else {
        print('Dossier public déjà existant : ${mediaDir.path}');
      }

      // Copier le fichier dans le dossier approprié
      final fileName = path.basename(file.path);
      final filePath = '${mediaDir.path}/$fileName';
      await file.copy(filePath);

      // Log pour confirmer l'emplacement de l'image/vidéo
      print('$type stocké(e) avec succès dans : $filePath');

      // Ajouter l'image/vidéo à la galerie
      final result = await ImageGallerySaver.saveFile(filePath);
      if (result['isSuccess']) {
        print('$type ajouté(e) à la galerie : $filePath');
      } else {
        print('Échec de l\'ajout de $type à la galerie.');
      }

      // Enregistrer les métadonnées dans Hive
      final media = MediaModel(url: file.path, localPath: filePath, type: type);
      mediaBox.put(fileName, media);

      print('Média sauvegardé dans le répertoire public : $filePath');
      return filePath; // Retourner le chemin local du fichier
    } catch (e) {
      print('Erreur lors de l\'enregistrement du média : $e');
      return '';
    }
  }

  /// Supprime un média du répertoire public et met à jour Hive
  static Future<void> deleteMedia(String fileName) async {
    try {
      // Récupérer les métadonnées du média depuis Hive
      final media = mediaBox.get(fileName);
      if (media == null) {
        print('Média non trouvé dans Hive : $fileName');
        return;
      }

      // Supprimer le fichier du répertoire public
      final file = File(media.localPath);
      if (file.existsSync()) {
        await file.delete();
        print('Média supprimé du répertoire public : ${media.localPath}');
      } else {
        print('Fichier introuvable dans le répertoire public : ${media.localPath}');
      }

      // Supprimer les métadonnées de Hive
      mediaBox.delete(fileName);
      print('Métadonnées supprimées de Hive : $fileName');
    } catch (e) {
      print('Erreur lors de la suppression du média : $e');
    }
  }

  /// Récupère tous les médias stockés
  static List<MediaModel> getAllMedia() {
    return mediaBox.values.toList();
  }
}