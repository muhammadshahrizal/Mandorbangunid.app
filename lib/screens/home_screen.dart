import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/image_utils.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGallery;

  const HomeScreen({
    super.key,
    this.onNavigateToGallery,
  });

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
    {
      'icon': Icons.chat_outlined,
      'title': 'KONSULTASI',
      'desc':
          'Kami melakukan konsultasi bersama calon klien untuk mengetahui apa saja yang dibutuhkan.',
    },
    {
      'icon': Icons.search,
      'title': 'SURVEY',
      'desc':
          'Melakukan peninjauan langsung ke lokasi proyek untuk mengukur dan menganalisa kondisi lapangan.',
    },
    {
      'icon': Icons.architecture,
      'title': 'PERENCANAAN',
      'desc':
          'Membuat desain arsitektur, gambar kerja, dan menyusun Rencana Anggaran Biaya (RAB).',
    },
    {
      'icon': Icons.handshake_outlined,
      'title': 'AKAD PELAKSANAAN',
      'desc':
          'Penandatanganan kontrak kerja kesepakatan antara tim Mandorbangun.id dengan klien.',
    },
    {
      'icon': Icons.construction,
      'title': 'PELAKSANAAN',
      'desc':
          'Proses pembangunan atau renovasi properti sesuai dengan perencanaan dan jadwal yang disepakati.',
    },
    {
      'icon': Icons.fact_check_outlined,
      'title': 'SURVEY PRA PELAKSANA',
      'desc':
          'Pengecekan ulang kesiapan lapangan sebelum tahap finishing atau tahap krusial lainnya.',
    },
    {
      'icon': Icons.checklist,
      'title': 'CEKLIST B.A.S.T',
      'desc':
          'Pemeriksaan detail seluruh pekerjaan bersama klien untuk memastikan kualitas sesuai standar.',
    },
    {
      'icon': Icons.task_alt,
      'title': 'B.A.S.T',
      'desc':
          'Berita Acara Serah Terima: Penyerahan kunci dan dokumen resmi sebagai tanda proyek selesai 100%.',
    },
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

        if (mounted) {
          setState(() {
            _services = data['data'] ?? [];
            _isLoading = false;
          });
        }
      }

      final response = await http
          .get(
            Uri.parse(
              'http://192.168.1.23/mandorbangun.id/api/services.php',
            ),
          )
          .timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          prefs.setString(
            'cache_services',
            response.body,
          );

          if (mounted) {
            setState(() {
              _services = data['data'] ?? [];
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint(
        '🚨 ERROR NARIK SERVICES: $e',
      );

      if (mounted && _services.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> fetchProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(
        'cache_projects',
      );

      if (cachedData != null) {
        final data = json.decode(cachedData);

        if (mounted) {
          setState(() {
            _projects = data['data'] ?? [];
            _isLoadingProjects = false;
          });
        }
      }

      final response = await http.get(
        Uri.parse(
          'http://192.168.1.23/mandorbangun.id/api/portfolio.php',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(
          response.body,
        );

        if (data['success'] == true &&
            data['data'] != null) {
          prefs.setString(
            'cache_projects',
            response.body,
          );

          if (mounted) {
            setState(() {
              _projects = data['data'] ?? [];
              _isLoadingProjects = false;
            });
          }
        } else {
          if (mounted && _projects.isEmpty) {
            setState(() {
              _isLoadingProjects = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted && _projects.isEmpty) {
        setState(() {
          _isLoadingProjects = false;
        });
      }
    }
  }

  IconData _mapIcon(
    String iconClass,
  ) {
    if (iconClass.contains('building')) {
      return Icons.domain;
    }

    if (iconClass.contains('house')) {
      return Icons.home_work;
    }

    if (iconClass.contains('compass') ||
        iconClass.contains('drafting')) {
      return Icons.architecture;
    }

    return Icons.construction;
  }

  // ============================================================
  // BUKA CHATBOT
  // ============================================================

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom,
          ),
          child: const ChatbotScreen(),
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      children: [

        // ======================================================
        // KONTEN HOME ASLI
        // ======================================================

        SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          // Tambahan padding supaya konten
          // tidak tertutup tombol Chat AI
          padding: const EdgeInsets.only(
            bottom: 110,
          ),

          child: Column(
            children: [

              // ==================================================
              // HERO
              // ==================================================

              Container(
                width: double.infinity,

                constraints:
                    const BoxConstraints(
                  minHeight: 460,
                ),

                decoration:
                    const BoxDecoration(
                  image:
                      DecorationImage(
                    image: AssetImage(
                      'assets/Background.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Container(
                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.centerLeft,
                      end:
                          Alignment.centerRight,
                      colors: [
                        const Color(
                          0xFF0a0a0a,
                        ).withValues(
                          alpha: 0.9,
                        ),
                        const Color(
                          0xFF0a0a0a,
                        ).withValues(
                          alpha: 0.3,
                        ),
                      ],
                    ),
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 180,
                      left: 24,
                      right: 54,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(
                          'DESAIN & BANGUN\n'
                          'DENGAN KUALITAS\n'
                          'PREMIUM',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFFD4AF37,
                            ),
                            fontSize: 34,
                            fontWeight:
                                FontWeight.w900,
                            fontStyle:
                                FontStyle.italic,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),

                        Container(
                          margin:
                              const EdgeInsets.only(
                            top: 10,
                          ),

                          height: 6,
                          width: 90,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFD4AF37,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(
                                  0xFFD4AF37,
                                ).withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        const SizedBox(
                          width: 350,

                          child: Text(
                            'Kami adalah mitra terpercaya Anda '
                            'dalam mewujudkan properti impian, '
                            'dari konsep hingga serah terima '
                            'kunci di Semarang dan sekitarnya.',

                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFFf4f4f5,
                              ),
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // LAYANAN
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 50,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(
                              'LAYANAN KAMI',

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFFD4AF37,
                                ),
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w900,
                                fontStyle:
                                    FontStyle.italic,
                              ),
                            ),

                            Container(
                              margin:
                                  const EdgeInsets.only(
                                top: 5,
                              ),

                              height: 4,
                              width: 40,

                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFD4AF37,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    _isLoading

                        ? const Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  Color(
                                0xFFD4AF37,
                              ),
                            ),
                          )

                        : ListView.builder(
                            padding:
                                const EdgeInsets.only(
                              top: 10,
                            ),

                            shrinkWrap:
                                true,

                            physics:
                                const NeverScrollableScrollPhysics(),

                            itemCount:
                                _services.length,

                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final s =
                                  _services[index];

                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  bottom: 15,
                                ),

                                child:
                                    _buildServiceCard(
                                  s['title']
                                      .toString()
                                      .toUpperCase(),

                                  s['description'],

                                  _mapIcon(
                                    s['icon'],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),

              // ==================================================
              // ALUR KERJA
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 70,
                ),

                child: Container(
                  padding:
                      const EdgeInsets.all(
                    30,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF111111,
                    ),

                    border:
                        Border.all(
                      color:
                          Colors.white.withValues(
                        alpha: 0.05,
                      ),
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      35,
                    ),

                    boxShadow:
                        const [
                      BoxShadow(
                        color:
                            Colors.black54,
                        blurRadius: 30,
                        offset:
                            Offset(
                          0,
                          10,
                        ),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),

                        margin:
                            const EdgeInsets.only(
                          bottom: 40,
                        ),

                        decoration:
                            BoxDecoration(
                          border:
                              Border(
                            bottom:
                                BorderSide(
                              color:
                                  const Color(
                                0xFFD4AF37,
                              ).withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ),

                        child:
                            const Text(
                          'ALUR KERJA',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFFD4AF37,
                            ),
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w900,
                            fontStyle:
                                FontStyle.italic,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      Column(
                        children:
                            List.generate(
                          _alurKerja.length,
                          (
                            index,
                          ) {
                            final step =
                                _alurKerja[
                                    index];

                            return _buildWorkflowStep(
                              index,
                              step['icon'],
                              step['title'],
                              step['desc'],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // PROYEK KAMI
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 120,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(
                          'PROYEK KAMI',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFFD4AF37,
                            ),
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w900,
                            fontStyle:
                                FontStyle.italic,
                          ),
                        ),

                        Container(
                          margin:
                              const EdgeInsets.only(
                            top: 5,
                          ),

                          height: 4,
                          width: 40,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFD4AF37,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    _isLoadingProjects

                        ? const Center(
                            child:
                                Padding(
                              padding:
                                  EdgeInsets.all(
                                20,
                              ),

                              child:
                                  CircularProgressIndicator(
                                color:
                                    Color(
                                  0xFFD4AF37,
                                ),
                              ),
                            ),
                          )

                        : _projects.isEmpty

                        ? const Center(
                            child: Text(
                              'Tidak ada proyek',

                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          )

                        : ListView.builder(
                            padding:
                                EdgeInsets.zero,

                            shrinkWrap:
                                true,

                            physics:
                                const NeverScrollableScrollPhysics(),

                            itemCount:
                                _projects.length >
                                        3
                                    ? 3
                                    : _projects.length,

                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final project =
                                  _projects[index];

                              var imageUrl =
                                  project['image'] ??
                                  '';

                              final title =
                                  project['title'] ??
                                  'Proyek';

                              if (imageUrl.isNotEmpty &&
                                  !imageUrl.startsWith(
                                    'http',
                                  )) {
                                imageUrl =
                                    getOptimizedImageUrl(
                                  imageUrl,
                                  size:
                                      'large',
                                );
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  bottom: 20,
                                ),

                                child:
                                    ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),

                                  child:
                                      Stack(
                                    children: [

                                      Container(
                                        width:
                                            double.infinity,

                                        height:
                                            250,

                                        decoration:
                                            BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                            16,
                                          ),

                                          border:
                                              Border.all(
                                            color:
                                                Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                        ),

                                        child:
                                            imageUrl.isNotEmpty

                                                ? buildSafeNetworkImage(
                                                    imageUrl,
                                                    fit:
                                                        BoxFit.cover,
                                                  )

                                                : Container(
                                                    color:
                                                        const Color(
                                                      0xFF151515,
                                                    ),

                                                    child:
                                                        const Icon(
                                                      Icons
                                                          .image_not_supported,
                                                      color:
                                                          Colors.grey,
                                                    ),
                                                  ),
                                      ),

                                      Positioned(
                                        bottom:
                                            0,

                                        left:
                                            0,

                                        right:
                                            0,

                                        child:
                                            Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),

                                          decoration:
                                              BoxDecoration(
                                            gradient:
                                                LinearGradient(
                                              begin:
                                                  Alignment.topCenter,
                                              end:
                                                  Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ],
                                            ),
                                          ),

                                          child:
                                              Text(
                                            title,

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white,
                                              fontSize:
                                                  16,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),

                                            maxLines:
                                                2,

                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    const SizedBox(
                      height: 24,
                    ),

                    SizedBox(
                      width:
                          double.infinity,

                      child:
                          ElevatedButton(
                        onPressed:
                            () {
                          widget
                              .onNavigateToGallery
                              ?.call();
                        },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFD4AF37,
                          ),

                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),

                        child:
                            const Text(
                          'GALERI KAMI',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF0a0a0a,
                            ),
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // FLOATING CHAT AI
        // ======================================================

        Positioned(
          right: 20,
          bottom: 95,

          child:
              Material(
            color:
                Colors.transparent,

            child:
                InkWell(
              onTap:
                  _openChatbot,

              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              child:
                  Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 12,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFD4AF37,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    30,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(
                        alpha: 0.55,
                      ),

                      blurRadius:
                          14,

                      offset:
                          const Offset(
                        0,
                        6,
                      ),
                    ),
                  ],
                ),

                child:
                    const Row(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    Icon(
                      Icons
                          .chat_bubble_outline_rounded,

                      color:
                          Color(
                        0xFF0A0A0A,
                      ),

                      size:
                          21,
                    ),

                    SizedBox(
                      width:
                          8,
                    ),

                    Text(
                      'CHAT AI',

                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF0A0A0A,
                        ),

                        fontSize:
                            13,

                        fontWeight:
                            FontWeight.w900,

                        letterSpacing:
                            0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    String title,
    String desc,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        30,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF151515,
        ),

        border:
            Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.05,
          ),
        ),

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        boxShadow:
            const [
          BoxShadow(
            color:
                Colors.black26,
            blurRadius:
                20,
          ),
        ],
      ),

      child:
          Stack(
        clipBehavior:
            Clip.none,

        children: [

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFFD4AF37,
                  ),

                  fontSize:
                      18,

                  fontWeight:
                      FontWeight.w900,

                  fontStyle:
                      FontStyle.italic,

                  height:
                      1.1,
                ),
              ),

              const SizedBox(
                height:
                    8,
              ),

              Text(
                desc,

                style:
                    TextStyle(
                  color:
                      Colors.grey[500],

                  fontSize:
                      13,
                ),

                maxLines:
                    4,

                overflow:
                    TextOverflow.ellipsis,
              ),
            ],
          ),

          Positioned(
            right:
                -20,

            bottom:
                -40,

            child:
                Icon(
              icon,

              size:
                  120,

              color:
                  Colors.white.withValues(
                alpha: 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStep(
    int index,
    IconData icon,
    String title,
    String desc,
  ) {
    final bool isExpanded =
        _expandedWorkflowIndex ==
            index;

    return GestureDetector(
      onTap:
          () {
        setState(
          () {
            _expandedWorkflowIndex =
                isExpanded
                    ? null
                    : index;
          },
        );
      },

      child:
          Container(
        color:
            Colors.transparent,

        margin:
            const EdgeInsets.only(
          bottom:
              20,
        ),

        child:
            Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              width:
                  48,

              height:
                  48,

              decoration:
                  BoxDecoration(
                color:
                    Colors.black,

                border:
                    Border.all(
                  color:
                      isExpanded
                          ? const Color(
                              0xFFD4AF37,
                            )
                          : Colors.white.withValues(
                              alpha: 0.1,
                            ),
                ),

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child:
                  Icon(
                icon,

                color:
                    const Color(
                  0xFFD4AF37,
                ),

                size:
                    20,
              ),
            ),

            const SizedBox(
              width:
                  20,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Container(
                    height:
                        48,

                    alignment:
                        Alignment.centerLeft,

                    child:
                        Text(
                      title,

                      style:
                          TextStyle(
                        color:
                            isExpanded
                                ? const Color(
                                    0xFFD4AF37,
                                  )
                                : Colors.white,

                        fontSize:
                            15,

                        fontWeight:
                            FontWeight.bold,

                        fontStyle:
                            FontStyle.italic,

                        letterSpacing:
                            -0.5,
                      ),
                    ),
                  ),

                  AnimatedCrossFade(
                    firstChild:
                        const SizedBox(
                      width:
                          double.infinity,

                      height:
                          0,
                    ),

                    secondChild:
                        Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom:
                            10,
                      ),

                      child:
                          Text(
                        desc,

                        style:
                            TextStyle(
                          color:
                              Colors.grey[500],

                          fontSize:
                              13,

                          height:
                              1.5,
                        ),
                      ),
                    ),

                    crossFadeState:
                        isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,

                    duration:
                        const Duration(
                      milliseconds:
                          300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}