import 'package:permission_handler/permission_handler.dart';

/// Service pour demander et vérifier les permissions de stockage
class PermissionService {
  /// Demande les permissions de stockage
  static Future<bool> requestStoragePermission() async {
    try {
      // Vérifie si les permissions de stockage sont déjà accordées
      if (await Permission.storage.isGranted) {
        print('[Permissions] Permissions déjà accordées.');
        return true; // Retourne `true` si les permissions sont déjà accordées
      }

      // Demande dynamiquement les permissions de stockage
      final status = await Permission.storage.request();
      if (status.isGranted) {
        print('[Permissions] Permissions accordées.');
        return true; // Retourne `true` si les permissions sont accordées
      } else if (status.isDenied) {
        print('[Permissions] Permissions refusées.');
        return false; // Retourne `false` si les permissions sont refusées
      } else if (status.isPermanentlyDenied) {
        print('[Permissions] Permissions refusées de manière permanente.');
        await openAppSettings(); // Ouvre les paramètres de l'application
        return false; // Retourne `false` si les permissions sont refusées de manière permanente
      } else if (status.isRestricted) {
        print('[Permissions] Permissions restreintes par le système.');
        return false; // Retourne `false` si les permissions sont restreintes par le système
      }
    } catch (e) {
      print('[Permissions] Erreur lors de la gestion des permissions : $e');
      return false; // Retourne `false` en cas d'erreur
    }
    return false; // Valeur par défaut pour éviter les erreurs inattendues
  }

  /// Vérifie si les permissions de stockage sont accordées
  static Future<bool> checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        print('[Permissions] Permissions déjà accordées.');
        return true; // Retourne `true` si les permissions sont accordées
      } else {
        print('[Permissions] Permissions non accordées.');
        return false; // Retourne `false` si les permissions ne sont pas accordées
      }
    } catch (e) {
      print('[Permissions] Erreur lors de la vérification des permissions : $e');
      return false; // Retourne `false` en cas d'erreur
    }
  }
}