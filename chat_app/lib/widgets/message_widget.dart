import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String message;  // Le message à afficher
  final int index;       // L'index du message

  // Constructeur pour initialiser les paramètres
  MessageWidget({required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(  // Icône de l'utilisateur ou une image
        backgroundColor: Colors.blue,
        child: Icon(Icons.account_circle, color: Colors.white),
      ),
      title: Text(
        message,  // Affichage du message
        style: TextStyle(fontSize: 16.0),
      ),
      subtitle: Text('Message #${index + 1}',  // Affichage de l'index du message
          style: TextStyle(color: Colors.grey)),
      trailing: Icon(
        Icons.chat_bubble_outline,  // Icône pour le message
        color: Colors.blue,
      ),
    );
  }
}
