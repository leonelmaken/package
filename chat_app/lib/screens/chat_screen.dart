import 'package:flutter/material.dart';
import 'package:flutter_media_storage/flutter_media_storage.dart';  // Importation de flutter_media_storage
import 'package:file_picker/file_picker.dart';  // Importation de FilePicker
import 'dart:io';  // Pour la gestion des fichiers (images locales)
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/message_widget.dart';  // Importation du widget de message
// Importation du service de message

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> messages = [];
  final TextEditingController _controller = TextEditingController();
  String _imageUrl = '';  // Variable pour stocker l'URL de l'image

  // Fonction pour envoyer un message ou une image
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add(_controller.text);  // Ajouter le message texte à la liste
      });
      _controller.clear();  // Effacer le champ de texte
    }

    // Si une image doit être téléchargée
    if (_imageUrl.isNotEmpty) {
      try {
        String localPath = await MediaService.saveMedia(File(_imageUrl), 'image');
        setState(() {
          messages.add(localPath);  // Ajouter l'image aux messages
          _imageUrl = ''; // ✅ Réinitialiser l'URL de l'image après envoi
        });
      } catch (e) {
        print("Erreur lors du téléchargement de l'image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors du téléchargement de l'image")),
        );
      }
    }
  }

  // Fonction pour sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      String filePath = result.files.single.path!;  
      setState(() {
        _imageUrl = filePath;  
      });
      _sendMessage();  
    } else {
      print("Aucune image sélectionnée");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucune image sélectionnée")),
      );
    }
  }

  // Fonction pour afficher l'image en plein écran
  void _showImageInFullScreen(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: messages[index].endsWith('.jpg') || 
                                 messages[index].endsWith('.png') || 
                                 messages[index].endsWith('.jpeg')
                          ? GestureDetector(
                              onTap: () => _showImageInFullScreen(messages[index]),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4.0,
                                      spreadRadius: 2.0,
                                    ),
                                  ],
                                ),
                                child: Image.file(
                                  File(messages[index]),
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : MessageWidget(message: messages[index], index: index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.image, color: Colors.blue),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
