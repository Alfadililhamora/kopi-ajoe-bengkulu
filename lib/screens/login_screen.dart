import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  final _namaController = TextEditingController();
  final _hpController = TextEditingController();
  final _alamatController = TextEditingController();

  Future<void> _handleSubmit() async {
    final provider = context.read<AppProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    if (_isRegisterMode) {
      if (_namaController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama lengkap wajib diisi')),
        );
        return;
      }
      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password minimal 6 karakter')),
        );
        return;
      }

      final msg = await provider.register(
        nama: _namaController.text,
        email: email,
        password: password,
        noHp: _hpController.text.isEmpty ? '-' : _hpController.text,
        alamat: _alamatController.text.isEmpty ? 'Kota Bengkulu' : _alamatController.text,
      );

      if (!mounted) return;
      if (msg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.orange.shade800),
        );
        if (msg.contains('Akun berhasil dibuat')) {
          setState(() => _isRegisterMode = false);
        }
      }
    } else {
      final error = await provider.login(email, password);
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppProvider>().isLoadingAuth;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.coffee_rounded, size: 64, color: AppTheme.accentTerracotta),
                const SizedBox(height: 12),
                const Text(
                  'KOPI AJOE BENGKULU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Text('Sistem Pemesanan Multi-Gerobak', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 32),
                if (_isRegisterMode) ...[
                  _field(_namaController, 'NAMA LENGKAP', Icons.person),
                  const SizedBox(height: 12),
                  _field(_hpController, 'NOMOR HP', Icons.phone),
                  const SizedBox(height: 12),
                  _field(_alamatController, 'ALAMAT BENGKULU', Icons.location_on),
                  const SizedBox(height: 12),
                ],
                _field(_emailController, 'EMAIL', Icons.email),
                const SizedBox(height: 12),
                _field(_passwordController, 'PASSWORD', Icons.lock, obscure: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B4E8A)),
                    onPressed: isLoading ? null : _handleSubmit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isRegisterMode ? 'DAFTAR AKUN' : 'MASUK'),
                  ),
                ),
                TextButton(
                  onPressed: isLoading ? null : () => setState(() => _isRegisterMode = !_isRegisterMode),
                  child: Text(
                    _isRegisterMode ? 'SUDAH PUNYA AKUN? MASUK' : 'DAFTAR AKUN BARU',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const Divider(color: Colors.white24, height: 32),
                const Text('Akses Cepat Pengujian (Multi-Role):', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      backgroundColor: AppTheme.coffeeBrown,
                      label: const Text('Pelanggan', style: TextStyle(color: Colors.white)),
                      onPressed: isLoading ? null : () => context.read<AppProvider>().loginDemo('pelanggan@kopiajoe.id'),
                    ),
                    ActionChip(
                      backgroundColor: AppTheme.coffeeBrown,
                      label: const Text('Operator Gerobak', style: TextStyle(color: Colors.white)),
                      onPressed: isLoading ? null : () => context.read<AppProvider>().loginDemo('operator1@kopiajoe.id'),
                    ),
                    ActionChip(
                      backgroundColor: AppTheme.coffeeBrown,
                      label: const Text('Admin Pusat', style: TextStyle(color: Colors.white)),
                      onPressed: isLoading ? null : () => context.read<AppProvider>().loginDemo('admin@kopiajoe.id'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.accentTerracotta),
        fillColor: const Color(0xFF2B1414),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}
