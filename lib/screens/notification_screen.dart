import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'login_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // CEK LOGIN
    // ==========================================================

    if (!AuthService.checkLogin()) {
      return const LoginRequiredScreen(
        title: 'Login untuk melihat notifikasi',

        description:
            'Silakan login terlebih dahulu untuk melihat notifikasi dan informasi terbaru dari Mandor Bangun.ID.',
      );
    }

    // ==========================================================
    // SUDAH LOGIN
    // ==========================================================

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
          'NOTIFIKASI',

          style: TextStyle(
            color: Color(0xFFD4AF37),

            fontSize: 20,

            fontWeight: FontWeight.w900,

            fontStyle: FontStyle.italic,
          ),
        ),
      ),

      body: const _NotificationBody(),
    );
  }
}

// ============================================================
// NOTIFICATION BODY
// ============================================================

class _NotificationBody extends StatelessWidget {
  const _NotificationBody();

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // DATA NOTIFIKASI SEMENTARA
    // ==========================================================

    final List<Map<String, dynamic>> notifications = [];

    // ==========================================================
    // BELUM ADA NOTIFIKASI
    // ==========================================================

    if (notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: const Color(0xFF1A1A1A),

                  border: Border.all(
                    color: const Color(0xFFD4AF37),

                    width: 1.5,
                  ),
                ),

                child: const Icon(
                  Icons.notifications_none_rounded,

                  color: Color(0xFFD4AF37),

                  size: 45,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Belum Ada Notifikasi',

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 18,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Notifikasi terbaru dari Mandor Bangun.ID akan muncul di sini.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.grey[500],

                  fontSize: 14,

                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // JIKA ADA NOTIFIKASI
    // ==========================================================

    return ListView.builder(
      padding: const EdgeInsets.all(20),

      itemCount: notifications.length,

      itemBuilder: (context, index) {
        final notification =
            notifications[index];

        return Container(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),

          decoration: BoxDecoration(
            color: const Color(0xFF151515),

            borderRadius:
                BorderRadius.circular(15),
          ),

          child: ListTile(
            leading: const Icon(
              Icons.notifications_rounded,

              color: Color(0xFFD4AF37),
            ),

            title: Text(
              notification['title'] ?? '',

              style: const TextStyle(
                color: Colors.white,

                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Text(
              notification['message'] ?? '',

              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ),
        );
      },
    );
  }
}