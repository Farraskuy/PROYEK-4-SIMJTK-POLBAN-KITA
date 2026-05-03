class AccessControlService {
  // Struktur Penyimpanan RBAC
  static final Map<String, Map<String, List<String>>> _rolePermissions = {};

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
    // 1. ROLE: MAHASISWA
    // Bisa baca kalender, buat/edit laporan, buat aspirasi, serta upvote/downvote.
    grantPermissions(role: 'mahasiswa', feature: 'kalender', permissions: [read]);
    grantPermissions(
      role: 'mahasiswa', 
      feature: 'laporan', 
      permissions: [create, read, upvote, downvote, readOwn, updateOwn, deleteOwn] // update/delete hanya jika masih 'pending'
    );
    grantPermissions(
      role: 'mahasiswa', 
      feature: 'aspirasi', 
      permissions: [create, read, upvote, downvote, readOwn, updateOwn, deleteOwn]
    );

    // 2. ROLE: DOSEN
    // Hak lapor setara mahasiswa, dapat melihat kalender, tanpa fitur aspirasi/voting.
    grantPermissions(role: 'dosen', feature: 'kalender', permissions: [read]);
    grantPermissions(
      role: 'dosen', 
      feature: 'laporan', 
      permissions: [create, read, readOwn, updateOwn, deleteOwn]
    );

    // 3. ROLE: ADMIN
    // Mengelola user, moderasi laporan global (paksa selesai/hapus hoaks), dan menanggapi aspirasi.
    grantPermissions(
      role: 'admin', 
      feature: 'users', 
      permissions: [create, read, update, delete] 
    );
    grantPermissions(
      role: 'admin', 
      feature: 'laporan', 
      permissions: [read, update, delete] // Moderasi global, fitur delegate dihapus
    );
    grantPermissions(
      role: 'admin', 
      feature: 'aspirasi', 
      permissions: [read, update, delete, respond] 
    );

    // 4. ROLE: TEKNISI
    // Mengambil laporan mandiri (claim), mengisi dokumen kontrol/analisa/usulan, dan mengisi log harian.
    grantPermissions(
      role: 'teknisi', 
      feature: 'laporan', 
      permissions: [read, claim] 
    );
    grantPermissions(
      role: 'teknisi', 
      feature: 'dokumen_teknisi', 
      permissions: [create, read, update, process] // process: eksekusi step-by-step
    );
    grantPermissions(
      role: 'teknisi', 
      feature: 'log_harian', 
      permissions: [create, read, readOwn, updateOwn, deleteOwn] 
    );

    // 5. ROLE: TU (TATA USAHA)
    // Mencetak laporan, BAP dokumen teknisi, rekap log, dan mengelola agenda kalender.
    grantPermissions(role: 'tu', feature: 'laporan', permissions: [read]);
    grantPermissions(
      role: 'tu', 
      feature: 'dokumen_teknisi', 
      permissions: [read, export] 
    );
    grantPermissions(
      role: 'tu', 
      feature: 'log_harian', 
      permissions: [read, export] 
    );
    grantPermissions(
      role: 'tu', 
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
    final featurePermissions = _rolePermissions[role]?[feature] ?? [];

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
}