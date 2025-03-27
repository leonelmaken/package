import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../services/media_service.dart';
import '../models/media_model.dart';

class MediaWidget extends StatefulWidget {
  const MediaWidget({super.key});

  @override
  _MediaWidgetState createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  late Future<void> _loadMedia;

  @override
  void initState() {
    super.initState();
    _loadMedia = MediaService.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadMedia,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final mediaList = MediaService.getAllMedia();
        return ListView.builder(
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            final media = mediaList[index];
            return media.type == "image"
                ? Image.file(File(media.localPath))
                : VideoWidget(filePath: media.localPath);
          },
        );
      },
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String filePath;
  const VideoWidget({super.key, required this.filePath});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const CircularProgressIndicator();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
