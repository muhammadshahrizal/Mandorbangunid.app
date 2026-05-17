import 'package:flutter/material.dart';

// ==========================================
// HALAMAN CHATBOT (ASISTEN MANDOR)
// ==========================================
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text': 'Halo! Saya Asisten MandorBangun. Ada yang bisa saya bantu terkait proyek, harga, atau layanan kami?'
    }
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text.trim();
    setState(() {
      _messages.add({'sender': 'user', 'text': userText});
      _controller.clear();
    });

    // Bikin jeda 1 detik biar berasa mikir
    Future.delayed(const Duration(seconds: 1), () {
      _botReply(userText.toLowerCase());
    });
  }

  // LOGIKA OTAK CHATBOT
  void _botReply(String text) {
    String userText = text.toLowerCase();

    // Default jawaban
    String botResponse = "Maaf, Asisten kurang paham maksudnya. 😅 Silakan hubungi WA kami di +62 815-2318-805 biar tim kami yang langsung bantu ya!";

    // KAMUS OTAK
    Map<List<String>, String> knowledgeBase = {
      ['harga', 'biaya', 'rab', 'pricelist', 'ongkos', 'tarif', 'budget', 'murah']:
          "Untuk estimasi harga bangun rumah, harga pastinya akan disesuaikan dengan desain dan material (RAB). Ada budget khusus yang mau didiskusikan?",
      ['lokasi', 'alamat', 'kantor', 'daerah', 'dimana', 'cabang', 'map']:
          "Kantor MandorBangun.id ada di Ruko Bukit Emerald Jaya, Blok C No. 50, Meteseh, Kec. Tembalang, Semarang. Kami melayani proyek di seluruh area Semarang dan sekitarnya.",
      ['lama', 'waktu', 'durasi', 'kapan', 'selesai', 'berapa bulan']:
          "Durasi pengerjaan tergantung luas bangunan. Rata-rata rumah 1 lantai butuh 3-4 bulan, dan 2 lantai butuh 4-6 bulan. Kami jamin serah terima tepat waktu sesuai kontrak!",
      ['bayar', 'pembayaran', 'cicil', 'kpr', 'dp', 'termin', 'kredit']:
          "Pembayaran bisa di diskusikan dengan tim Mandorbangun melalui wa kami +62 815-2318-805, atau bisa langsung diskusi dengan tim kami di kantor mandorbangun yang bertempat di Ruko Bukit Emerald Jaya, Blok C No. 50, Meteseh, Kec. Tembalang, Semarang.",
      ['material', 'bahan', 'besi', 'semen', 'bata', 'kualitas', 'sni']:
          "Integritas adalah fondasi kami. Kami HANYA menggunakan material berkualitas standar SNI. Anda bisa mengecek transparansi spek material ini langsung di RAB yang kami buatkan.",
      ['garansi', 'rusak', 'bocor', 'pemeliharaan', 'tanggung jawab']:
          "Tenang saja! Setiap proyek yang kami kerjakan dilengkapi dengan Garansi Pemeliharaan pasca serah terima (B.A.S.T). Kalau ada bocor atau retak rambut, tim kami langsung meluncur gratis!",
      ['desain', 'arsitek', 'gambar', '3d', 'denah', 'sketsa']:
          "Punya ide desain sendiri? Atau mau kami buatkan? Kami menyediakan layanan pembuatan desain 3D dan denah arsitektur modern yang fungsional gratis jika Anda deal membangun bersama kami.",
      ['cara', 'prosedur', 'alur', 'mulai', 'survey', 'konsultasi', 'pesan']:
          "Alurnya sangat mudah: 1. Konsultasi (Gratis) -> 2. Survey Lokasi -> 3. Pembuatan Desain & RAB -> 4. Tanda Tangan Kontrak -> 5. Mulai Pembangunan. Kapan tim kami bisa survey ke lokasi Anda?",
      ['galeri', 'contoh', 'proyek', 'portofolio', 'portfolio', 'hasil']:
          "Anda bisa melihat hasil kerja dan desain kami di menu 'GALERI' pada aplikasi ini, atau kunjungi Instagram kami di @mandorbangun.id untuk update proyek terbaru.",
      ['halo', 'hai', 'pagi', 'siang', 'sore', 'malam', 'assalamualaikum', 'bro']:
          "Halo! Selamat datang di MandorBangun.id. Ada yang bisa Asisten bantu untuk wujudkan rumah impian Anda hari ini?",
    };

    for (var entry in knowledgeBase.entries) {
      if (entry.key.any((keyword) => userText.contains(keyword))) {
        botResponse = entry.value;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': botResponse});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Tinggi Pop-up dibikin 85% dari layar HP
      height: MediaQuery.of(context).size.height * 0.85, 
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 1. HEADER POP-UP CHAT (Ada tombol silangnya)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.smart_toy, color: Color(0xFFD4AF37), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Asisten Mandor', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Online', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10)),
                    ],
                  ),
                ),
                // TOMBOL CLOSE (SILANG)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.grey, size: 18),
                  ),
                )
              ],
            ),
          ),
          
          // 2. ISI CHAT (BODY)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUser = _messages[index]['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFD4AF37) : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                      border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      _messages[index]['text']!,
                      style: TextStyle(color: isUser ? const Color(0xFF0A0A0A) : Colors.white, fontSize: 13, fontWeight: isUser ? FontWeight.w600 : FontWeight.normal),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 3. KOLOM KETIK BAWAH
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Color(0xFF0A0A0A), size: 20),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}