import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'screens/chatbot_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rab_screen.dart';

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
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
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
                errorBuilder: (c, e, s) => const Icon(
                  Icons.construction,
                  color: Color(0xFFD4AF37),
                  size: 50,
                ),
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

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _previousIndex; // Nyimpen info tab sebelumnya biar tau arah geser

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.index;
    // Bikin durasi lebih smooth, nggak kekencengan nggak kelamaan
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
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
    final beginOffset = isMovingRight
        ? const Offset(0.05, 0.0)
        : const Offset(-0.05, 0.0);

    return FadeTransition(
      // Efek Pudar: Dimulai dari agak terang (0.2) ke full (1.0) biar nggak nge-blank item
      opacity: Tween<double>(
        begin: 0.2,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      child: SlideTransition(
        // Efek Geser Tipis: Nyesuain arah lu mencet tab
        position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        ),

        child: ScaleTransition(
          // Efek Zoom Tipis: Dari 98% (agak kecil) nge-zoom ke 100% (normal)
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          ),
          child: IndexedStack(index: widget.index, children: widget.children),
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
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.1),
                  height: 1,
                ),
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
                          isScrollControlled:
                              true, // Wajib true biar pop-up bisa tinggi
                          backgroundColor: Colors
                              .transparent, // Biar background-nya transparan & bisa melengkung
                          builder: (context) {
                            return Padding(
                              // Ini jurus rahasia biar pop-up naik pas keyboard HP muncul
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFD4AF37,
                              ).withValues(alpha: 0.4),
                              blurRadius: 5,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Color(0xFF0a0a0a),
                              size: 20,
                            ),
                            Positioned(top: -2, right: -2, child: PingDot()),
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
      body: AnimatedIndexedStack(
        index: _selectedIndex,
        children: [
          // INDEX 0
          // HOME
          HomeScreen(
            onNavigateToGallery: () => setState(() => _selectedIndex = 1),
          ),

          // INDEX 1
          // GALERI
          GalleryScreen(onBack: () => setState(() => _selectedIndex = 0)),

          // INDEX 2
          // KALKULATOR RAB
          const RabScreen(),

          // INDEX 3
          // PROFIL
          const ProfileScreen(),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          height: 65, // Tinggi fix biar rapi
          decoration: BoxDecoration(
            color: const Color(
              0xFF0A0A0A,
            ), // Warna solid hitam pekat, no muddy color!
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, 'HOME'),
              _buildNavItem(1, Icons.layers_outlined, 'GALERI'),
              _buildNavItem(2, Icons.calculate_outlined, 'KALKULATOR'),
              _buildNavItem(3, Icons.person_outlined, 'PROFIL'),
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
          color: isSelected
              ? const Color(0xFFD4AF37).withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white70,
            ),
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
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
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0a0a0a),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}
