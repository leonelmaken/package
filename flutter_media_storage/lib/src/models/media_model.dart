import 'package:hive/hive.dart';

part 'media_model.g.dart';

@HiveType(typeId: 0)
class MediaModel extends HiveObject {
  @HiveField(0)
  String url;

  @HiveField(1)
  String localPath;

  @HiveField(2)
  String type;

  MediaModel({required this.url, required this.localPath, required this.type});
}
