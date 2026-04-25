import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/fasilitas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/laporan_fasilitas_screen.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
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

      return;
    }

    setState(() {
      _status =
          'Akun belum terdaftar lokal. Sinkronisasi dari website akademik...';
    });

    final controller = await authService.loginWebsite(
      username: nim,
      password: password,

      onSuccess: (url) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _status =
              'Login website berhasil dan akun sudah tersimpan di MongoDB.';
          _currentUrl = url;
          _webViewController = null;
        });
      },

      onFailure: (errorMessage) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _status = errorMessage;
          _webViewController = null;
        });

        // Menampilkan pesan error di bawah layar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      },

      onHttpError: (errorMessage) async {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _status = errorMessage;
          _webViewController = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      },
    );

    if (mounted) {
      setState(() {
        _webViewController = controller;
      });
    }
  }

  void _openMahasiswaAccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
    );
  }

  void _openAdminAccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => AdminFasilitasController(),
          child: const AdminLaporanFasilitasScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Akademik')),
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
                  decoration: const InputDecoration(labelText: 'NIM / NIM'),
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
                ElevatedButton(
                  onPressed: _isLoading ? null : _openMahasiswaAccess,
                  child: const Text('Akses Mahasiswa'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _openAdminAccess,
                  child: const Text('Masuk sebagai Admin'),
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
