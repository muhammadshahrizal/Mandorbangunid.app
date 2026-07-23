import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _bgColor = Color(0xFF0A0A0A);
const Color _surfaceColor = Color(0xFF151515);
const Color _cardColor = Color(0xFF1A1A1A);
const Color _accentColor = Color(0xFFD4AF37);
const Color _mutedTextColor = Colors.grey;

class RabScreen extends StatefulWidget {
  const RabScreen({super.key});

  @override
  State<RabScreen> createState() => _RabScreenState();
}

class _RabScreenState extends State<RabScreen> {
  // ============================================================
  // CONTROLLER
  // ============================================================
  final TextEditingController _luasController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================
  String _jenisBangunan = 'Rumah Tinggal';
  String _kualitasBangunan = 'Standar';
  String _lokasiKota = 'Jabodetabek';
  int _jumlahLantai = 1;
  double? _totalEstimasi;
  String? _estimasiWaktu;
  bool _isLoading = false;

  // Harga dasar per m2
  final Map<String, double> _hargaPerM2 = {
    'Ekonomis': 3000000,
    'Standar': 4000000,
    'Premium': 5500000,
  };

  // Multiplier Harga Berdasarkan Lokasi Kota
  final Map<String, double> _multiplierLokasi = {
    'Jabodetabek': 1.0,
    'Jawa Barat': 0.95,
    'Jawa Tengah & DIY': 0.85,
    'Jawa Timur': 0.90,
    'Luar Pulau Jawa': 1.20,
  };

  // ============================================================
  // HITUNG RAB
  // ============================================================
  Future<void> _hitungRab() async {
    final String luasText = _luasController.text.trim();
    if (luasText.isEmpty) {
      _showSnackBar('Masukkan luas bangunan terlebih dahulu.', isError: true);
      return;
    }

    final double? luas = double.tryParse(luasText.replaceAll(',', '.'));
    if (luas == null || luas <= 0) {
      _showSnackBar('Luas bangunan tidak valid.', isError: true);
      return;
    }

    if (luas > 10000) {
      _showSnackBar('Luas terlalu besar, hubungi admin untuk proyek raksasa.', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _totalEstimasi = null;
      _estimasiWaktu = null;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    double hargaDasar = _hargaPerM2[_kualitasBangunan]!;
    double multiplierLantai = _jumlahLantai == 2 ? 1.15 : 1.0;
    double multiplierKota = _multiplierLokasi[_lokasiKota]!;

    double hargaFinalPerMeter = hargaDasar * multiplierLantai * multiplierKota;

    String hitungWaktu;
    if (luas < 50) {
      hitungWaktu = _jumlahLantai == 1 ? '2 - 3 Bulan' : '3 - 4 Bulan';
    } else if (luas <= 100) {
      hitungWaktu = _jumlahLantai == 1 ? '3 - 4 Bulan' : '4 - 5 Bulan';
    } else if (luas <= 200) {
      hitungWaktu = _jumlahLantai == 1 ? '4 - 6 Bulan' : '6 - 7 Bulan';
    } else {
      hitungWaktu = '> 7 Bulan (Sesuai Desain)';
    }

    setState(() {
      _totalEstimasi = luas * hargaFinalPerMeter;
      _estimasiWaktu = hitungWaktu;
      _isLoading = false;
    });
  }

  // ============================================================
  // RESET
  // ============================================================
  void _resetRab() {
    setState(() {
      _luasController.clear();
      _jenisBangunan = 'Rumah Tinggal';
      _kualitasBangunan = 'Standar';
      _lokasiKota = 'Jabodetabek';
      _jumlahLantai = 1;
      _totalEstimasi = null;
      _estimasiWaktu = null;
      _isLoading = false;
    });
    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // SPESIFIKASI MATERIAL
  // ============================================================
  String _getSpesifikasiTeks() {
    if (_kualitasBangunan == 'Ekonomis') {
      return "  Lantai: Keramik 40x40 cm\n  Dinding: Batako / Bata Ringan Standard\n  Atap: Rangka Kayu + Genteng Tanah Liat\n  Cat: Catylac / Setara\n  Plafon: Gypsum Rangka Hollow";
    } else if (_kualitasBangunan == 'Premium') {
      return "  Lantai: Granit Tile 80x80 cm / Marmer\n  Dinding: Bata Merah (Double Wall)\n  Atap: Baja Ringan + Genteng Keramik Kanmuri\n  Cat: Jotun / Dulux Premium\n  Lainnya: Smart Home Ready, Sanitasi Toto Premium";
    } else {
      return "  Lantai: Granit 60x60 cm\n  Dinding: Bata Merah / Hebel\n  Atap: Baja Ringan + Genteng Beton\n  Cat: Dulux / Mowilex\n  Sanitasi: Toto Standard / American Standard";
    }
  }

  // ============================================================
  // HUBUNGI WHATSAPP
  // ============================================================
  Future<void> _hubungiWhatsApp() async {
    if (_totalEstimasi == null) {
      _showSnackBar('Hitung estimasi terlebih dahulu.', isError: true);
      return;
    }

    final String noWA = '628152318805';
    final String pesan = '''Halo MandorBangun, saya ingin konsultasi mengenai proyek saya:
*Lokasi:* $_lokasiKota
*Jenis:* $_jenisBangunan ($_jumlahLantai Lantai)
*Kualitas:* $_kualitasBangunan
*Luas:* ${_luas.toStringAsFixed(0)} m²
*Estimasi RAB:* Rp ${_formatRupiah(_totalEstimasi!)}
*Estimasi Waktu:* $_estimasiWaktu

Mohon info lebih lanjut untuk penawaran resminya. Terima kasih!''';

    final String url = 'https://wa.me/$noWA?text=${Uri.encodeComponent(pesan)}';
    final Uri uri = Uri.parse(url);

    try {
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        _showSnackBar('Gagal membuka WhatsApp.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: _accentColor),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: _cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatRupiah(double value) {
    final String valueString = value.round().toString();
    final StringBuffer result = StringBuffer();
    int counter = 0;
    for (int i = valueString.length - 1; i >= 0; i--) {
      result.write(valueString[i]);
      counter++;
      if (counter == 3 && i != 0) {
        result.write('.');
        counter = 0;
      }
    }
    return result.toString().split('').reversed.join();
  }

  double get _luas {
    return double.tryParse(_luasController.text.replaceAll(',', '.')) ?? 0;
  }

  // ============================================================
  // BAGIKAN / COPY
  // ============================================================
  void _copyResult() {
    if (_totalEstimasi == null) return;
    final double total = _totalEstimasi!;

    final String result = '''ESTIMASI RAB MANDORBANGUN.ID
----------------------------
Lokasi: $_lokasiKota
Jenis Bangunan: $_jenisBangunan ($_jumlahLantai Lantai)
Luas Bangunan: ${_luas.toStringAsFixed(0)} m²
Kualitas Material: $_kualitasBangunan

*TOTAL ESTIMASI: Rp ${_formatRupiah(total)}*
*ESTIMASI WAKTU: $_estimasiWaktu*

*SPESIFIKASI MATERIAL ($_kualitasBangunan):*
${_getSpesifikasiTeks()}

*RINCIAN BIAYA PEKERJAAN:*
- Persiapan & Tanah (5%): Rp ${_formatRupiah(total * 0.05)}
- Pondasi & Beton (25%): Rp ${_formatRupiah(total * 0.25)}
- Dinding & Plesteran (15%): Rp ${_formatRupiah(total * 0.15)}
- Atap & Rangka (12%): Rp ${_formatRupiah(total * 0.12)}
- Plafon (8%): Rp ${_formatRupiah(total * 0.08)}
- Lantai & Keramik (10%): Rp ${_formatRupiah(total * 0.10)}
- Pintu & Jendela (10%): Rp ${_formatRupiah(total * 0.10)}
- Pengecatan (5%): Rp ${_formatRupiah(total * 0.05)}
- Elektrikal & Plumbing (10%): Rp ${_formatRupiah(total * 0.10)}

Catatan: Estimasi ini merupakan perkiraan awal. MandorBangun.id''';

    Clipboard.setData(ClipboardData(text: result));
    _showSnackBar('Rincian lengkap RAB berhasil disalin.');
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // SPASI ATAS SUPAYA GA NABAARRAK APP BAR GLOBAL MAIN SCREEN
          const SliverToBoxAdapter(
            child: SizedBox(height: 110),
          ),
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildInputSection(),
                  const SizedBox(height: 20),
                  _buildCalculateButton(),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SizeTransition(sizeFactor: animation, child: FadeTransition(opacity: animation, child: child));
                    },
                    child: _isLoading 
                        ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator(color: _accentColor))
                        : _totalEstimasi != null 
                            ? Container(key: const ValueKey('result'), child: _buildResultCard()) 
                            : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                  const SizedBox(height: 20),
                  if (_totalEstimasi != null) _buildDisclaimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.calculate_outlined, color: _accentColor, size: 25),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KALKULATOR RAB',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1),
                ),
                SizedBox(height: 4),
                Text('Ketahui estimasi detail biaya & material', style: TextStyle(color: _mutedTextColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_accentColor.withValues(alpha: 0.18), _cardColor]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: _accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gunakan kalkulator ini untuk mendapatkan rincian biaya proyek dan spesifikasi material. Hubungi kami untuk survey akurat.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA PROYEK',
            style: TextStyle(color: _accentColor, fontSize: 14, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          _buildLabel('Lokasi Pembangunan'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _lokasiKota,
            icon: Icons.location_on_outlined,
            items: const ['Jabodetabek', 'Jawa Barat', 'Jawa Tengah & DIY', 'Jawa Timur', 'Luar Pulau Jawa'],
            onChanged: (value) { if (value != null) setState(() => _lokasiKota = value); },
          ),
          const SizedBox(height: 20),
          _buildLabel('Jenis Bangunan'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _jenisBangunan,
            icon: Icons.home_work_outlined,
            items: const ['Rumah Tinggal', 'Ruko', 'Kantor', 'Bangunan Lainnya'],
            onChanged: (value) { if (value != null) setState(() => _jenisBangunan = value); },
          ),
          const SizedBox(height: 20),
          _buildLabel('Jumlah Lantai'),
          const SizedBox(height: 8),
          _buildLantaiChips(),
          const SizedBox(height: 20),
          _buildLabel('Luas Bangunan Total'),
          const SizedBox(height: 8),
          TextField(
            controller: _luasController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Contoh: 100',
              hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
              suffixText: 'm²',
              suffixStyle: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
              filled: true,
              fillColor: const Color(0xFF0D0D0D),
              prefixIcon: const Icon(Icons.square_foot, color: Color(0xFFD4AF37)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Kualitas Material'),
          const SizedBox(height: 12),
          _buildQualityChips(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600));
  }

  Widget _buildDropdown({required String value, required List<String> items, required IconData icon, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD4AF37)),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0D0D0D),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
      items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildLantaiChips() {
    return Row(
      children: [1, 2].map((lantai) {
        final bool isSelected = _jumlahLantai == lantai;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _jumlahLantai = lantai),
            child: Container(
              margin: EdgeInsets.only(right: lantai == 2 ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? _accentColor.withValues(alpha: 0.2) : const Color(0xFF0D0D0D),
                border: Border.all(color: isSelected ? _accentColor : Colors.white.withValues(alpha: 0.1), width: isSelected ? 1.5 : 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('$lantai Lantai', style: TextStyle(color: isSelected ? _accentColor : _mutedTextColor, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQualityChips() {
    final List<String> kualitas = ['Ekonomis', 'Standar', 'Premium'];
    return Row(
      children: kualitas.map((item) {
        final bool isSelected = _kualitasBangunan == item;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _kualitasBangunan = item),
            child: Container(
              margin: EdgeInsets.only(right: item == 'Premium' ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? _accentColor.withValues(alpha: 0.2) : const Color(0xFF0D0D0D),
                border: Border.all(color: isSelected ? _accentColor : Colors.white.withValues(alpha: 0.1), width: isSelected ? 1.5 : 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item, style: TextStyle(color: isSelected ? _accentColor : _mutedTextColor, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _hitungRab,
        icon: const Icon(Icons.auto_graph, color: _bgColor),
        label: const Text('HITUNG ESTIMASI RAB', style: TextStyle(color: _bgColor, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // ============================================================
  // RESULT CARD - KONTRAKTOR VERSION
  // ============================================================
  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accentColor.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: _accentColor.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          const Text('HASIL ESTIMASI', style: TextStyle(color: _accentColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 16),
          const Text('Perkiraan Total Biaya', style: TextStyle(color: _mutedTextColor, fontSize: 12)),
          const SizedBox(height: 4),
          
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _totalEstimasi!),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutExpo,
            builder: (context, value, child) {
              return Text('Rp ${_formatRupiah(value)}', textAlign: TextAlign.center, style: const TextStyle(color: _accentColor, fontSize: 27, fontWeight: FontWeight.w900));
            },
          ),
          const SizedBox(height: 16),
          
          // WIDGET ESTIMASI WAKTU
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: _accentColor, size: 20),
                const SizedBox(width: 10),
                Text('Estimasi Waktu: $_estimasiWaktu', style: const TextStyle(color: _accentColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // SPESIFIKASI MATERIAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.architecture, color: _accentColor, size: 16),
                    const SizedBox(width: 8),
                    Text('Spesifikasi Material ($_kualitasBangunan)', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_getSpesifikasiTeks(), style: const TextStyle(color: _mutedTextColor, fontSize: 11, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // RINCIAN PEKERJAAN DETAIL (ACCORDION)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 0),
              iconColor: _accentColor,
              collapsedIconColor: _mutedTextColor,
              title: const Text('Lihat Rincian Biaya Pekerjaan', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0D0D0D), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                  child: Column(
                    children: [
                      _buildBreakdownRow('Persiapan & Tanah', 0.05, Colors.brown),
                      _buildBreakdownRow('Pondasi & Beton', 0.25, Colors.blueGrey),
                      _buildBreakdownRow('Dinding & Plesteran', 0.15, Colors.orange),
                      _buildBreakdownRow('Atap & Rangka', 0.12, Colors.redAccent),
                      _buildBreakdownRow('Plafon', 0.08, Colors.lightBlue),
                      _buildBreakdownRow('Lantai & Keramik', 0.10, Colors.teal),
                      _buildBreakdownRow('Pintu & Jendela', 0.10, Colors.purple),
                      _buildBreakdownRow('Pengecatan', 0.05, Colors.pink),
                      _buildBreakdownRow('Elektrikal & Plumbing', 0.10, Colors.yellow[700]!),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyResult,
                  icon: const Icon(Icons.copy_outlined, size: 17),
                  label: const Text('SALIN'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accentColor,
                    side: const BorderSide(color: _accentColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetRab,
                  icon: const Icon(Icons.refresh, size: 17),
                  label: const Text('RESET'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _hubungiWhatsApp,
              icon: const Icon(Icons.chat, color: Colors.white, size: 18),
              label: const Text('LANJUT KONSULTASI VIA WA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String title, double percentage, Color color) {
    final double value = _totalEstimasi! * percentage;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text('Rp ${_formatRupiah(value)}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              color: color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(14)),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: _mutedTextColor, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Perhitungan ini adalah estimasi awal. Harga material dan jasa menyesuaikan lokasi. Estimasi waktu belum termasuk proses perizinan dan cuaca. Hubungi tim MandorBangun untuk survey akurat.',
              style: TextStyle(color: _mutedTextColor, fontSize: 10, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _luasController.dispose();
    super.dispose();
  }
}