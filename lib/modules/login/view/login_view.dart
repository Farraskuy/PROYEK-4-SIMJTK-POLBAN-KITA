import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_navigation_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  WebViewController? _webViewController;

  bool _isLoading = false;
  String _status = 'Silakan isi NIM dan password.';
  String _currentUrl = '-';

  void _navigateByRole() {
    final role = AuthService().currentUser?.role;
    Get.offAll(() => RoleNavigationService.buildHomeByRole(role));
  }

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    _webViewController = null;
    super.dispose();
  }

  void _loginHandler() async {
    FocusScope.of(context).unfocus();

    final nim = _nimController.text.trim();
    final password = _passwordController.text.trim();

    if (nim.isEmpty || password.isEmpty) {
      setState(() {
        _status = 'NIM dan password wajib diisi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Mengecek akun di database lokal...';
      _currentUrl = '-';
      _webViewController = null;
    });

    final authService = AuthService();
    final localLoginSuccess = await authService.login(nim, password);

    if (!mounted) return;

    if (localLoginSuccess) {
      setState(() {
        _isLoading = false;
        _status = 'Login berhasil melalui MongoDB.';
        _currentUrl = 'mongo://users/$nim';
        _webViewController = null;
      });

      _navigateByRole();
      return;
    }

    setState(() {
      _isLoading = false;
      _status = 'Login gagal. Cek username/password MongoDB Anda.';
      _currentUrl = '-';
      _webViewController = null;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login manual MongoDB gagal.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Manual MongoDB')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nimController,
                  enabled: !_isLoading, // Kunci input saat loading
                  decoration: const InputDecoration(labelText: 'NIM / NIP'),
                ),
                TextField(
                  controller: _passwordController,
                  // obscureText: true,
                  enabled: !_isLoading, // Kunci input saat loading
                  decoration: const InputDecoration(labelText: 'Password'),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _isLoading ? null : _loginHandler,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 12),

                if (_isLoading) const CircularProgressIndicator(),

                const SizedBox(height: 12),

                Text(
                  'Status: $_status',
                  style: TextStyle(
                    color: _status.contains('gagal')
                        ? Colors.red
                        : Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                Text('URL saat ini: $_currentUrl'),
              ],
            ),
          ),

          // Menggunakan Offstage murni agar webview tetap merender dengan ukuran normal namun tak terlihat
          if (_webViewController != null)
            Offstage(
              offstage: true,
              child: WebViewWidget(controller: _webViewController!),
            ),
        ],
      ),
    );
  }
}
