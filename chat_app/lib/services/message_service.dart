// message_service.dart

class MessageService {
  // Liste pour stocker les messages dans le service
  final List<String> _messages = [];

  // Fonction pour récupérer les messages
  List<String> getMessages() {
    return List.from(_messages);
  }

  // Fonction pour ajouter un message
  void addMessage(String message) {
    if (message.isNotEmpty) {
      _messages.add(message);
    }
  }

  // Fonction pour supprimer un message (par exemple, après une suppression dans l'UI)
  void deleteMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
    }
  }

  // Fonction pour simuler l'envoi de messages (par exemple, à un serveur)
  Future<void> sendMessage(String message) async {
    // Ici, vous pouvez ajouter la logique pour envoyer un message à un serveur ou effectuer une autre action
    await Future.delayed(const Duration(seconds: 1)); // Simuler un délai
    addMessage(message); // Ajouter le message après un délai simulé
  }
}
