import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_model.dart';

class MediaService {
  static late Box<MediaModel> mediaBox;

  /// Initialisation de Hive et création des dossiers de stockage
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(MediaModelAdapter());
    mediaBox = await Hive.openBox<MediaModel>('mediaBox');

    // Création des dossiers médias s'ils n'existent pas
    _createMediaDirectories();
  }

  /// Création des dossiers `media/images` et `media/videos`
  static Future<void> _createMediaDirectories() async {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${directory.path}/media');
    final imageDir = Directory('${mediaDir.path}/images');
    final videoDir = Directory('${mediaDir.path}/videos');

    if (!mediaDir.existsSync()) mediaDir.createSync();
    if (!imageDir.existsSync()) imageDir.createSync();
    if (!videoDir.existsSync()) videoDir.createSync();
  }

  /// Télécharge et stocke un média localement
  static Future<String> saveMedia(File file, String type) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/media/$type');

      if (!mediaDir.existsSync()) {
        mediaDir.createSync(recursive: true);
      }

      final fileName = file.path.split('/').last;
      final filePath = '${mediaDir.path}/$fileName';

      file.copySync(filePath);

      final media = MediaModel(url: file.path, localPath: filePath, type: type);
      mediaBox.put(fileName, media);

      return filePath;
    } catch (e) {
      print('Erreur lors de l\'enregistrement du média : $e');
      return '';
    }
  }

  /// Récupère tous les médias stockés
  static List<MediaModel> getAllMedia() {
    return mediaBox.values.toList();
  }
}
