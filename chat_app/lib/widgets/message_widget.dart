// message_widget.dart

import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String message; // Le contenu du message
  final DateTime? timestamp; // L'heure du message (optionnel)
  final bool isSentByMe; // Indique si le message est envoyé par l'utilisateur

  const MessageWidget({
    super.key,
    required this.message,
    this.timestamp,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7, // Limiter la largeur
        ),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blue[200] : Colors.grey[300], // Couleur différente
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isSentByMe ? 12.0 : 0.0),
            topRight: Radius.circular(isSentByMe ? 0.0 : 12.0),
            bottomLeft: const Radius.circular(12.0),
            bottomRight: const Radius.circular(12.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 16.0,
                color: isSentByMe ? Colors.black : Colors.black87,
              ),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: 4.0), // Espacement entre le texte et l'horodatage
              Text(
                '${timestamp!.hour}:${timestamp!.minute}', // Format HH:mm
                style: TextStyle(
                  fontSize: 12.0,
                  color: isSentByMe ? Colors.black54 : Colors.black45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}