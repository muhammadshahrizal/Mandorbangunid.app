import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _email = 'halo@mandorbangun.id';
  String _whatsapp = '+62 821-2233-4455';
  String _address = 'Gedung Inovasi Lt. 4\nSCBD Raya, Jakarta Selatan';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchContactData();
  }

  Future<void> fetchContactData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cache_contact');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        if (mounted && data['data'] != null) {
          setState(() {
            _email = data['data']['email'] ?? _email;
            _whatsapp = data['data']['whatsapp'] ?? _whatsapp;
            _address = data['data']['address'] ?? _address;
            _isLoading = false;
          });
        }
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.23/mandorbangun.id/api/contact.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          prefs.setString('cache_contact', response.body);
          if (mounted) {
            setState(() {
              _email = data['data']['email'] ?? _email;
              _whatsapp = data['data']['whatsapp'] ?? _whatsapp;
              _address = data['data']['address'] ?? _address;
              _isLoading = false;
            });
          }
        } else {
          if (mounted && cachedData == null) {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Tidak bisa membuka: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 170),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF222222), Color(0xFF0A0A0A)],
                  ),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Text(
                      'MB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 2,
              ),
              children: [
                TextSpan(
                  text: 'MANDORBANGUN',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'ID',
                  style: TextStyle(color: Color(0xFFD4AF37)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'PROFESSIONAL CONTRACTOR',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 24, bottom: 40),
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFD4AF37),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          _buildSectionTitle(Icons.change_history, 'FONDASI UTAMA KAMI'),
          const SizedBox(height: 16),
          _buildSeparateCard(
            icon: Icons.verified_outlined,
            title: 'INTEGRITAS & KUALITAS',
            desc:
                'Penggunaan material berstandar SNI dengan eksekusi pengerjaan presisi tinggi dan terpercaya.',
          ),
          const SizedBox(height: 16),
          _buildSeparateCard(
            icon: Icons.receipt_long_outlined,
            title: 'TRANSPARANSI RAB',
            desc:
                'Rincian anggaran terbuka sejak awal tanpa adanya biaya siluman atau perubahan sepihak.',
          ),
          const SizedBox(height: 16),
          _buildSeparateCard(
            icon: Icons.shield_outlined,
            title: 'DEDIKASI & GARANSI',
            desc:
                'Pendampingan penuh hingga selesai, dilengkapi garansi pemeliharaan pasca serah terima (B.A.S.T).',
          ),
          const SizedBox(height: 40),
          _buildSectionTitle(Icons.adjust, 'VISI KAMI'),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: const Text(
              ' "Menjadi kontraktor terkemuka yang diakui secara nasional dan internasional, memberikan solusi konstruksi inovatif dan berkualitas tinggi untuk membangun masa depan yang berkelanjutan." ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          _buildSectionTitle(Icons.check_circle_outline, 'MISI KAMI'),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _buildMisiItem(
                  'Menyelesaikan tanggung jawab pekerjaan hingga tuntas dengan standar mutu tinggi.',
                ),
                _buildMisiItem(
                  'Berusaha membangun kepercayaan dan amanah kepada customer dengan memberikan hasil terbaik.',
                ),
                _buildMisiItem(
                  'Melayani customer dengan sepenuh hati dan mewujudkan bangunan impian.',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSectionTitle(Icons.headset_mic_outlined, 'HUBUNGI KAMI'),
          const SizedBox(height: 16),
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                )
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _buildContactRow(Icons.email_outlined, 'EMAIL', _email),
                      _buildDivider(),
                      _buildContactRow(
                        Icons.phone_outlined,
                        'WHATSAPP',
                        _whatsapp,
                      ),
                      _buildDivider(),
                      _buildContactRow(
                        Icons.location_on_outlined,
                        'ALAMAT',
                        _address,
                        isLast: true,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        height: 1,
                        width: double.infinity,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialIcon(
                            FontAwesomeIcons.instagram,
                            'https://instagram.com/mandorbangun.id',
                          ),
                          _buildSocialIcon(
                            FontAwesomeIcons.facebook,
                            'https://facebook.com/mandorbangun.id',
                          ),
                          _buildSocialIcon(
                            FontAwesomeIcons.tiktok,
                            'https://tiktok.com/@mandorbangun.id',
                          ),
                          _buildSocialIcon(
                            FontAwesomeIcons.globe,
                            'https://mandorbangunid.com',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'MANDORBANGUNID.APP V2.0',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF141414),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildSeparateCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisiItem(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, color: Color(0xFFD4AF37), size: 6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.05),
        thickness: 1,
        height: 1,
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey[400], size: 18),
      ),
    );
  }
}
