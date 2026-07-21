import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with WidgetsBindingObserver {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color bgColor = Color(0xFF0A0A0A);
  static const Color cardColor = Color(0xFF111111);
  static const Color bubbleColor = Color(0xFF1A1A1A);
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color textGrey = Color(0xFF9E9E9E);

  // ============================================================
  // API CONFIG
  // ============================================================

  static const String apiUrl =
      'http://192.168.1.23/Mandorbangun.id/api/chatbot.php';

  static const Duration requestTimeout =
      Duration(seconds: 30);

  // ============================================================
  // COMPANY INFORMATION
  // ============================================================

  static const String companyName =
      'PT Mandorbangunid Persada';

  static const String companyBrand =
      'Mandorbangun';

  static const String companyAddress =
      'Ruko Bukit Emerald Jaya, Blok C No.05, '
      'Meteseh, Kec. Tembalang, '
      'Kota Semarang, Jawa Tengah 50271';

  static const String companyPhone =
      '08123456789';

  static const String companyEmail =
      'Mandorbangun.id23@gmail.com';

  static const String companyWebsite =
      'https://www.Mandorbangunid.com/';

  static const String companyInstagram =
      'Mandorbangun.id';

  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final FocusNode _inputFocusNode =
      FocusNode();

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;

  bool _isKeyboardVisible = false;

  String? _lastUserQuestion;

  String? _lastErrorMessage;

  // ============================================================
  // MESSAGES
  // ============================================================

  final List<Map<String, dynamic>> _messages = [];

  // ============================================================
  // QUICK QUESTIONS
  // ============================================================

  final List<Map<String, String>>
      _quickQuestions = [

    {
      'label': '🏠 Layanan',
      'question':
          'Apa saja layanan yang tersedia di Mandorbangun?',
    },

    {
      'label': '💰 Estimasi',
      'question':
          'Bagaimana cara mendapatkan estimasi biaya pembangunan atau renovasi rumah?',
    },

    {
      'label': '📍 Lokasi',
      'question':
          'Di mana lokasi kantor Mandorbangun?',
    },

    {
      'label': '📞 Kontak',
      'question':
          'Bagaimana cara menghubungi Mandorbangun?',
    },

    {
      'label': '🛠️ Konsultasi',
      'question':
          'Saya ingin konsultasi pembangunan atau renovasi rumah.',
    },
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addObserver(this);

    _addInitialMessage();
  }

  // ============================================================
  // INITIAL MESSAGE
  // ============================================================

  void _addInitialMessage() {
    _messages.add({
      'sender': 'bot',
      'text':
          'Halo! 👋 Saya Asisten Mandorbangun.\n\n'
          'Saya siap membantu Anda seputar layanan '
          'pembangunan rumah, renovasi, desain, '
          'estimasi biaya, dan konsultasi proyek.\n\n'
          'Silakan pilih pertanyaan cepat di bawah '
          'atau ketik pertanyaan Anda.',
      'time': DateTime.now(),
      'intent': 'welcome',
    });
  }

  // ============================================================
  // KEYBOARD OBSERVER
  // ============================================================

  @override
  void didChangeMetrics() {
    if (!mounted) {
      return;
    }

    final bottomInset =
        WidgetsBinding
            .instance
            .platformDispatcher
            .views
            .first
            .viewInsets
            .bottom;

    final keyboardVisible =
        bottomInset > 0;

    if (keyboardVisible !=
        _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible =
            keyboardVisible;
      });
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _handleSendMessage() async {
    final text =
        _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    await _sendMessage(text);
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage(
    String text,
  ) async {
    text = text.trim();

    if (text.isEmpty ||
        _isLoading) {
      return;
    }

    _lastUserQuestion = text;

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': DateTime.now(),
        'intent': 'user_question',
      });

      _isLoading = true;

      _lastErrorMessage = null;
    });

    _messageController.clear();

    _closeKeyboard();

    _scrollToBottom();

    // ==========================================================
    // CEK INFORMASI STATIS
    // ==========================================================

    final staticReply =
        _getStaticResponse(text);

    if (staticReply != null) {
      await Future.delayed(
        const Duration(
          milliseconds: 350,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': staticReply['reply'],
          'time': DateTime.now(),
          'intent': staticReply['intent'],
          'static': true,
        });

        _isLoading = false;
      });

      _scrollToBottom();

      return;
    }

    // ==========================================================
    // REQUEST GROQ VIA PHP
    // ==========================================================

    try {
      debugPrint(
        '====================================',
      );

      debugPrint(
        'CHATBOT REQUEST',
      );

      debugPrint(
        'URL: $apiUrl',
      );

      debugPrint(
        'MESSAGE: $text',
      );

      debugPrint(
        '====================================',
      );

      final response =
          await http
              .post(
                Uri.parse(apiUrl),

                headers: {
                  'Content-Type':
                      'application/json',

                  'Accept':
                      'application/json',
                },

                body:
                    jsonEncode({
                  'message': text,
                }),
              )
              .timeout(
                requestTimeout,
              );

      debugPrint(
        'CHATBOT STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'CHATBOT RESPONSE: '
        '${response.body}',
      );

      if (response.statusCode ==
          200) {
        await _handleSuccessResponse(
          response.body,
        );
      } else {
        _handleHttpError(
          response.statusCode,
          response.body,
        );
      }
    } on TimeoutException {
      _handleConnectionError(
        'Waktu koneksi ke server habis.',
      );
    } on http.ClientException catch (e) {
      debugPrint(
        'CLIENT EXCEPTION: $e',
      );

      _handleConnectionError(
        'Aplikasi tidak dapat terhubung '
        'ke server chatbot.',
      );
    } on FormatException catch (e) {
      debugPrint(
        'JSON FORMAT ERROR: $e',
      );

      _handleConnectionError(
        'Server memberikan data yang '
        'tidak dapat diproses.',
      );
    } catch (e) {
      debugPrint(
        'CHATBOT EXCEPTION: $e',
      );

      _handleConnectionError(
        'Terjadi gangguan saat menghubungi '
        'server chatbot.',
      );
    }
  }

  // ============================================================
  // STATIC RESPONSE
  // ============================================================

  Map<String, String>?
      _getStaticResponse(
    String message,
  ) {
    final text =
        message.toLowerCase();

    // ==========================================================
    // LOKASI
    // ==========================================================

    if (text.contains('lokasi') ||
        text.contains('alamat kantor') ||
        text.contains('kantor dimana') ||
        text.contains('kantor di mana') ||
        text.contains('kantor mandor')) {
      return {
        'intent':
            'company_location',

        'reply':
            '📍 Kantor Mandorbangun berada di:\n\n'
            '$companyAddress\n\n'
            'Anda juga dapat membuka lokasi kantor '
            'langsung melalui Google Maps menggunakan '
            'tombol "Buka Google Maps" di bawah.',
      };
    }

    // ==========================================================
    // KONTAK
    // ==========================================================

    if (text.contains('kontak') ||
        text.contains('hubungi') ||
        text.contains('nomor') ||
        text.contains('whatsapp') ||
        text.contains('wa ') ||
        text.contains('telepon') ||
        text.contains('email')) {
      return {
        'intent':
            'company_contact',

        'reply':
            '📞 Anda dapat menghubungi tim Mandorbangun melalui:\n\n'
            'WhatsApp: $companyPhone\n'
            'Email: $companyEmail\n\n'
            'Silakan tekan tombol "Hubungi Kami" '
            'untuk langsung terhubung melalui WhatsApp.',
      };
    }

    // ==========================================================
    // JAM OPERASIONAL
    // ==========================================================

    if (text.contains('jam buka') ||
        text.contains('jam kerja') ||
        text.contains('jam operasional') ||
        text.contains('buka jam berapa') ||
        text.contains('operasional')) {
      return {
        'intent':
            'company_hours',

        'reply':
            '🕐 Jam operasional Mandorbangun:\n\n'
            'Senin - Sabtu\n'
            '08.00 - 16.00 WIB\n\n'
            'Minggu: Tutup',
      };
    }

    // ==========================================================
    // LAYANAN
    // ==========================================================

    if (text.contains('layanan') ||
        text.contains('jasa apa') ||
        text.contains('jasa yang tersedia') ||
        text.contains('melayani apa')) {
      return {
        'intent':
            'company_services',

        'reply':
            '🏠 Mandorbangun menyediakan layanan:\n\n'
            '1. Pembangunan rumah\n'
            '2. Renovasi rumah\n'
            '3. Konsultasi pembangunan\n'
            '4. Konsultasi renovasi\n'
            '5. Desain dan perencanaan rumah\n'
            '6. Estimasi dan konsultasi kebutuhan proyek\n\n'
            'Silakan pilih layanan yang sesuai dengan '
            'kebutuhan Anda.',
      };
    }

    // ==========================================================
    // WEBSITE
    // ==========================================================

    if (text.contains('website') ||
        text.contains('web resmi')) {
      return {
        'intent':
            'company_website',

        'reply':
            '🌐 Website resmi Mandorbangun:\n\n'
            '$companyWebsite',
      };
    }

    return null;
  }

  // ============================================================
  // HANDLE SUCCESS RESPONSE
  // ============================================================

  Future<void> _handleSuccessResponse(
    String responseBody,
  ) async {
    if (responseBody
        .trim()
        .isEmpty) {
      _handleConnectionError(
        'Server tidak memberikan jawaban.',
      );

      return;
    }

    try {
      final dynamic decoded =
          jsonDecode(responseBody);

      if (decoded is! Map) {
        _handleConnectionError(
          'Format jawaban server tidak dikenali.',
        );

        return;
      }

      final Map<String, dynamic>
          data =
          Map<String, dynamic>.from(
        decoded,
      );

      final bool success =
          data['success'] == true;

      if (success) {
        final String reply =
            data['reply']
                    ?.toString()
                    .trim() ??
                '';

        final String intent =
            data['intent']
                    ?.toString() ??
                'general_question';

        if (reply.isEmpty) {
          _handleConnectionError(
            'Chatbot tidak memberikan jawaban.',
          );

          return;
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': reply,
            'time': DateTime.now(),
            'intent': intent,
          });

          _isLoading = false;
        });

        _scrollToBottom();

        return;
      }

      final String error =
          data['error']
                  ?.toString()
                  .trim() ??
              'Terjadi kesalahan pada server.';

      _handleConnectionError(
        error,
      );
    } catch (e) {
      debugPrint(
        'RESPONSE PARSE ERROR: $e',
      );

      _handleConnectionError(
        'Respons dari server tidak valid.',
      );
    }
  }

  // ============================================================
  // HTTP ERROR
  // ============================================================

  void _handleHttpError(
    int statusCode,
    String responseBody,
  ) {
    debugPrint(
      'HTTP ERROR $statusCode',
    );

    debugPrint(
      responseBody,
    );

    String message;

    switch (statusCode) {
      case 400:
        message =
            'Permintaan ke server tidak valid.';
        break;

      case 401:
        message =
            'Konfigurasi API chatbot bermasalah.';
        break;

      case 404:
        message =
            'Endpoint chatbot tidak ditemukan.\n\n'
            'Periksa alamat API pada aplikasi.';
        break;

      case 429:
        message =
            'Layanan AI sedang mencapai batas penggunaan.\n\n'
            'Silakan coba lagi beberapa saat.';
        break;

      case 500:
        message =
            'Server chatbot mengalami gangguan.';
        break;

      case 502:
      case 503:
      case 504:
        message =
            'Layanan chatbot sedang tidak tersedia.';
        break;

      default:
        message =
            'Terjadi gangguan pada server '
            '(HTTP $statusCode).';
    }

    _handleConnectionError(
      message,
    );
  }

  // ============================================================
  // CONNECTION ERROR
  // ============================================================

  void _handleConnectionError(
    String error,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;

      _lastErrorMessage = error;

      _messages.add({
        'sender': 'bot',
        'text':
            '⚠️ $error\n\n'
            'Silakan coba lagi menggunakan tombol '
            '"Coba Lagi".',
        'time': DateTime.now(),
        'intent': 'connection_error',
        'canRetry': true,
      });
    });

    _scrollToBottom();
  }

  // ============================================================
  // RETRY
  // ============================================================

  Future<void> _retryLastMessage() async {
    if (_lastUserQuestion ==
            null ||
        _isLoading) {
      return;
    }

    final question =
        _lastUserQuestion!;

    await _sendMessage(
      question,
    );
  }

  // ============================================================
  // CLEAR CHAT
  // ============================================================

  Future<void> _clearChat() async {
    final bool?
        confirmed =
        await showDialog<bool>(
      context: context,

      builder: (
        context,
      ) {
        return AlertDialog(
          backgroundColor:
              cardColor,

          title: const Text(
            'Hapus Percakapan?',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content:
              const Text(
            'Semua pesan dalam percakapan ini '
            'akan dihapus.',
            style: TextStyle(
              color: textGrey,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text(
                'Batal',
                style:
                    TextStyle(
                  color: textGrey,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    goldColor,

                foregroundColor:
                    bgColor,
              ),

              child:
                  const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _messages.clear();

      _lastUserQuestion =
          null;

      _lastErrorMessage =
          null;

      _addInitialMessage();
    });

    _scrollToBottom(
      animated: false,
    );
  }

  // ============================================================
  // WHATSAPP
  // ============================================================

  Future<void> _openWhatsApp() async {
    const String phone =
        '628123456789';

    final Uri url =
        Uri.parse(
      'https://wa.me/$phone',
    );

    try {
      final bool launched =
          await launchUrl(
        url,
        mode:
            LaunchMode
                .externalApplication,
      );

      if (!launched) {
        _showSnackBar(
          'WhatsApp tidak dapat dibuka.',
        );
      }
    } catch (e) {
      debugPrint(
        'WHATSAPP ERROR: $e',
      );

      _showSnackBar(
        'Gagal membuka WhatsApp.',
      );
    }
  }

  // ============================================================
  // GOOGLE MAPS
  // ============================================================

  Future<void> _openGoogleMaps() async {
    final Uri url =
        Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=Ruko+Bukit+Emerald+Jaya+Blok+C+No+05+Meteseh+Tembalang+Semarang',
    );

    try {
      final bool launched =
          await launchUrl(
        url,
        mode:
            LaunchMode
                .externalApplication,
      );

      if (!launched) {
        _showSnackBar(
          'Google Maps tidak dapat dibuka.',
        );
      }
    } catch (e) {
      debugPrint(
        'MAPS ERROR: $e',
      );

      _showSnackBar(
        'Gagal membuka Google Maps.',
      );
    }
  }

  // ============================================================
  // EMAIL
  // ============================================================

  Future<void> _openEmail() async {
    final Uri emailUri =
        Uri(
      scheme: 'mailto',
      path:
          companyEmail,
      query:
          'subject=Konsultasi Mandorbangun',
    );

    try {
      final bool launched =
          await launchUrl(
        emailUri,
      );

      if (!launched) {
        _showSnackBar(
          'Aplikasi email tidak tersedia.',
        );
      }
    } catch (e) {
      _showSnackBar(
        'Gagal membuka email.',
      );
    }
  }

  // ============================================================
  // FOLLOW UP QUESTION
  // ============================================================

  List<Map<String, dynamic>>
      _getFollowUpQuestions(
    String intent,
  ) {
    switch (intent) {
      case 'company_location':
        return [
          {
            'label':
                '🗺️ Buka Maps',
            'action':
                'maps',
          },
          {
            'label':
                '📞 Hubungi Kami',
            'action':
                'whatsapp',
          },
        ];

      case 'company_contact':
        return [
          {
            'label':
                '💬 WhatsApp',
            'action':
                'whatsapp',
          },
          {
            'label':
                '📧 Email',
            'action':
                'email',
          },
        ];

      case 'company_services':
        return [
          {
            'label':
                '💰 Tanya Estimasi',
            'question':
                'Bagaimana cara mendapatkan estimasi biaya pembangunan rumah?',
          },
          {
            'label':
                '🛠️ Konsultasi',
            'question':
                'Saya ingin konsultasi pembangunan rumah.',
          },
        ];

      case 'potential_customer':
        return [
          {
            'label':
                '📞 Hubungi Kami',
            'action':
                'whatsapp',
          },
          {
            'label':
                '📍 Lokasi Kantor',
            'question':
                'Di mana lokasi kantor Mandorbangun?',
          },
        ];

      default:
        return [
          {
            'label':
                '🏠 Layanan',
            'question':
                'Apa saja layanan Mandorbangun?',
          },
          {
            'label':
                '💰 Estimasi',
            'question':
                'Bagaimana cara mendapatkan estimasi biaya?',
          },
        ];
    }
  }

  // ============================================================
  // HANDLE FOLLOW UP
  // ============================================================

  void _handleFollowUp(
    Map<String, dynamic> item,
  ) {
    final action =
        item['action'];

    if (action ==
        'whatsapp') {
      _openWhatsApp();

      return;
    }

    if (action ==
        'maps') {
      _openGoogleMaps();

      return;
    }

    if (action ==
        'email') {
      _openEmail();

      return;
    }

    final question =
        item['question'];

    if (question !=
        null) {
      _sendMessage(
        question,
      );
    }
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToBottom({
    bool animated = true,
  }) {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted ||
            !_scrollController
                .hasClients) {
          return;
        }

        final position =
            _scrollController
                .position;

        if (!position
            .hasContentDimensions) {
          return;
        }

        if (animated) {
          _scrollController
              .animateTo(
            position
                .maxScrollExtent,

            duration:
                const Duration(
              milliseconds: 250,
            ),

            curve:
                Curves.easeOutCubic,
          );
        } else {
          _scrollController
              .jumpTo(
            position
                .maxScrollExtent,
          );
        }
      },
    );
  }

  // ============================================================
  // CLOSE KEYBOARD
  // ============================================================

  void _closeKeyboard() {
    FocusManager
        .instance
        .primaryFocus
        ?.unfocus();
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger
        .of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger
        .of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),

        duration:
            const Duration(
          seconds: 2,
        ),

        behavior:
            SnackBarBehavior
                .floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: Container(
        height:
            MediaQuery.of(
                  context,
                ).size.height *
                0.88,

        decoration:
            const BoxDecoration(
          color: bgColor,

          borderRadius:
              BorderRadius.only(
            topLeft:
                Radius.circular(28),
            topRight:
                Radius.circular(28),
          ),
        ),

        child: Column(
          children: [

            _buildHeader(),

            Expanded(
              child:
                  _buildChatList(),
            ),

            if (_isLoading)
              _buildTypingIndicator(),

            AnimatedSwitcher(
              duration:
                  const Duration(
                milliseconds: 120,
              ),

              child:
                  _isKeyboardVisible
                      ? const SizedBox
                          .shrink()
                      : _buildQuickQuestions(),
            ),

            _buildInput(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),

      decoration:
          const BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.only(
          topLeft:
              Radius.circular(28),
          topRight:
              Radius.circular(28),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 44,
            height: 44,

            decoration:
                BoxDecoration(
              color:
                  goldColor.withValues(
                alpha: 0.15,
              ),

              shape:
                  BoxShape.circle,

              border:
                  Border.all(
                color:
                    goldColor.withValues(
                  alpha: 0.35,
                ),
              ),
            ),

            child:
                const Icon(
              Icons
                  .smart_toy_rounded,
              color:
                  goldColor,
              size: 23,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  'Asisten Mandorbangun',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 4,
                ),

                Row(
                  children: [

                    Icon(
                      Icons
                          .circle,
                      color:
                          Colors.green,
                      size: 8,
                    ),

                    SizedBox(
                      width: 5,
                    ),

                    Text(
                      'Online • Siap membantu',
                      style:
                          TextStyle(
                        color:
                            Colors.green,
                        fontSize:
                            10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            tooltip:
                'Hapus percakapan',

            onPressed:
                _isLoading
                    ? null
                    : _clearChat,

            icon:
                const Icon(
              Icons
                  .delete_outline_rounded,
              color:
                  Colors.grey,
              size: 21,
            ),
          ),

          IconButton(
            tooltip:
                'Tutup',

            onPressed:
                () {
              _closeKeyboard();

              Navigator.pop(
                context,
              );
            },

            icon:
                const Icon(
              Icons
                  .close_rounded,
              color:
                  Colors.grey,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHAT LIST
  // ============================================================

  Widget _buildChatList() {
    return ListView.builder(
      controller:
          _scrollController,

      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior
              .onDrag,

      physics:
          const BouncingScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        14,
        18,
        14,
        14,
      ),

      itemCount:
          _messages.length,

      itemBuilder:
          (
        context,
        index,
      ) {
        final message =
            _messages[index];

        return _buildMessage(
          message,
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  Widget _buildMessage(
    Map<String, dynamic>
        message,
  ) {
    final bool isUser =
        message['sender'] ==
            'user';

    final String text =
        message['text']
                ?.toString() ??
            '';

    final String intent =
        message['intent']
                ?.toString() ??
            'general_question';

    final bool canRetry =
        message['canRetry'] ==
            true;

    final DateTime time =
        message['time']
                is DateTime
            ? message['time']
            : DateTime.now();

    final bool showActions =
        !isUser &&
        intent != 'welcome';

    return Align(
      alignment:
          isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,

      child:
          Container(
        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),

        child:
            Row(
          mainAxisAlignment:
              isUser
                  ? MainAxisAlignment
                      .end
                  : MainAxisAlignment
                      .start,

          crossAxisAlignment:
              CrossAxisAlignment
                  .end,

          children: [

            if (!isUser)
              _buildAvatar(
                false,
              ),

            if (!isUser)
              const SizedBox(
                width: 8,
              ),

            Flexible(
              child:
                  Column(
                crossAxisAlignment:
                    isUser
                        ? CrossAxisAlignment
                            .end
                        : CrossAxisAlignment
                            .start,

                children: [

                  Container(
                    constraints:
                        BoxConstraints(
                      maxWidth:
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.78,
                    ),

                    padding:
                        const EdgeInsets.all(
                      13,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          isUser
                              ? goldColor
                              : bubbleColor,

                      borderRadius:
                          BorderRadius.only(
                        topLeft:
                            const Radius
                                .circular(
                          18,
                        ),

                        topRight:
                            const Radius
                                .circular(
                          18,
                        ),

                        bottomLeft:
                            Radius.circular(
                          isUser
                              ? 18
                              : 4,
                        ),

                        bottomRight:
                            Radius.circular(
                          isUser
                              ? 4
                              : 18,
                        ),
                      ),
                    ),

                    child:
                        _buildMessageContent(
                      text,
                      isUser,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    _formatTime(
                      time,
                    ),

                    style:
                        const TextStyle(
                      color:
                          textGrey,
                      fontSize:
                          9,
                    ),
                  ),

                  if (canRetry)
                    _buildRetryButton(),

                  if (showActions)
                    _buildActionButtons(
                      intent,
                    ),
                ],
              ),
            ),

            if (isUser)
              const SizedBox(
                width: 8,
              ),

            if (isUser)
              _buildAvatar(
                true,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE CONTENT
  // ============================================================

  Widget _buildMessageContent(
    String text,
    bool isUser,
  ) {
    return SelectableText(
      text,

      style:
          TextStyle(
        color:
            isUser
                ? bgColor
                : Colors.white,

        fontSize:
            13,

        height:
            1.5,
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildAvatar(
    bool isUser,
  ) {
    return Container(
      width: 30,
      height: 30,

      decoration:
          BoxDecoration(
        color:
            isUser
                ? goldColor
                : goldColor.withValues(
                    alpha: 0.15,
                  ),

        shape:
            BoxShape.circle,
      ),

      child:
          Icon(
        isUser
            ? Icons.person_rounded
            : Icons.smart_toy_rounded,

        color:
            isUser
                ? bgColor
                : goldColor,

        size: 17,
      ),
    );
  }

  // ============================================================
  // RETRY BUTTON
  // ============================================================

  Widget _buildRetryButton() {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 8,
      ),

      child:
          OutlinedButton.icon(
        onPressed:
            _isLoading
                ? null
                : _retryLastMessage,

        icon:
            const Icon(
          Icons
              .refresh_rounded,
          size: 15,
        ),

        label:
            const Text(
          'Coba Lagi',
          style:
              TextStyle(
            fontSize: 11,
          ),
        ),

        style:
            OutlinedButton
                .styleFrom(
          foregroundColor:
              goldColor,

          side:
              BorderSide(
            color:
                goldColor.withValues(
              alpha: 0.6,
            ),
          ),

          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 12,
          ),

          minimumSize:
              const Size(
            0,
            32,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons(
    String intent,
  ) {
    final actions =
        _getFollowUpQuestions(
      intent,
    );

    if (actions.isEmpty) {
      return const SizedBox
          .shrink();
    }

    return Container(
      margin:
          const EdgeInsets.only(
        top: 8,
      ),

      constraints:
          const BoxConstraints(
        maxWidth: 280,
      ),

      child:
          Wrap(
        spacing: 6,
        runSpacing: 6,

        children:
            actions.map(
          (
            item,
          ) {
            return ActionChip(
              label:
                  Text(
                item['label']
                        ?.toString() ??
                    '',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      10,
                ),
              ),

              backgroundColor:
                  const Color(
                0xFF181818,
              ),

              side:
                  BorderSide(
                color:
                    goldColor.withValues(
                  alpha: 0.5,
                ),
              ),

              onPressed:
                  _isLoading
                      ? null
                      : () {
                          _handleFollowUp(
                            item,
                          );
                        },
            );
          },
        ).toList(),
      ),
    );
  }

  // ============================================================
  // TYPING INDICATOR
  // ============================================================

  Widget _buildTypingIndicator() {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),

      child:
          Row(
        mainAxisAlignment:
            MainAxisAlignment
                .center,

        children: [

          _buildTypingDot(
            0,
          ),

          const SizedBox(
            width: 4,
          ),

          _buildTypingDot(
            1,
          ),

          const SizedBox(
            width: 4,
          ),

          _buildTypingDot(
            2,
          ),

          const SizedBox(
            width: 8,
          ),

          const Text(
            'Asisten sedang mengetik...',
            style:
                TextStyle(
              color:
                  textGrey,
              fontSize:
                  10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(
    int index,
  ) {
    return Container(
      width: 6,
      height: 6,

      decoration:
          const BoxDecoration(
        color:
            goldColor,

        shape:
            BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // QUICK QUESTIONS
  // ============================================================

  Widget _buildQuickQuestions() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),

      decoration:
          BoxDecoration(
        color:
            cardColor,

        border:
            Border(
          top:
              BorderSide(
            color:
                Colors.white
                    .withValues(
              alpha: 0.05,
            ),
          ),
        ),
      ),

      child:
          SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,

        physics:
            const BouncingScrollPhysics(),

        child:
            Row(
          children:
              _quickQuestions.map(
            (
              item,
            ) {
              final String label =
                  item['label'] ??
                      '';

              final String question =
                  item['question'] ??
                      '';

              return Padding(
                padding:
                    const EdgeInsets.only(
                  right: 7,
                ),

                child:
                    ActionChip(
                  label:
                      Text(
                    label,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          10,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  backgroundColor:
                      const Color(
                    0xFF181818,
                  ),

                  side:
                      BorderSide(
                    color:
                        goldColor.withValues(
                      alpha: 0.65,
                    ),
                  ),

                  onPressed:
                      _isLoading
                          ? null
                          : () {
                              _sendMessage(
                                question,
                              );
                            },
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget _buildInput() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        10,
      ),

      color:
          cardColor,

      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .end,

        children: [

          if (_isKeyboardVisible)
            IconButton(
              tooltip:
                  'Tutup keyboard',

              onPressed:
                  _closeKeyboard,

              icon:
                  const Icon(
                Icons
                    .keyboard_hide_outlined,
                color:
                    textGrey,
                size: 20,
              ),
            ),

          Expanded(
            child:
                TextField(
              controller:
                  _messageController,

              focusNode:
                  _inputFocusNode,

              minLines:
                  1,

              maxLines:
                  4,

              textInputAction:
                  TextInputAction
                      .newline,

              keyboardType:
                  TextInputType
                      .multiline,

              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize:
                    13,
              ),

              decoration:
                  InputDecoration(
                hintText:
                    'Ketik pertanyaan...',

                hintStyle:
                    const TextStyle(
                  color:
                      textGrey,
                  fontSize:
                      12,
                ),

                filled:
                    true,

                fillColor:
                    bubbleColor,

                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      16,

                  vertical:
                      11,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),

              onSubmitted:
                  (_) {
                if (!_isLoading) {
                  _handleSendMessage();
                }
              },
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          ValueListenableBuilder<
              TextEditingValue>(
            valueListenable:
                _messageController,

            builder:
                (
              context,
              value,
              child,
            ) {
              final bool
                  canSend =
                  value.text
                          .trim()
                          .isNotEmpty &&
                      !_isLoading;

              return AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),

                width:
                    45,

                height:
                    45,

                decoration:
                    BoxDecoration(
                  color:
                      canSend
                          ? goldColor
                          : const Color(
                              0xFF444444,
                            ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    _isLoading
                        ? const Padding(
                            padding:
                                EdgeInsets.all(
                              13,
                            ),

                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,

                              color:
                                  goldColor,
                            ),
                          )
                        : IconButton(
                            onPressed:
                                canSend
                                    ? _handleSendMessage
                                    : null,

                            icon:
                                const Icon(
                              Icons
                                  .send_rounded,

                              color:
                                  bgColor,
                            ),
                          ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(
    DateTime time,
  ) {
    final String hour =
        time.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String minute =
        time.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$hour:$minute';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(
      this,
    );

    _messageController
        .dispose();

    _scrollController
        .dispose();

    _inputFocusNode
        .dispose();

    super.dispose();
  }
}