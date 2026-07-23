import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'login_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!AuthService.checkLogin()) {
      return const LoginRequiredScreen(
        title: 'Login untuk membuka profile',
        description:
            'Silakan login terlebih dahulu untuk mengakses profile dan mengelola akun Anda.',
      );
    }

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
          'PROFILE USER',

          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: const Center(
        child: Text(
          'Profile User',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}