import 'package:aquasense/service/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notif.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  List<Map<String, dynamic>> dataBuffer = [];
  int windowSize = 20;

  bool hasNotif = false;
  int stokPakan = 0;
  String kondisiKolam = "menunggu data...";

  Map<String, dynamic>? rekomendasiAi;
  Map<String, dynamic>? featureScores;

  // Data sensor saat ini
  double currentTempAir = 0;
  double currentDO = 0;
  double currentTurbidity = 0;
  double currentPH = 0;
  double currentTDS = 0;
  double currentTempLingkungan = 0;

  Future<void> _fetchPrediction() async {
    setState(() {
      isLoading = true;
    });

    try {
      debugPrint('Memulai analisis manual via tombol...');
      final responseData = await _apiService.checkAnomaly(dataBuffer);
      bool isAnomaly = responseData['is_anomaly'] ?? false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_anomaly', isAnomaly);
      await prefs.setString(
        'last_analysis_time',
        DateTime.now().toIso8601String(),
      );

      if (mounted) {
        setState(() {
          kondisiKolam = isAnomaly ? "buruk" : "baik";
          hasNotif = isAnomaly;
          if (isAnomaly) {
            rekomendasiAi = responseData['rekomendasi'];
            featureScores = responseData['feature_scores'];
          } else {
            rekomendasiAi = null;
            featureScores = null;
          }
        });
      }
    } catch (e) {
      debugPrint("AI Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal analisis: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Format nilai sensor menjadi 2 angka di belakang koma
  String _fmt(double value) => value.toStringAsFixed(2);

  Color getStokColor(int persen) {
    if (persen > 60) return const Color(0xFF52B888);
    if (persen > 25) return const Color(0xFFFFC63D);
    return const Color(0xFFFF0100);
  }

  Color getKolamColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case "baik":
        return const Color(0xFF52B888);
      case "buruk":
        return const Color(0xFFFF0100);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    final horizontalPadding = isTablet ? 48.0 : 16.0;

    // STREAM FIRESTORE: Hanya untuk sinkronisasi UI Sensor
    final Stream<QuerySnapshot> _sensorStream =
        FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'aquasense',
            )
            .collection('sensor_data')
            .where('deviceId', isEqualTo: 'device_1')
            .orderBy('updatedAt', descending: true)
            .limit(windowSize)
            .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _sensorStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isNotEmpty) {
              // Update state data sensor saat ini untuk tampilan Grid
              final latest = docs.first.data() as Map<String, dynamic>;
              currentTempAir = (latest['suhu_air'] ?? 0).toDouble();
              currentDO = (latest['dissolved_oxygen'] ?? 0).toDouble();
              currentTurbidity = (latest['turbidity'] ?? 0).toDouble();
              currentPH = (latest['pH_air'] ?? 0).toDouble();
              currentTDS = (latest['tds'] ?? 0).toDouble(); // ← FIX: tambah TDS
              currentTempLingkungan = (latest['suhu_lingkungan'] ?? 0)
                  .toDouble(); // ← FIX: tambah Suhu Lingkungan
              stokPakan = (latest['pakan_percent'] ?? 0).toInt();

              // Memasukkan data terbaru ke buffer (tanpa auto-trigger)
              dataBuffer = docs
                  .map((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return {
                      'tempAir': (d['suhu_air'] ?? 0).toDouble(),
                      'DO': (d['dissolved_oxygen'] ?? 0).toDouble(),
                      'turbidity': (d['turbidity'] ?? 0).toDouble(),
                      'pH': (d['pH_air'] ?? 0).toDouble(),
                    };
                  })
                  .toList()
                  .reversed
                  .toList();
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D2625),
                            ),
                          ),
                          Text(
                            "",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF97A09F),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotifPage()),
                        ),
                        child: Image.asset(
                          hasNotif
                              ? "assets/icons/Notif_On.png"
                              : "assets/icons/Notif_Off.png",
                          width: 24,
                          height: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// STATUS KONDISI KOLAM
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: getKolamColor(kondisiKolam),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/LOGO4.png", width: 38, height: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Kondisi Kolam: ${kondisiKolam.toUpperCase()}",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEFF2F7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// TOMBOL ANALISIS MANUAL
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _fetchPrediction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3558A8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              dataBuffer.length < windowSize
                                  ? "Kumpulkan Data (${dataBuffer.length}/$windowSize)"
                                  : "Mulai Analisis AI",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: Color(0xFF3558A8),
                      ),
                    ),

                  const SizedBox(height: 15),

                  /// BOX REKOMENDASI AI
                  if (rekomendasiAi != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        border: Border.all(color: const Color(0xFFFF0100)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFF0100),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rekomendasiAi!['head'] ?? "Peringatan",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF0100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rekomendasiAi!['title'] ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  /// GRID SENSOR
                  Text(
                    "Data Sensor Terkini",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isTablet ? 2.0 : 1.85,
                    ),
                    children: [
                      _buildSensorCard(
                        "Suhu Air",
                        "${_fmt(currentTempAir)} °C",
                        "assets/icons/SuhuAir.png",
                        isTablet,
                      ),
                      _buildSensorCard(
                        "Suhu Lingkungan",
                        "${_fmt(currentTempLingkungan)} °C",
                        "assets/icons/SuhuLingkungan.png",
                        isTablet,
                      ),
                      _buildSensorCard(
                        "TDS",
                        "${_fmt(currentTDS)} ppm",
                        "assets/icons/TDS.png",
                        isTablet,
                      ),
                      _buildSensorCard(
                        "pH Air",
                        _fmt(currentPH),
                        "assets/icons/PhAir.png",
                        isTablet,
                      ),
                      _buildSensorCard(
                        "Turbidity",
                        "${_fmt(currentTurbidity)} NTU",
                        "assets/icons/Turbidity.png",
                        isTablet,
                      ),
                      _buildSensorCard(
                        "DO",
                        "${_fmt(currentDO)} mg/L",
                        "assets/icons/DO.png",
                        isTablet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// STOK PAKAN
                  Text(
                    "Ketersediaan Pakan",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: getStokColor(stokPakan),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/LOGO4.png", width: 36, height: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Sisa Stok Pakan: $stokPakan%",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEFF2F7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    String value,
    String iconPath,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
