import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessControlService {
  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  static List<String> get availableRoles {
    final roles = dotenv.env['APP_ROLES']?.split(',') ?? ['Anggota'];
    return roles
        .map((role) => role.trim())
        .where((role) => role.isNotEmpty)
        .toList();
  }

  static final Map<String, List<String>> _rolePermissions = {
    'Ketua': [actionCreate, actionRead, actionUpdate, actionDelete],
    'Anggota': [actionCreate, actionRead],
    'Asisten': [actionRead, actionUpdate],
  };

  static bool canPerform(String role, String action, {bool isOwner = false}) {
    final permissions = _rolePermissions[role] ?? [];
    final hasBasicPermission = permissions.contains(action);

    if (role == 'Anggota' &&
        (action == actionUpdate || action == actionDelete)) {
      return isOwner;
    }

    return hasBasicPermission;
  }
}
