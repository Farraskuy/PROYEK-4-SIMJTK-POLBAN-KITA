class AccessControlService {
  // Struktur Penyimpanan RBAC
  static final Map<String, Map<String, List<String>>> _rolePermissions = {};

  // --- Konstanta Role ---
  static const String roleMahasiswa = 'mahasiswa';
  static const String roleDosen = 'dosen';
  static const String roleTeknisi = 'teknisi';
  static const String roleTu = 'tu';
  static const String roleAdmin = 'admin';

  // --- Konstanta Action Standar ---
  static const String create = 'create';
  static const String read = 'read';
  static const String update = 'update';
  static const String delete = 'delete';

  // --- Konstanta Action Khusus SIMJTK ---
  static const String upvote = 'upvote';       // Untuk Mahasiswa
  static const String downvote = 'downvote';   // Untuk Mahasiswa
  static const String claim = 'claim';         // Teknisi mengambil laporan (menggantikan delegate)
  static const String process = 'process';     // Teknisi mengerjakan/mengisi dokumen wizard
  static const String respond = 'respond';     // Admin menanggapi aspirasi
  static const String export = 'export';       // TU mencetak formulir (PDF)

  // --- Konstanta Action Kepemilikan (Owner) ---
  static const String readOwn = 'read_own';
  static const String updateOwn = 'update_own';
  static const String deleteOwn = 'delete_own';

  /// Inisialisasi Role & Hak Akses berdasarkan Dokumen SIMJTK V3
  static void initSimjtkRoles() {
    _rolePermissions.clear();

    // 1. ROLE: MAHASISWA
    // Bisa baca kalender, buat/edit laporan, buat aspirasi, serta upvote/downvote.
    grantPermissions(role: roleMahasiswa, feature: 'kalender', permissions: [read]);
    grantPermissions(
      role: roleMahasiswa,
      feature: 'laporan', 
      permissions: [create, read, upvote, downvote, readOwn, updateOwn, deleteOwn] // update/delete hanya jika masih 'pending'
    );
    grantPermissions(
      role: roleMahasiswa,
      feature: 'aspirasi', 
      permissions: [create, read, upvote, downvote, readOwn, updateOwn, deleteOwn]
    );

    // 2. ROLE: DOSEN
    // Hak lapor setara mahasiswa, dapat melihat kalender, tanpa fitur aspirasi/voting.
    grantPermissions(role: roleDosen, feature: 'kalender', permissions: [read]);
    grantPermissions(
      role: roleDosen,
      feature: 'laporan', 
      permissions: [create, read, readOwn, updateOwn, deleteOwn]
    );

    // 3. ROLE: ADMIN
    // Mengelola user, moderasi laporan global (paksa selesai/hapus hoaks), dan menanggapi aspirasi.
    grantPermissions(
      role: roleAdmin,
      feature: 'users', 
      permissions: [create, read, update, delete] 
    );
    grantPermissions(
      role: roleAdmin,
      feature: 'laporan', 
      permissions: [read, update, delete] // Moderasi global, fitur delegate dihapus
    );
    grantPermissions(
      role: roleAdmin,
      feature: 'aspirasi', 
      permissions: [read, update, delete, respond] 
    );

    // 4. ROLE: TEKNISI
    // Mengambil laporan mandiri (claim), mengisi dokumen kontrol/analisa/usulan, dan mengisi log harian.
    grantPermissions(
      role: roleTeknisi,
      feature: 'laporan', 
      permissions: [read, claim] 
    );
    grantPermissions(
      role: roleTeknisi,
      feature: 'dokumen_teknisi', 
      permissions: [create, read, update, process] // process: eksekusi step-by-step
    );
    grantPermissions(
      role: roleTeknisi,
      feature: 'log_harian', 
      permissions: [create, read, readOwn, updateOwn, deleteOwn] 
    );

    // 5. ROLE: TU (TATA USAHA)
    // Mencetak laporan, BAP dokumen teknisi, rekap log, dan mengelola agenda kalender.
    grantPermissions(role: roleTu, feature: 'laporan', permissions: [read]);
    grantPermissions(
      role: roleTu,
      feature: 'dokumen_teknisi', 
      permissions: [read, export] 
    );
    grantPermissions(
      role: roleTu,
      feature: 'log_harian', 
      permissions: [read, export] 
    );
    grantPermissions(
      role: roleTu,
      feature: 'kalender', 
      permissions: [create, read, update, delete] 
    );
  }

  /// Mendaftarkan hak akses
  static void grantPermissions({
    required String role,
    required String feature,
    required List<String> permissions,
  }) {
    if (!_rolePermissions.containsKey(role)) {
      _rolePermissions[role] = {};
    }
    _rolePermissions[role]![feature] = permissions;
  }

  /// Mengecek apakah role bisa melakukan suatu aksi
  static bool canPerform(String role, String feature, String action, {bool isOwner = false}) {
    final normalizedRole = normalizeRole(role);
    final featurePermissions = _rolePermissions[normalizedRole]?[feature] ?? [];

    if (featurePermissions.contains(action)) {
      return true;
    }

    if (isOwner) {
      final ownerAction = '${action}_own';
      if (featurePermissions.contains(ownerAction)) {
        return true;
      }
    }

    return false;
  }

  static String normalizeRole(String? role) {
    final normalized = (role ?? '').trim().toLowerCase();

    if (normalized == 'staff') {
      return roleTeknisi;
    }

    return normalized;
  }
}
