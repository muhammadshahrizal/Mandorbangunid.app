import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  double? _totalEstimasi;

  bool _showDetail = false;

  // ============================================================
  // HARGA PER M2
  // ============================================================

  final Map<String, double> _hargaPerM2 = {
    'Ekonomis': 3000000,
    'Standar': 4000000,
    'Premium': 5500000,
  };

  // ============================================================
  // HITUNG RAB
  // ============================================================

  void _hitungRab() {
    final String luasText = _luasController.text.trim();

    if (luasText.isEmpty) {
      _showSnackBar(
        'Masukkan luas bangunan terlebih dahulu.',
        isError: true,
      );
      return;
    }

    final double? luas = double.tryParse(
      luasText.replaceAll(',', '.'),
    );

    if (luas == null || luas <= 0) {
      _showSnackBar(
        'Luas bangunan tidak valid.',
        isError: true,
      );
      return;
    }

    if (luas > 10000) {
      _showSnackBar(
        'Luas bangunan terlalu besar.',
        isError: true,
      );
      return;
    }

    final double harga = _hargaPerM2[_kualitasBangunan]!;

    setState(() {
      _totalEstimasi = luas * harga;
      _showDetail = false;
    });

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetRab() {
    setState(() {
      _luasController.clear();
      _jenisBangunan = 'Rumah Tinggal';
      _kualitasBangunan = 'Standar';
      _totalEstimasi = null;
      _showDetail = false;
    });

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: const Color(0xFFD4AF37),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT RUPIAH
  // ============================================================

  String _formatRupiah(double value) {
    final String valueString = value
        .round()
        .toString();

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

    return result
        .toString()
        .split('')
        .reversed
        .join();
  }

  // ============================================================
  // GET LUAS
  // ============================================================

  double get _luas {
    return double.tryParse(
          _luasController.text.replaceAll(',', '.'),
        ) ??
        0;
  }

  // ============================================================
  // BAGIKAN / COPY
  // ============================================================

  void _copyResult() {
    if (_totalEstimasi == null) {
      return;
    }

    final double harga =
        _hargaPerM2[_kualitasBangunan]!;

    final String result = '''
ESTIMASI RAB MANDORBANGUN.ID

Jenis Bangunan:
$_jenisBangunan

Luas Bangunan:
${_luas.toStringAsFixed(0)} m²

Kualitas:
$_kualitasBangunan

Estimasi Harga:
Rp ${_formatRupiah(harga)} / m²

Total Estimasi:
Rp ${_formatRupiah(_totalEstimasi!)}

Catatan:
Estimasi ini merupakan perkiraan awal.
Biaya sebenarnya dapat berbeda sesuai kondisi
lokasi, desain, material, dan spesifikasi proyek.

MandorBangun.id
''';

    Clipboard.setData(
      ClipboardData(text: result),
    );

    _showSnackBar(
      'Hasil RAB berhasil disalin.',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                120,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildInfoCard(),

                    const SizedBox(height: 24),

                    _buildInputSection(),

                    const SizedBox(height: 20),

                    _buildCalculateButton(),

                    const SizedBox(height: 20),

                    if (_totalEstimasi != null)
                      _buildResultCard(),

                    const SizedBox(height: 20),

                    _buildDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        20,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37)
                  .withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37)
                    .withOpacity(0.4),
              ),
            ),
            child: const Icon(
              Icons.calculate_outlined,
              color: Color(0xFFD4AF37),
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'KALKULATOR RAB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Estimasi biaya pembangunan',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37)
                .withOpacity(0.18),
            const Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37)
              .withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFD4AF37),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'Gunakan kalkulator ini untuk mendapatkan '
              'gambaran awal biaya pembangunan berdasarkan '
              'luas dan kualitas bangunan.',
              style: TextStyle(
                color: Colors.white
                    .withOpacity(0.8),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT SECTION
  // ============================================================

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA PROYEK',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 20),

          _buildLabel(
            'Luas Bangunan',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _luasController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: 100',
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
              suffixText: 'm²',
              suffixStyle: const TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: const Color(0xFF0D0D0D),
              prefixIcon: const Icon(
                Icons.square_foot,
                color: Color(0xFFD4AF37),
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide:
                    const BorderSide(
                  color: Color(0xFFD4AF37),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildLabel(
            'Jenis Bangunan',
          ),

          const SizedBox(height: 8),

          _buildDropdown(
            value: _jenisBangunan,
            items: const [
              'Rumah Tinggal',
              'Ruko',
              'Kantor',
              'Bangunan Lainnya',
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _jenisBangunan = value;
              });
            },
          ),

          const SizedBox(height: 20),

          _buildLabel(
            'Kualitas Bangunan',
          ),

          const SizedBox(height: 8),

          _buildDropdown(
            value: _kualitasBangunan,
            items: const [
              'Ekonomis',
              'Standar',
              'Premium',
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _kualitasBangunan = value;
              });
            },
          ),

          const SizedBox(height: 12),

          _buildPriceInfo(),
        ],
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor:
          const Color(0xFF1A1A1A),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Color(0xFFD4AF37),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor:
            const Color(0xFF0D0D0D),
        prefixIcon: const Icon(
          Icons.home_work_outlined,
          color: Color(0xFFD4AF37),
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map(
        (item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        },
      ).toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // PRICE INFO
  // ============================================================

  Widget _buildPriceInfo() {
    final double harga =
        _hargaPerM2[_kualitasBangunan]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37)
            .withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            color: Color(0xFFD4AF37),
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Estimasi $_kualitasBangunan: '
              'Rp ${_formatRupiah(harga)} / m²',
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CALCULATE BUTTON
  // ============================================================

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _hitungRab,
        icon: const Icon(
          Icons.calculate,
          color: Color(0xFF0A0A0A),
        ),
        label: const Text(
          'HITUNG ESTIMASI RAB',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFFD4AF37),
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESULT CARD
  // ============================================================

  Widget _buildResultCard() {
    final double harga =
        _hargaPerM2[_kualitasBangunan]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD4AF37)
              .withOpacity(0.35),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'HASIL ESTIMASI',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Perkiraan Total Biaya',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Rp ${_formatRupiah(_totalEstimasi!)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${_luas.toStringAsFixed(0)} m² × '
            'Rp ${_formatRupiah(harga)} / m²',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 20),

          _buildResultRow(
            'Jenis Bangunan',
            _jenisBangunan,
          ),

          _buildResultRow(
            'Kualitas',
            _kualitasBangunan,
          ),

          _buildResultRow(
            'Luas',
            '${_luas.toStringAsFixed(0)} m²',
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyResult,
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 17,
                  ),
                  label: const Text(
                    'SALIN',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(
                      0xFFD4AF37,
                    ),
                    side:
                        const BorderSide(
                      color:
                          Color(0xFFD4AF37),
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetRab,
                  icon: const Icon(
                    Icons.refresh,
                    size: 17,
                  ),
                  label: const Text(
                    'RESET',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.white,
                    side:
                        BorderSide(
                      color: Colors.white
                          .withOpacity(0.2),
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                _showSnackBar(
                  'Silakan hubungi tim MandorBangun untuk konsultasi proyek.',
                );
              },
              icon: const Icon(
                Icons.chat_outlined,
                color: Color(0xFFD4AF37),
              ),
              label: const Text(
                'KONSULTASI DENGAN MANDORBANGUN',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULT ROW
  // ============================================================

  Widget _buildResultRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.03),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.grey,
            size: 18,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Perhitungan ini hanya estimasi awal dan '
              'bukan harga penawaran resmi. Biaya aktual '
              'dapat berbeda berdasarkan desain, lokasi, '
              'kondisi tanah, material, spesifikasi, '
              'dan kebutuhan pekerjaan.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _luasController.dispose();

    super.dispose();
  }
}