import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class _FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return _FakePlatformWebViewController(params);
  }
}

class _FakePlatformWebViewController extends PlatformWebViewController {
  _FakePlatformWebViewController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params);
}

void main() {
  const nim = '241511010';
  const password = '*Polban6931#';
  const sessionKey = 'current_user_data';

  final storageData = <String, String>{};
  final authService = AuthService();

  setUpAll(() {
    dotenv.loadFromString(
      envString: 'LOG_LEVEL=0\nLOG_MUTE=',
    );

    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(storageData);
    WebViewPlatform.instance = _FakeWebViewPlatform();

    AuthService.fetchUsersOverride = (collection, filter) async {
      if (collection != 'users') {
        return <Map<String, dynamic>>[];
      }

      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'username': nim,
          'email': '241511010@students.example',
          'name': 'Mahasiswa Polban',
          'role': 'mahasiswa',
          'isActive': true,
          'programStudy': 'D4 Teknik Informatika',
          'photoUrl': '',
          'source': 'test',
          'password': hashedPassword,
        },
      ];
    };

    AuthService.registerUserOverride = ({
      required String username,
      required String password,
      required Map<String, dynamic> profile,
    }) async {
      return UserModel.fromJson(<String, dynamic>{
        'id': 'website-test-user',
        'username': profile['nim'] ?? username,
        'email': '241511010@students.example',
        'name': profile['name'] ?? 'Mahasiswa Polban',
        'role': 'mahasiswa',
        'isActive': true,
        'programStudy': profile['programStudy'] ?? 'D4 Teknik Informatika',
        'photoUrl': profile['photoUrl'] ?? '',
        'source': 'website',
      });
    };

    AuthService.loginWebsiteOverride = ({
      required String username,
      required String password,
      void Function(String url)? onUrlChanged,
      void Function(String url)? onSuccess,
      void Function(String errorMessage)? onFailure,
      void Function(String errorMessage)? onHttpError,
      Duration timeout = const Duration(seconds: 25),
    }) async {
      await authService.completeAcademicWebsiteLoginForTest(
        username: username,
        password: password,
        profile: <String, dynamic>{
          'nim': nim,
          'name': 'Mahasiswa Polban',
          'programStudy': 'D4 Teknik Informatika',
          'photoUrl': 'https://example.test/photo.png',
        },
        onSuccess: onSuccess,
      );

      return WebViewController();
    };
  });

  setUp(() async {
    storageData.clear();
    await authService.logout();
  });

  tearDownAll(() async {
    AuthService.fetchUsersOverride = null;
    AuthService.registerUserOverride = null;
    AuthService.loginWebsiteOverride = null;
    await authService.logout();
  });

  test('login dengan NIM dan password valid', () async {
    final success = await authService.login(nim, password);

    expect(success, isTrue);
    expect(authService.currentUser, isNotNull);
    expect(authService.currentUser!.username, equals(nim));
    expect(storageData[sessionKey], isNotNull);
  });

  test('logout menghapus session auth', () async {
    final success = await authService.login(nim, password);

    expect(success, isTrue);
    expect(authService.currentUser, isNotNull);

    await authService.logout();

    expect(authService.currentUser, isNull);
    expect(storageData.containsKey(sessionKey), isFalse);
  });

  test('login dengan website akademik berhasil', () async {
    String? successUrl;

    final controller = await authService.loginWebsite(
      username: nim,
      password: password,
      onSuccess: (url) {
        successUrl = url;
      },
    );

    expect(controller, isNotNull);
    expect(successUrl, isNotNull);
    expect(successUrl, contains('https://akademik.polban.ac.id/Mhs'));
    expect(authService.currentUser, isNotNull);
    expect(authService.currentUser!.username, equals(nim));
    expect(storageData[sessionKey], isNotNull);
  });
}