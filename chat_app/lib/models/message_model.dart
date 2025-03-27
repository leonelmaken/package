// models/message_model.dart

import 'package:hive/hive.dart';

part 'message_model.g.dart'; // Généré par build_runner

@HiveType(typeId: 2) // Utilisez un ID unique différent des autres modèles
class MessageModel extends HiveObject {
  @HiveField(0)
  String type; // "text" ou "image"

  @HiveField(1)
  String content; // Contenu du message ou chemin de l'image

  @HiveField(2)
  DateTime timestamp; // Horodatage

  @HiveField(3)
  bool isSentByMe; // Indique si le message est envoyé par l'utilisateur

  MessageModel({
    required this.type,
    required this.content,
    required this.timestamp,
    required this.isSentByMe,
  });
}