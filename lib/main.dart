import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart'; // Wajib buat tombol sosmed mbutt!
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:ui'; // Wajib buat efek blur/kaca transparan
import 'chatbot_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MandorBangunApp());
}

// Menghilangkan efek scroll "memantul" biar lebih clean
class NoBouncScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

// ==========================================
// HELPER FUNCTION UNTUK IMAGE URL (Optimized)
// ==========================================
String getOptimizedImageUrl(String imagePath, {String size = 'medium'}) {
  if (imagePath.isEmpty) return '';

  int width = 800;
  if (size == 'thumb') width = 300;
  if (size == 'large') width = 1200;

  if (imagePath.startsWith('http')) {
    // Kalau sudah full URL, gunakan langsung
    return imagePath;
  }

  // Untuk path lokal, gunakan optimize-image.php
  return 'http://192.168.1.15/mandorbangun.id/api/optimize-image.php?path=$imagePath&width=$width';
}

// ==========================================
// WIDGET HELPER: SAFE IMAGE LOADER (Optimasi RAM 🔥)
// ==========================================
Widget _buildSafeNetworkImage(
  String imageUrl, {
  BoxFit fit = BoxFit.cover,
  int? cacheWidth, // <--- TAMBAHIN JURUS INI
}) {
  if (imageUrl.isEmpty) {
    return Container(
      color: const Color(0xFF151515),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: fit,
    memCacheWidth: cacheWidth, // <--- BIAR RAM HP GAK NGEDEN
    fadeInDuration: const Duration(milliseconds: 300),
    fadeOutDuration: const Duration(milliseconds: 300),
    placeholder: (context, url) => Container(
      color: const Color(0xFF151515),
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            strokeWidth: 2,
          ),
        ),
      ),
    ),
    errorWidget: (context, url, error) {
      debugPrint('Image load error: $url - $error');
      return Container(
        color: const Color(0xFF151515),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    },
    httpHeaders: const {
      'Connection': 'keep-alive',
      'Cache-Control': 'max-age=2592000',
    },
  );
}

class MandorBangunApp extends StatelessWidget {
  const MandorBangunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MandorBangun',
      scrollBehavior: NoBouncScrollBehavior(),
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
          surface: const Color(0xFF0a0a0a),
        ),
        scaffoldBackgroundColor: const Color(0xFF0a0a0a),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 1. SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                strokeWidth: 3,
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.5, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Image.asset(
                'assets/logo.png', 
                width: 80,
                height: 80,
                errorBuilder: (c, e, s) => const Icon(Icons.construction, color: Color(0xFFD4AF37), size: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET HELPER: ANIMASI PINDAH TAB (FADE, SCALE & SLIDE) 🔥
// ==========================================
class AnimatedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const AnimatedIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _previousIndex; // Nyimpen info tab sebelumnya biar tau arah geser

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.index;
    // Bikin durasi lebih smooth, nggak kekencengan nggak kelamaan
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350)); 
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kalau index tab berubah, kita restart animasinya dari awal (0.0)
    if (widget.index != oldWidget.index) {
      _previousIndex = oldWidget.index;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nentuin arah geser: Kalau pindah ke tab kanan geser dari kiri, dan sebaliknya
    final isMovingRight = widget.index > _previousIndex;
    final beginOffset = isMovingRight ? const Offset(0.05, 0.0) : const Offset(-0.05, 0.0);

    return FadeTransition(
      // Efek Pudar: Dimulai dari agak terang (0.2) ke full (1.0) biar nggak nge-blank item
      opacity: Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        // Efek Geser Tipis: Nyesuain arah lu mencet tab
        position: Tween<Offset>(
          begin: beginOffset, 
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
        
        child: ScaleTransition(
          // Efek Zoom Tipis: Dari 98% (agak kecil) nge-zoom ke 100% (normal)
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          ),
          child: IndexedStack(
            index: widget.index,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. MAIN SCREEN
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      extendBody: true, 
      
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.4),
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: Colors.white.withOpacity(0.1), height: 1),
              ),
              title: Row(
                children: [
                  Image.asset(
                    'assets/logo-mandorbangun.png', 
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        // JURUS POP-UP CHATBOT BAWAH MBUTT!
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Wajib true biar pop-up bisa tinggi
                          backgroundColor: Colors.transparent, // Biar background-nya transparan & bisa melengkung
                          builder: (context) {
                            return Padding(
                              // Ini jurus rahasia biar pop-up naik pas keyboard HP muncul
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: const ChatbotScreen(),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.4), blurRadius: 5, offset: const Offset(0, 0))],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline, color: Color(0xFF0a0a0a), size: 20),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: PingDot(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // PAKE INDEXEDSTACK BIAR HALAMAN DISIMPEN DI MEMORI (PINDAH TAB 0 DETIK!)
      body: AnimatedIndexedStack( // <--- Tinggal tambahin kata "Animated" di depannya
        index: _selectedIndex,
        children: [
          HomeScreen(
            onNavigateToGallery: () => setState(() => _selectedIndex = 1),
          ),
          GalleryScreen(
            onBack: () => setState(() => _selectedIndex = 0)
          ),
          const ProfileScreen(),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          height: 65, // Tinggi fix biar rapi
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A), // Warna solid hitam pekat, no muddy color!
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, 'HOME'),
              _buildNavItem(1, Icons.layers_outlined, 'GALERI'),
              _buildNavItem(2, Icons.group_outlined, 'PROFIL'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 72,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? const Color(0xFFD4AF37) : Colors.white70),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ==========================================
// 3. WIDGET ANIMASI PING (NOTIF)
// ==========================================
class PingDot extends StatefulWidget {
  const PingDot({super.key});

  @override
  State<PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<PingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 1.0 - _controller.value,
              child: Transform.scale(
                scale: 1.0 + (_controller.value * 1.5),
                child: Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
              ),
            ),
            Container(
              width: 12, height: 12, 
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0a0a0a), border: Border.all(color: Colors.white, width: 2))
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// 4. HALAMAN HOME
// ==========================================
class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGallery;

  const HomeScreen({super.key, this.onNavigateToGallery});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _services = [];
  bool _isLoading = true;

  List<dynamic> _projects = [];
  bool _isLoadingProjects = true;

  int? _expandedWorkflowIndex;

  final List<Map<String, dynamic>> _alurKerja = [
    {'icon': Icons.chat_outlined, 'title': 'KONSULTASI', 'desc': 'Kami melakukan konsultasi bersama calon klien untuk mengetahui apa saja yang dibutuhkan.'},
    {'icon': Icons.search, 'title': 'SURVEY', 'desc': 'Melakukan peninjauan langsung ke lokasi proyek untuk mengukur dan menganalisa kondisi lapangan.'},
    {'icon': Icons.architecture, 'title': 'PERENCANAAN', 'desc': 'Membuat desain arsitektur, gambar kerja, dan menyusun Rencana Anggaran Biaya (RAB).'},
    {'icon': Icons.handshake_outlined, 'title': 'AKAD PELAKSANAAN', 'desc': 'Penandatanganan kontrak kerja kesepakatan antara tim Mandorbangun.id dengan klien.'},
    {'icon': Icons.construction, 'title': 'PELAKSANAAN', 'desc': 'Proses pembangunan atau renovasi properti sesuai dengan perencanaan dan jadwal yang disepakati.'},
    {'icon': Icons.fact_check_outlined, 'title': 'SURVEY PRA PELAKSANA', 'desc': 'Pengecekan ulang kesiapan lapangan sebelum tahap finishing atau tahap krusial lainnya.'},
    {'icon': Icons.checklist, 'title': 'CEKLIST B.A.S.T', 'desc': 'Pemeriksaan detail seluruh pekerjaan bersama klien untuk memastikan kualitas sesuai standar.'},
    {'icon': Icons.task_alt, 'title': 'B.A.S.T', 'desc': 'Berita Acara Serah Terima: Penyerahan kunci dan dokumen resmi sebagai tanda proyek selesai 100%.'},
  ];
  
  @override
  void initState() {
    super.initState();
    fetchServices();
    fetchProjects();
  }

  Future<void> fetchServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cache_services');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        // FIX ERROR NULL: Tambahin ?? [] biar aman
        if (mounted) setState(() { _services = data['data'] ?? []; _isLoading = false; });
      }

      final response = await http.get(Uri.parse('http://192.168.1.15/mandorbangun.id/api/services.php'))
      .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          prefs.setString('cache_services', response.body); 
          if (mounted) setState(() { _services = data['data'] ?? []; _isLoading = false; });
          
        }
        
      }
    } catch (e) {
      print("🚨 ERROR NARIK SERVICES: $e");
      if (mounted && _services.isEmpty) setState(() => _isLoading = false);
    }
  }

  Future<void> fetchProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cache_projects');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        // FIX ERROR NULL: Tambahin ?? [] 
        if (mounted) setState(() { _projects = data['data'] ?? []; _isLoadingProjects = false; });
      }

      final response = await http.get(Uri.parse('http://192.168.1.15/mandorbangun.id/api/portfolio.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          prefs.setString('cache_projects', response.body);
          if (mounted) setState(() { _projects = data['data'] ?? []; _isLoadingProjects = false; });
        } else {
          if (mounted && _projects.isEmpty) setState(() => _isLoadingProjects = false);
        }
      }
    } catch (e) {
      if (mounted && _projects.isEmpty) setState(() => _isLoadingProjects = false);
    }
  }

  IconData _mapIcon(String iconClass) {
    if (iconClass.contains('building')) return Icons.domain;
    if (iconClass.contains('house')) return Icons.home_work;
    if (iconClass.contains('compass') || iconClass.contains('drafting')) return Icons.architecture;
    return Icons.construction;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 460),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Background.png'), 
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [const Color(0xFF0a0a0a).withOpacity(0.9), const Color(0xFF0a0a0a).withOpacity(0.3)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 180, left: 24, right: 54),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESAIN & BANGUN\nDENGAN KUALITAS\nPREMIUM',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 6, width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.5), blurRadius: 15)],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      width: 350,
                      child: Text(
                        'Kami adalah mitra terpercaya Anda dalam mewujudkan properti impian, dari konsep hingga serah terima kunci di Semarang dan sekitarnya.',
                        style: TextStyle(color: Color(0xFFf4f4f5), fontSize: 14, fontWeight: FontWeight.w600, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('LAYANAN KAMI', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                        Container(margin: const EdgeInsets.only(top: 5), height: 4, width: 40, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(10))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(), 
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final s = _services[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15), 
                          child: _buildServiceCard(
                            s['title'].toString().toUpperCase(), 
                            s['description'], 
                            _mapIcon(s['icon']),
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 70), 
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.2)))),
                    child: const Text('ALUR KERJA', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2)),
                  ),
                  Column(
                    children: List.generate(_alurKerja.length, (index) {
                      final step = _alurKerja[index];
                      return _buildWorkflowStep(
                        index,
                        step['icon'],
                        step['title'],
                        step['desc'],
                      );
                    }),
                  ),
                ], 
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PROYEK KAMI', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                    Container(margin: const EdgeInsets.only(top: 5), height: 4, width: 40, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(10))),
                  ],
                ),
                const SizedBox(height: 24),
                _isLoadingProjects
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFFD4AF37))))
                    : _projects.isEmpty
                        ? const Center(child: Text('Tidak ada proyek', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _projects.length > 3 ? 3 : _projects.length,
                            itemBuilder: (context, index) {
                              final project = _projects[index];
                              var imageUrl = project['image'] ?? '';
                              final title = project['title'] ?? 'Proyek';

                              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                                imageUrl = getOptimizedImageUrl(imageUrl, size: 'large');
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: imageUrl.isNotEmpty
                                            ? _buildSafeNetworkImage(imageUrl, fit: BoxFit.cover)
                                            : Container(
                                                color: const Color(0xFF151515),
                                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onNavigateToGallery?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('GALERI KAMI', style: TextStyle(color: Color(0xFF0a0a0a), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 1.1)),
              const SizedBox(height: 8),
              Text(
                desc, 
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Positioned(
            right: -20, bottom: -40,
            child: Icon(icon, size: 120, color: Colors.white.withOpacity(0.03)),
          )
        ],
      ),
    );
  }

  Widget _buildWorkflowStep(int index, IconData icon, String title, String desc) {
    bool isExpanded = _expandedWorkflowIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedWorkflowIndex = isExpanded ? null : index;
        });
      },
      child: Container(
        color: Colors.transparent, 
        margin: const EdgeInsets.only(bottom: 20), 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: isExpanded ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 48, 
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title, 
                      style: TextStyle(
                        color: isExpanded ? const Color(0xFFD4AF37) : Colors.white, 
                        fontSize: 15, 
                        fontWeight: FontWeight.bold, 
                        fontStyle: FontStyle.italic, 
                        letterSpacing: -0.5
                      )
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity, height: 0),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        desc, 
                        style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5)
                      ),
                    ),
                    crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. HALAMAN GALERI (DARI DATABASE)
// ==========================================
class GalleryScreen extends StatefulWidget {
  final VoidCallback onBack;

  const GalleryScreen({super.key, required this.onBack});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _galleryItems = [];
  int? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGalleryData();
  }

  Future<void> fetchGalleryData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cache_gallery');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        if (mounted) {
          setState(() {
            _categories = data['categories'] ?? [];
            _galleryItems = data['items'] ?? data['data'] ?? [];
            if (_categories.isNotEmpty && _selectedCategoryId == null) _selectedCategoryId = _categories[0]['id'];
            _isLoading = false;
          });
        }
      }

      String url = 'http://192.168.1.15/mandorbangun.id/api/gallery.php';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          prefs.setString('cache_gallery', response.body);
          if (mounted) {
            setState(() {
              _categories = data['categories'] ?? [];
              _galleryItems = data['items'] ?? data['data'] ?? [];
              if (_categories.isNotEmpty && _selectedCategoryId == null) _selectedCategoryId = _categories[0]['id'];
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted && _categories.isEmpty) setState(() => _isLoading = false);
    }
  }

  // JURUS FILTER LOKAL UDAH GW PASANG MBUTT!
  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    // fetchGalleryData dihapus biar perpindahan tab 0 detik tanpa muter-muter
  }

  @override
  Widget build(BuildContext context) {
    // NGAMBIL DATA YANG UDAH DISORTIR SESUAI TAB LOKAL
    final filteredItems = _selectedCategoryId == null 
        ? _galleryItems 
        : _galleryItems.where((item) => item['category_id'].toString() == _selectedCategoryId.toString()).toList();

    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 150),

                // JUDUL HALAMAN 
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('GALERI KAMI', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                      Container(margin: const EdgeInsets.only(top: 5), height: 4, width: 40, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(10))),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'Setiap proyek adalah cerita. Temukan inspirasi dari karya desain dan konstruksi yang telah kami wujudkan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5), 
                        ),
                      ),
                    ],
                  ),
                ),
                
                // KATEGORI TABS
                if (_categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24), 
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.center, 
                        spacing: 12, 
                        runSpacing: 10, 
                        children: List.generate(_categories.length, (index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategoryId == category['id'];
                          return GestureDetector(
                            onTap: () => _filterByCategory(category['id']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category['name'],
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF0a0a0a) : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // GALLERY GRID MENGGUNAKAN DATA FILTER LOKAL
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Tidak ada galeri', style: TextStyle(color: Colors.grey)),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              var imageUrl = item['main_image_path'] ?? item['main_image'] ?? item['image_path'] ?? '';

                              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                                imageUrl = getOptimizedImageUrl(imageUrl, size: 'thumb');
                              }

                              return GestureDetector(
                                onTap: () {
                                  showGalleryDetailModal(context, item, imageUrl);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    color: const Color(0xFF111111),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          child: imageUrl.isNotEmpty
                                              // TAMBAHIN cacheWidth: 350 BIAR GAMBAR GALERI ENTENG! 👇
                                              ? _buildSafeNetworkImage(imageUrl, fit: BoxFit.cover, cacheWidth: 350) 
                                              : Container(
                                                  color: const Color(0xFF151515),
                                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                                ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          item['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
    );
  }

  void showGalleryDetailModal(BuildContext context, dynamic item, String mainImageUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      builder: (context) {
        return GalleryDetailSheet(
          item: item,
          mainImageUrl: mainImageUrl,
        );
      },
    );
  }
}

// ==========================================
// GALLERY DETAIL BOTTOM SHEET
// ==========================================
class GalleryDetailSheet extends StatefulWidget {
  final dynamic item;
  final String mainImageUrl;

  const GalleryDetailSheet({
    super.key,
    required this.item,
    required this.mainImageUrl,
  });

  @override
  State<GalleryDetailSheet> createState() => _GalleryDetailSheetState();
}

class _GalleryDetailSheetState extends State<GalleryDetailSheet> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.item['images'] ?? [];
    final itemTitle = widget.item['title'] ?? 'Galeri';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CLOSE BUTTON
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      itemTitle,
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // IMAGE GALLERY
              if (images.isNotEmpty)
                Column(
                  children: [
                    // PAGE VIEW
                    SizedBox(
                      height: 350,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          var imageUrl = images[index]['path'] ?? '';
                          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                            imageUrl = 'http://192.168.1.15/mandorbangun.id/$imageUrl';
                          }

                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: imageUrl.isNotEmpty
                                ? _buildSafeNetworkImage(imageUrl, fit: BoxFit.cover)
                                : Container(
                                    color: const Color(0xFF151515),
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                          );
                        },
                      ),
                    ),
                    // IMAGE COUNTER & PAGINATION
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentImageIndex + 1} / ${images.length}',
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              images.length > 5 ? 5 : images.length,
                              (index) {
                                final isActive = index == (_currentImageIndex % 5);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Container(
                                    width: isActive ? 20 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isActive ? const Color(0xFFD4AF37) : Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // IMAGE CAPTION
                    if (images[_currentImageIndex]['caption'] != null && images[_currentImageIndex]['caption'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            images[_currentImageIndex]['caption'],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    // THUMBNAILS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(images.length, (index) {
                            var thumbUrl = images[index]['path'] ?? '';
                            if (thumbUrl.isNotEmpty && !thumbUrl.startsWith('http')) {
                              thumbUrl = 'http://192.168.1.15/mandorbangun.id/$thumbUrl';
                            }

                          return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _currentImageIndex == index
                                        ? const Color(0xFFD4AF37)
                                        : Colors.white.withOpacity(0.2),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFF151515),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: thumbUrl.isNotEmpty
                                      ? _buildSafeNetworkImage(thumbUrl, fit: BoxFit.cover)
                                      : const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 6. HALAMAN PROFIL (FLOATING CARDS ELEGAN)
// ==========================================
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
        // FIX ERROR NULL: Pastiin data['data'] nggak null sebelum dipecah
        if (mounted && data['data'] != null) {
          setState(() {
            _email = data['data']['email'] ?? _email;
            _whatsapp = data['data']['whatsapp'] ?? _whatsapp;
            _address = data['data']['address'] ?? _address;
            _isLoading = false;
          });
        }
      }

      final response = await http.get(Uri.parse('http://192.168.1.15/mandorbangun.id/api/contact.php'));

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
          if (mounted && cachedData == null) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi buat buka link sosmed / aplikasi
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
          const SizedBox(height: 170), // Jarak dari header atas
          
          // 1. HERO SECTION (Glow Emas & Logo)
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow Ambient Emas
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.25), blurRadius: 40, spreadRadius: 10)
                  ],
                ),
              ),
              // Kotak Logo Elegan
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF222222), Color(0xFF0A0A0A)],
                  ),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 1.5),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, 10))],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Text('MB', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TEKS MANDORBANGUN.ID
          RichText(
            text: const TextSpan(
              style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2),
              children: [
                TextSpan(text: 'MANDORBANGUN', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'ID', style: TextStyle(color: Color(0xFFD4AF37))),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // TEKS PROFESSIONAL CONTRACTOR
          const Text('PROFESSIONAL CONTRACTOR', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3)),
          
          // GARIS PEMISAH ELEGAN (Fading)
          Container(
            margin: const EdgeInsets.only(top: 24, bottom: 40),
            height: 2, width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFFD4AF37), Colors.transparent]),
              borderRadius: BorderRadius.circular(10)
            )
          ),

          // ========================================================
          // 2. KONTEN KOTAK TERPISAH (FLOATING CARDS)
          // ========================================================

          // A. FONDASI UTAMA
          _buildSectionTitle(Icons.change_history, 'FONDASI UTAMA KAMI'),
          const SizedBox(height: 16),
          _buildSeparateCard(
            icon: Icons.verified_outlined,
            title: 'INTEGRITAS & KUALITAS',
            desc: 'Penggunaan material berstandar SNI dengan eksekusi pengerjaan presisi tinggi dan terpercaya.',
          ),
          const SizedBox(height: 16),
          _buildSeparateCard(
            icon: Icons.receipt_long_outlined,
            title: 'TRANSPARANSI RAB',
            desc: 'Rincian anggaran terbuka sejak awal tanpa adanya biaya siluman atau perubahan sepihak.',
          ),
          const SizedBox(height: 16),
          _buildSeparateCard(
            icon: Icons.shield_outlined,
            title: 'DEDIKASI & GARANSI',
            desc: 'Pendampingan penuh hingga selesai, dilengkapi garansi pemeliharaan pasca serah terima (B.A.S.T).',
          ),
          const SizedBox(height: 40),

          // B. VISI KAMI
          _buildSectionTitle(Icons.adjust, 'VISI KAMI'),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: const Text(
              ' "Menjadi kontraktor terkemuka yang diakui secara nasional dan internasional, memberikan solusi konstruksi inovatif dan berkualitas tinggi untuk membangun masa depan yang berkelanjutan." ',
              style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),

          // C. MISI KAMI
          _buildSectionTitle(Icons.check_circle_outline, 'MISI KAMI'),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(
              children: [ 
                _buildMisiItem('Menyelesaikan tanggung jawab pekerjaan hingga tuntas dengan standar mutu tinggi.'),
                _buildMisiItem('Berusaha membangun kepercayaan dan amanah kepada customer dengan memberikan hasil terbaik.'),
                _buildMisiItem('Melayani customer dengan sepenuh hati dan mewujudkan bangunan impian.', isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // D. HUBUNGI KAMI
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
                      _buildContactRow(Icons.phone_outlined, 'WHATSAPP', _whatsapp),
                      _buildDivider(),
                      _buildContactRow(Icons.location_on_outlined, 'ALAMAT', _address, isLast: true),

                      // GARIS PEMISAH UNTUK SOSMED
                      Container(margin: const EdgeInsets.symmetric(vertical: 24), height: 1, width: double.infinity, color: Colors.white.withOpacity(0.05)),

                      // LOGO SOSMED
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialIcon(FontAwesomeIcons.instagram, 'https://instagram.com/mandorbangun.id'),
                          _buildSocialIcon(FontAwesomeIcons.facebook, 'https://facebook.com/mandorbangun.id'),
                          _buildSocialIcon(FontAwesomeIcons.tiktok, 'https://tiktok.com/@mandorbangun.id'),
                          _buildSocialIcon(FontAwesomeIcons.globe, 'https://mandorbangunid.com'),
                        ],
                      )
                    ],
                  ),
                ),

          // 3. FOOTER
          const SizedBox(height: 40),
          // Efek Garis Berdenyut (Pulsing Divider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, const Color(0xFFD4AF37).withOpacity(0.5)])))),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16), width: 6, height: 6, 
                  decoration: BoxDecoration(color: const Color(0xFFD4AF37), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.8), blurRadius: 10)]),
                ),
                Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFD4AF37).withOpacity(0.5), Colors.transparent])))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('MANDORBANGUNID.APP V2.0', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4)),
          const SizedBox(height: 120), // Jarak aman buat Navbar bawah
        ],
      ),
    );
  }

  // WIDGET HELPER: SECTION TITLE (Teks Ngambang Tanpa Kotak)
  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  // WIDGET HELPER: GAYA KOTAK KARTU (Shadow & Border)
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF141414), // Abu-abu gelap
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
    );
  }

  // WIDGET HELPER: KARTU FONDASI TERPISAH
  Widget _buildSeparateCard({required IconData icon, required String title, required String desc}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon Kotak dengan border emas
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.5),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // WIDGET HELPER: ITEM MISI
  Widget _buildMisiItem(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.circle, color: Color(0xFFD4AF37), size: 6)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5))),
        ],
      ),
    );
  }

  // WIDGET HELPER: DIVIDER
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: Colors.white.withOpacity(0.05), thickness: 1, height: 1),
    );
  }

  // WIDGET HELPER: BARIS KONTAK
  Widget _buildContactRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        )
      ],
    );
  }

  // WIDGET HELPER: TOMBOL SOSMED FOOTER
  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), 
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)]
        ),
        child: Icon(icon, color: Colors.grey[400], size: 18),
      ),
    );
  }
}
