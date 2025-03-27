import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour sélectionner des images
import 'package:path_provider/path_provider.dart'; // Pour gérer les chemins de fichiers
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Pour les animations
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Pour les icônes FontAwesome
import 'package:hive/hive.dart'; // Pour le stockage local Hive
import 'package:path/path.dart' as path; // Pour manipuler les chemins de fichiers
import '../models/message_model.dart'; // Modèle Hive pour les messages
import '../widgets/message_widget.dart'; // Widget personnalisé pour afficher les messages

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Box<MessageModel> messageBox; // Boîte Hive pour stocker les messages
  final TextEditingController _controller = TextEditingController(); // Contrôleur pour le champ de texte
  XFile? _pickedImage; // Stocke l'image sélectionnée
  bool _isInitialized = false; // Indicateur pour vérifier si messageBox est initialisé

  // Initialisation de Hive
  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory(); // Récupère le répertoire des documents de l'application
      Hive.init(dir.path); // Initialise Hive dans ce répertoire
      // Enregistre l'adaptateur Hive pour MessageModel
      Hive.registerAdapter(MessageModelAdapter());
      // Ouvre la boîte Hive pour stocker les messages
      messageBox = await Hive.openBox<MessageModel>('messageBox');
    } catch (e) {
      print("Erreur lors de l'initialisation de Hive: $e");
    }
    setState(() {
      _isInitialized = true; // Marque comme initialisé
    });
  }

  @override
  void initState() {
    super.initState();
    init(); // Appelle la méthode d'initialisation
  }

  // Fonction pour envoyer un message ou une image
  void _sendMessage() async {
    print('[_sendMessage] Début de l\'envoi du message...'); // 🔥 Log
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'application n'est pas encore prête.")),
      );
      return;
    }
    if (_controller.text.isNotEmpty) {
      // Création d'un nouveau message texte
      print('[_sendMessage] Création d\'un message texte...'); // 🔥 Log
      final message = MessageModel(
        type: 'text',
        content: _controller.text,
        timestamp: DateTime.now(),
        isSentByMe: true,
      );
      messageBox.add(message); // Sauvegarde le message dans Hive
      _controller.clear(); // Efface le champ de texte
      setState(() {}); // Met à jour l'interface utilisateur
    }
    if (_pickedImage != null) {
      try {
        // Copie l'image sélectionnée dans le répertoire public
        final mediaDir = Directory('/storage/emulated/0/ChatApp/ChatAppMedia/images');
        if (!mediaDir.existsSync()) {
          await mediaDir.create(recursive: true);
          print('Création du dossier public : ${mediaDir.path}');
        }
        final fileName = path.basename(_pickedImage!.path);
        final savedImage = await File(_pickedImage!.path).copy('${mediaDir.path}/$fileName');
        print('[_sendMessage] Image sauvegardée : ${savedImage.path}'); // 🔥 Log
        // Création d'un nouveau message image
        final message = MessageModel(
          type: 'image',
          content: savedImage.path, // Chemin local de l'image sauvegardée
          timestamp: DateTime.now(),
          isSentByMe: true,
        );
        messageBox.add(message); // Sauvegarde le message dans Hive
        _pickedImage = null; // Réinitialise l'image sélectionnée
        setState(() {}); // Met à jour l'interface utilisateur
      } catch (e) {
        print("Erreur lors du traitement de l'image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors du traitement de l'image")),
        );
      }
    }
  }

  // Fonction pour sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    print('[_pickImage] Tentative de sélection d\'une image...'); // 🔥 Log
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print('[_pickImage] Image sélectionnée : ${pickedFile.path}'); // 🔥 Log
      setState(() {
        _pickedImage = pickedFile; // Stocke l'image sélectionnée
      });
      _sendMessage(); // Envoie immédiatement l'image sélectionnée
    } else {
      print('[_pickImage] Aucune image sélectionnée.'); // 🔥 Log
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucune image sélectionnée")),
      );
    }
  }

  // Supprimer un message (texte, image ou vidéo)
  void _deleteMessage(int index) {
    try {
      final message = messageBox.getAt(index);
      if (message == null) {
        print('Message non trouvé dans Hive : $index');
        return;
      }
      // Supprimer le fichier média s'il existe
      if (message.type == 'image') {
        final file = File(message.content);
        if (file.existsSync()) {
          file.deleteSync();
          print('Média supprimé du répertoire public : ${message.content}');
        }
      }
      // Supprimer les métadonnées de Hive
      messageBox.deleteAt(index);
      setState(() {});
      print('Message supprimé de Hive : $index');
    } catch (e) {
      print('Erreur lors de la suppression du message : $e');
    }
  }

  // Affiche l'image en plein écran avec une animation Hero
  void _showImageInFullScreen(String imagePath, String tag) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullScreenImage(imagePath: imagePath, heroTag: tag),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatApp'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: !_isInitialized
                ? const Center(child: CircularProgressIndicator()) // Affiche un indicateur de chargement
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: messageBox.length,
                      itemBuilder: (context, index) {
                        final message = messageBox.getAt(index)!;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Dismissible(
                                key: Key(message.key.toString()),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (_) {
                                  _deleteMessage(index); // Supprime le message
                                },
                                child: message.type == 'image'
                                    ? GestureDetector(
                                        onTap: () => _showImageInFullScreen(
                                          message.content,
                                          'image_${message.key}',
                                        ),
                                        child: Hero(
                                          tag: 'image_${message.key}',
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 6.0,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12.0),
                                              child: Image.file(
                                                File(message.content),
                                                width: 250,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : MessageWidget(
                                        message: message.content,
                                        timestamp: message.timestamp,
                                        isSentByMe: message.isSentByMe,
                                      ),
                              ),
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
                  icon: const Icon(FontAwesomeIcons.image, color: Colors.teal),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Entrez un message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
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

// Écran pour afficher l'image en plein écran
class FullScreenImage extends StatelessWidget {
  final String imagePath;
  final String heroTag;
  const FullScreenImage({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            left: 10.0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}