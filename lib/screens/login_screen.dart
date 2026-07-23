import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginRequiredScreen extends StatelessWidget {
  final String title;
  final String description;

  const LoginRequiredScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // ==================================================
              // ICON LOCK
              // ==================================================

              Container(
                width: 95,
                height: 95,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: const Color(0xFF1A1A1A),

                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 1.5,
                  ),
                ),

                child: const Icon(
                  Icons.lock_outline_rounded,

                  color: Color(0xFFD4AF37),

                  size: 45,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                title,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.white,

                  fontSize: 21,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              Text(
                description,

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.grey[500],

                  fontSize: 14,

                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // LOGIN BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) {
                          return const LoginScreen();
                        },
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),

                    foregroundColor: const Color(0xFF0A0A0A),

                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    'LOGIN',

                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // REGISTER
              // ==================================================

              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fitur pendaftaran akan segera tersedia.',
                      ),
                    ),
                  );
                },

                child: const Text(
                  'Belum punya akun? Daftar sekarang',

                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  // ==========================================================
  // CONTROLLER
  // ==========================================================

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  // ==========================================================
  // PASSWORD VISIBILITY
  // ==========================================================

  bool _obscurePassword = true;

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // PROSES LOGIN
  // ==========================================================

  void _login() {
    final String email =
        _emailController.text.trim();

    final String password =
        _passwordController.text.trim();

    // ========================================================
    // VALIDASI
    // ========================================================

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan masukkan email.',
          ),
        ),
      );

      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan masukkan password.',
          ),
        ),
      );

      return;
    }

    // ========================================================
    // LOGIN
    // ========================================================

    AuthService.login();

    // ========================================================
    // KEMBALI KE HALAMAN SEBELUMNYA
    // ========================================================

    Navigator.pop(context);

    // ========================================================
    // PESAN BERHASIL
    // ========================================================

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Login berhasil!',
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,

            color: Colors.white,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'LOGIN',

          style: TextStyle(
            color: Color(0xFFD4AF37),

            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 30),

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Selamat Datang',

              style: TextStyle(
                color: Colors.white,

                fontSize: 28,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Login untuk mengakses akun Anda.',

              style: TextStyle(
                color: Colors.grey[500],

                fontSize: 14,
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // EMAIL
            // ==================================================

            TextField(
              controller: _emailController,

              keyboardType: TextInputType.emailAddress,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText: 'Email',

                labelStyle: const TextStyle(
                  color: Colors.white54,
                ),

                prefixIcon: const Icon(
                  Icons.email_outlined,

                  color: Color(0xFFD4AF37),
                ),

                filled: true,

                fillColor: const Color(0xFF151515),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // PASSWORD
            // ==================================================

            TextField(
              controller: _passwordController,

              obscureText: _obscurePassword,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText: 'Password',

                labelStyle: const TextStyle(
                  color: Colors.white54,
                ),

                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,

                  color: Color(0xFFD4AF37),
                ),

                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,

                    color: Colors.white54,
                  ),

                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                ),

                filled: true,

                fillColor: const Color(0xFF151515),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // LOGIN BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: _login,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),

                  foregroundColor: const Color(0xFF0A0A0A),

                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  'LOGIN',

                  style: TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // REGISTER
            // ==================================================

            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fitur pendaftaran akan segera tersedia.',
                      ),
                    ),
                  );
                },

                child: const Text(
                  'Belum punya akun? Daftar',

                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}