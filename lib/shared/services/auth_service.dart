import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/log_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthService {
  static const String _usersCollection = 'users';
  static const String _academicLoginUrl = 'https://akademik.polban.ac.id/laman/login';
  static const String _academicSuccessUrl = 'https://akademik.polban.ac.id/Mhs';
  static const String _usernameSelector = '.form-control[name="username"]';
  static const String _passwordSelector = '.form-control[name="password"]';
  static const String _loginButtonSelector =
      '.btn.btn-primary.btn-block.btn-flat[name="submit"]';

  static final AuthService _instance = AuthService._internal();

  @visibleForTesting
  static Future<List<Map<String, dynamic>>> Function(
    String collection,
    SelectorBuilder filter,
  )? fetchUsersOverride;
  
  @visibleForTesting
  static Future<UserModel> Function({
    required String username,
    required String password,
    required Map<String, dynamic> profile,
  })? registerUserOverride;
  
  @visibleForTesting
  static Future<WebViewController> Function({
    required String username,
    required String password,
    void Function(String url)? onUrlChanged,
    void Function(String url)? onSuccess,
    void Function(String errorMessage)? onFailure,
    void Function(String errorMessage)? onHttpError,
    Duration timeout,
  })? loginWebsiteOverride;

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _userKey = 'current_user_data';

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel?> loadSavedSession() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    final storedUser = await _storage.read(key: _userKey);
    if (storedUser == null || storedUser.isEmpty) {
      return null;
    }

    try {
      final decoded = json.decode(storedUser);
      if (decoded is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(decoded);
        return _currentUser;
      }

      if (decoded is Map) {
        _currentUser = UserModel.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
        return _currentUser;
      }
    } catch (e) {
      await LogService.writeLog(
        "AUTH: Gagal memuat sesi user - $e",
        source: "auth_service.dart",
        level: 1,
      );
    }

    return null;
  }

  /// Login menggunakan API (mengakses database Mongo)
  Future<bool> login(String username, String password) async {
    try {
      final userList = await _fetchUsers(where.eq('username', username));

      final userMap = userList.isNotEmpty ? userList.first : null;
      final storedPassword = userMap?['password']?.toString() ?? '';

      if (userMap != null && _verifyPassword(password, storedPassword)) {
        final user = UserModel.fromJson(userMap);

        await _saveUserSession(user);

        final userId = userMap['_id'];
        if (userId is ObjectId) {
          await MonggoDBServices().updateOneByFilter(
            _usersCollection,
            where.eq('_id', userId),
            {'lastLoginAt': DateTime.now().toIso8601String()},
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      await LogService.writeLog(
        "AUTH: Login failed - $e",
        source: "auth_service.dart",
        level: 1,
      );

      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsers(SelectorBuilder filter) async {
    final override = fetchUsersOverride;
    if (override != null) {
      return override(_usersCollection, filter);
    }

    return MonggoDBServices().fetch(_usersCollection, filter);
  }

  /// Logout - menghapus sesi
  Future<void> logout() async {
    _currentUser = null;

    await _storage.delete(key: _userKey);

    await LogService.writeLog(
      "AUTH: User logout, Session cleared",
      source: "auth_service.dart",
    );
  }

  /// Simpan sesi user secara lokal setelah berhasil login/register
  Future<void> _saveUserSession(UserModel user) async {
    _currentUser = user;

    await _storage.write(key: _userKey, value: json.encode(user.toJson()));

    await LogService.writeLog(
      "AUTH: Sesi user disimpan",
      source: "auth_service.dart",
    );
  }

  // Login menggunakan website akademik
  Future<WebViewController> loginWebsite({
    required String username,
    required String password,
    void Function(String url)? onUrlChanged,
    void Function(String url)? onSuccess,
    void Function(String errorMessage)? onFailure,
    void Function(String errorMessage)? onHttpError,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final override = loginWebsiteOverride;
    if (override != null) {
      return override(
        username: username,
        password: password,
        onUrlChanged: onUrlChanged,
        onSuccess: onSuccess,
        onFailure: onFailure,
        onHttpError: onHttpError,
        timeout: timeout,
      );
    }

    late final WebViewController controller;

    bool hasAttemptedLogin = false;
    bool isCompleted = false;

    void completeSuccessOnce(String url) {
      if (isCompleted) return;
      isCompleted = true;
      onSuccess?.call(url);
    }

    void completeFailureOnce(String message) {
      if (isCompleted) return;
      isCompleted = true;
      onFailure?.call(message);
    }

    controller = WebViewController();

    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();
    await controller.clearCache();
    await controller.clearLocalStorage();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnJavaScriptAlertDialog((request) async {})
      ..setOnJavaScriptConfirmDialog((request) async {
        return false;
      })
      ..setOnJavaScriptTextInputDialog((request) async {
        return '';
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (isCompleted) return;

            completeFailureOnce(
              'Gagal memuat halaman akademik. Periksa koneksi internet.',
            );
          },

          onPageFinished: (String url) async {
            if (isCompleted) return;

            final finishedUri = Uri.tryParse(url);
            if (finishedUri == null) return;

            if (_isSameUrl(finishedUri, _academicSuccessUrl)) {
              try {
                final profile = await _extractAcademicProfile(controller);

                final user = await _register(username: username, password: password, profile: profile);

                await _saveUserSession(user);

                await LogService.writeLog(
                  'AUTH: Login website sukses dan akun tersinkron ke MongoDB (${profile['nim'] ?? username})',
                  source: 'auth_service.dart',
                );

                completeSuccessOnce(url);
              } catch (e) {
                await LogService.writeLog(
                  'AUTH: Register user website gagal - $e',
                  source: 'auth_service.dart',
                  level: 1,
                );

                completeFailureOnce(
                  'Login website berhasil, tapi register akun ke database gagal.',
                );
              }
              return;
            }

            if (!_isSameUrl(finishedUri, _academicLoginUrl)) {
              return;
            }

            if (hasAttemptedLogin) {
              return;
            }

            final escapedUsername = _escapeForJsString(username);
            final escapedPassword = _escapeForJsString(password);

            final submitted = await _submitWebsiteLoginForm(
              controller: controller,
              usernameFieldSelector: _usernameSelector,
              passwordFieldSelector: _passwordSelector,
              loginButtonSelector: _loginButtonSelector,
              escapedUsername: escapedUsername,
              escapedPassword: escapedPassword,
            );

            if (!submitted) {
              completeFailureOnce(
                'Form login akademik tidak ditemukan. Kemungkinan halaman berubah.',
              );
              return;
            }

            hasAttemptedLogin = true;
          },

          onUrlChange: (UrlChange change) {
            final currentUrl = change.url;
            if (currentUrl == null) return;

            onUrlChanged?.call(currentUrl);
          },

          onHttpError: (error) {
            if (isCompleted) return;

            completeFailureOnce(
              'Website akademik sedang mengalami gangguan. Coba lagi nanti.',
            );

            onHttpError?.call(
              'Website akademik sedang mengalami gangguan. Coba lagi nanti.',
            );

            LogService.writeLog(
              'HTTP error during login: ${error.response?.statusCode}',
              source: 'auth_service.dart',
              level: 1,
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(_academicLoginUrl));

    Future<void>.delayed(timeout, () {
      if (!isCompleted) {
        completeFailureOnce(
          'Timeout saat proses login website. Periksa koneksi lalu coba lagi.',
        );
      }
    });

    return controller;
  }

  @visibleForTesting
  Future<void> completeAcademicWebsiteLoginForTest({
    required String username,
    required String password,
    required Map<String, dynamic> profile,
    void Function(String url)? onSuccess,
  }) async {
    final user = await _register(
      username: username,
      password: password,
      profile: profile,
    );

    await _saveUserSession(user);
    onSuccess?.call(_academicSuccessUrl);
  }

  bool _verifyPassword(String password, String storedPassword) {
    if (storedPassword.isEmpty) {
      return false;
    }

    try {
      return BCrypt.checkpw(password, storedPassword);
    } catch (_) {
      // Fallback untuk data lama yang mungkin masih plaintext.
      return password == storedPassword;
    }
  }

  bool _isSameUrl(Uri current, String successUrl) {
    final expected = Uri.parse(successUrl);
    return current.host == expected.host &&
        current.path.toLowerCase().startsWith(expected.path.toLowerCase());
  }

  Future<bool> _submitWebsiteLoginForm({
    required WebViewController controller,
    required String usernameFieldSelector,
    required String passwordFieldSelector,
    required String loginButtonSelector,
    required String escapedUsername,
    required String escapedPassword,
  }) async {
    try {
      final result = await controller.runJavaScriptReturningResult('''
        (function() {
          const usernameInput = document.querySelector('$usernameFieldSelector');
          const passwordInput = document.querySelector('$passwordFieldSelector');
          const loginButton = document.querySelector('$loginButtonSelector');

          if (!usernameInput || !passwordInput || !loginButton) {
            return false;
          }

          usernameInput.focus();
          usernameInput.value = '$escapedUsername';
          usernameInput.dispatchEvent(new Event('input', { bubbles: true }));
          usernameInput.dispatchEvent(new Event('change', { bubbles: true }));

          passwordInput.focus();
          passwordInput.value = '$escapedPassword';
          passwordInput.dispatchEvent(new Event('input', { bubbles: true }));
          passwordInput.dispatchEvent(new Event('change', { bubbles: true }));

          loginButton.click();
          return true;
        })();
      ''');

      return _jsResultToBool(result);
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _extractAcademicProfile(
    WebViewController controller,
  ) async {
    final result = await controller.runJavaScriptReturningResult(r'''
      (function() {
        const userHeader = document.querySelector('li.user-header');
        if (!userHeader) {
          return JSON.stringify({});
        }

        const imageEl = userHeader.querySelector('img.img-circle');
        const pEl = userHeader.querySelector('p');
        const smallEls = pEl ? pEl.querySelectorAll('small') : [];

        const nim = smallEls.length > 0
          ? (smallEls[0].textContent || '').trim()
          : '';
        const programStudy = smallEls.length > 1
          ? (smallEls[1].textContent || '').trim()
          : '';

        let fullName = '';
        if (pEl) {
          const cloned = pEl.cloneNode(true);
          cloned.querySelectorAll('small').forEach((el) => el.remove());
          fullName = (cloned.textContent || '').replace(/\s+/g, ' ').trim();
        }

        return JSON.stringify({
          nim: nim,
          name: fullName,
          programStudy: programStudy,
          photoUrl: imageEl ? imageEl.getAttribute('src') || '' : '',
        });
      })();
    ''');

    final jsonString = _normalizeJsStringResult(result);

    if (jsonString == null || jsonString.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final parsed = json.decode(jsonString);

      if (parsed is Map<String, dynamic>) {
        return parsed;
      }

      if (parsed is Map) {
        return parsed.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  Future<UserModel> _register({
    required String username,
    required String password,
    required Map<String, dynamic> profile,
  }) async {
    final override = registerUserOverride;
    if (override != null) {
      return override(
        username: username,
        password: password,
        profile: profile,
      );
    }

    final nimFromWebsite = (profile['nim'] ?? '').toString().trim();
    final usernameToStore = nimFromWebsite.isNotEmpty
        ? nimFromWebsite
        : username;

    final now = DateTime.now().toIso8601String();
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

    final profilePatch = <String, dynamic>{
      'username': usernameToStore,
      'name': (profile['name'] ?? '').toString().trim(),
      'programStudy': (profile['programStudy'] ?? '').toString().trim(),
      'photoUrl': (profile['photoUrl'] ?? '').toString().trim(),
      'password': passwordHash,
      'role': 'mahasiswa',
      'source': 'website',
      'updatedAt': now,
      'lastLoginAt': now,
    };

    final existingByUsername = await MonggoDBServices().fetch(
      _usersCollection,
      where.eq('username', usernameToStore),
    );

    if (existingByUsername.isEmpty) {
      final newUserMap = <String, dynamic>{
        ...profilePatch,
        'createdAt': now,
      };

      await MonggoDBServices().insertData(_usersCollection, newUserMap);
      return UserModel.fromJson(newUserMap);
    }

    final existing = existingByUsername.first;
    final existingId = existing['_id'];

    if (existingId is ObjectId) {
      await MonggoDBServices().updateOneByFilter(
        _usersCollection,
        where.eq('_id', existingId),
        profilePatch,
      );
    }

    return UserModel.fromJson({...existing, ...profilePatch});
  }

  bool _jsResultToBool(Object? result) {
    if (result is bool) return result;
    final normalized = result?.toString().trim().toLowerCase();
    return normalized == 'true';
  }

  String? _normalizeJsStringResult(Object? result) {
    if (result == null) {
      return null;
    }

    var value = result.toString().trim();
    if (value.isEmpty) {
      return value;
    }

    final isWrappedByDoubleQuote = value.startsWith('"') && value.endsWith('"');
    final isWrappedBySingleQuote = value.startsWith("'") && value.endsWith("'");

    if (isWrappedByDoubleQuote || isWrappedBySingleQuote) {
      value = value.substring(1, value.length - 1);
      value = value
          .replaceAll(r'\"', '"')
          .replaceAll(r"\'", "'")
          .replaceAll(r'\\', '\\');
    }

    return value;
  }

  String _escapeForJsString(String value) {
    return value
        .replaceAll(r'\\', r'\\\\')
        .replaceAll("'", r"\\'")
        .replaceAll('\n', r'\\n')
        .replaceAll('\r', r'\\r');
  }
}
