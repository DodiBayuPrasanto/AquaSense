import 'package:aquasense/service/api_service.dart';
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
  List<Map<String, double>> dataBuffer = [];
  int windowSize = 20;

  bool hasNotif = false;
  String kondisiKolam = "menunggu data...";
  String firestoreStatus = "Connecting...";
  
  Map<String, dynamic>? rekomendasiAi;
  Map<String, dynamic>? featureScores;

  // Data sensor dari Firestore dengan default values
  double currentTempAir = 29.9;
  double currentTempLingkungan = 26.6;
  double currentDO = 7.6;
  double currentTurbidity = 7.9;
  double currentPH = 6.8;
  double currentTDS = 631.0;
  int stokPakan = 10;
  String updatedAt = "Loading...";
  bool isFirestoreLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
  }

  /// Initialize Firestore stream and load initial data
  Future<void> _initializeFirestore() async {
    setState(() => isFirestoreLoading = true);
    print("🔥 [Firestore] Initializing Firebase connection...");
    _listenToFirestoreData();
  }

  /// Listen to real-time updates from Firestore
  void _listenToFirestoreData() {
    print("🔥 [Firestore] Starting stream listener...");
    _apiService.getRealtimeDataStream().listen((data) {
      print("✅ [Firestore] Data received: $data");
      if (mounted) {
        setState(() {
          // Parse data dari Firestore dengan null coalescing
          currentTempAir = (data['suhu_air'] as num?)?.toDouble() ?? 29.9;
          currentTempLingkungan = (data['suhu_lingkungan'] as num?)?.toDouble() ?? 26.6;
          currentDO = (data['dissolved_oxygen'] as num?)?.toDouble() ?? 7.6;
          currentTurbidity = (data['turbidity'] as num?)?.toDouble() ?? 7.9;
          currentPH = (data['pH_air'] as num?)?.toDouble() ?? 6.8;
          currentTDS = (data['tds'] as num?)?.toDouble() ?? 631.0;
          stokPakan = (data['pakan_percent'] as num?)?.toInt() ?? 10;
          updatedAt = data['updatedAt']?.toString() ?? "Unknown";
          isFirestoreLoading = false;
          firestoreStatus = "✅ Connected - Data refreshed";
          
          print("✅ [Firestore] State updated - TempAir: $currentTempAir, DO: $currentDO, TDS: $currentTDS, Pakan: $stokPakan%");
          
          // Tambahkan data ke buffer untuk AI prediction
          _addSensorDataToBuffer();
        });
      }
    }, onError: (error) {
      print("❌ [Firestore] Error occurred: $error");
      if (mounted) {
        setState(() {
          isFirestoreLoading = false;
          firestoreStatus = "❌ Error: $error";
        });
        
        // Show error dialog with options
        _showFirestoreErrorDialog(error.toString());
      }
    });
  }

  /// Show error dialog with options to create test data
  void _showFirestoreErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ Firestore Error"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Masalah:"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Solusi:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "1. Pastikan collection 'realtime_data' dan document 'device_1' sudah dibuat di Firebase\n"
                "2. Atau gunakan tombol di bawah untuk create test data otomatis",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createTestDataInFirestore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("📝 Create Test Data", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Create test data in Firestore automatically
  Future<void> _createTestDataInFirestore() async {
    try {
      setState(() => firestoreStatus = "🔄 Creating test data...");
      await _apiService.createTestData();
      if (mounted) {
        setState(() => firestoreStatus = "✅ Test data created!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Test data berhasil dibuat! Refresh page..."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
        // Retry connection
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _listenToFirestoreData();
          }
        });
      }
    } catch (e) {
      print("❌ Error creating test data: $e");
      if (mounted) {
        setState(() => firestoreStatus = "❌ Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creating data: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Fungsi mengganti skenario testing
  void _setSensorVariant(String variant) {
    setState(() {
      switch (variant) {
        case "NORMAL":
          // Sesuai Mean Metadata (Data yang paling dianggap 'sehat' oleh AI)
          currentTempAir = 29.96; 
          currentDO = 7.61;
          currentTurbidity = 7.92;
          currentPH = 6.80;
          break;

        case "PANAS":
          // Mean 29.96 + (Sigma tinggi). 35.0 akan memicu anomali suhu.
          currentTempAir = 35.0; 
          currentDO = 7.61;
          currentTurbidity = 7.92;
          currentPH = 6.80;
          break;

        case "DO_DROP":
          // Mean 7.61. Turun ke 4.0 akan memicu anomali oksigen.
          currentTempAir = 29.96;
          currentDO = 4.0; 
          currentTurbidity = 7.92;
          currentPH = 6.80;
          break;

        case "KERUH":
          // Mean 7.92. Naik ke 80.0 akan memicu anomali kekeruhan.
          currentTempAir = 29.96;
          currentDO = 7.61;
          currentTurbidity = 80.0; 
          currentPH = 6.80;
          break;

        case "PH_ASAM":
          // Mean 6.80. Turun ke 4.5 akan memicu anomali pH.
          currentTempAir = 29.96;
          currentDO = 7.61;
          currentTurbidity = 7.92;
          currentPH = 4.5; 
          break;
      }
    });


    dataBuffer.clear();


    for (int i = 0; i < windowSize; i++) {
      _addSensorDataToBuffer();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Skenario: $variant dipasang."),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _addSensorDataToBuffer() {
    dataBuffer.add({
      'tempAir': currentTempAir,
      'DO': currentDO,
      'turbidity': currentTurbidity,
      'pH': currentPH,
    });

    if (dataBuffer.length > windowSize) {
      dataBuffer.removeAt(0);
    }
  }

  Future<void> _fetchPrediction() async {
    if (dataBuffer.length < windowSize) return;

    setState(() {
      isLoading = true;
      rekomendasiAi = null;
      featureScores = null;
    });

    try {
      final responseData = await _apiService.checkAnomaly(dataBuffer);

      bool isAnomaly = responseData['is_anomaly'] ?? false;

      // SIMPAN KE SHARED PREFERENCES
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_anomaly', isAnomaly);
      await prefs.setString('last_analysis_time', DateTime.now().toIso8601String());

      if (isAnomaly && responseData['rekomendasi'] != null) {
        await prefs.setString('anomaly_head', responseData['rekomendasi']['head'] ?? 'Peringatan');
        await prefs.setString('anomaly_title', responseData['rekomendasi']['title'] ?? 'Kualitas air buruk.');
        setState(() => hasNotif = true); 
      } else {
        await prefs.remove('anomaly_head');
        await prefs.remove('anomaly_title');
        setState(() => hasNotif = false);
      }

      if (mounted) {
        setState(() {
          kondisiKolam = isAnomaly ? "buruk" : "baik";
          if (isAnomaly) {
            rekomendasiAi = responseData['rekomendasi'];
            featureScores = responseData['feature_scores'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

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

  // Fungsi untuk menampilkan menu testing
  void _showTestMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Skenario Testing AI",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _testListTile("Kondisi Normal", "NORMAL", Icons.check_circle, Colors.green),
              _testListTile("Suhu Panas (Anomali)", "PANAS", Icons.wb_sunny, Colors.orange),
              _testListTile("Kadar Oksigen Drop (Anomali)", "DO_DROP", Icons.air, Colors.blue),
              _testListTile("Air Keruh Parah (Anomali)", "KERUH", Icons.opacity, Colors.brown),
              _testListTile("pH Asam (Anomali)", "PH_ASAM", Icons.science, Colors.purple),
            ],
          ),
        );
      },
    );
  }

  Widget _testListTile(String title, String variant, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      onTap: () {
        _setSensorVariant(variant);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    final horizontalPadding = isTablet ? 48.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      // FLOATING ACTION BUTTON UNTUK TESTING
      floatingActionButton: FloatingActionButton(
        onPressed: _showTestMenu,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, Dodi Bayu Prasanto",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1D2625)),
                        ),
                        Text(
                          "09 September 2025",
                          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF97A09F)),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotifPage())),
                      child: Image.asset(hasNotif ? "assets/icons/Notif_On.png" : "assets/icons/Notif_Off.png", width: 24, height: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // KONDISI KOLAM
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(color: getKolamColor(kondisiKolam), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Image.asset("assets/LOGO4.png", width: 38, height: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Kolam Dalam Kondisi ${kondisiKolam[0].toUpperCase()}${kondisiKolam.substring(1)}",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFFEFF2F7)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // TOMBOL ANALISIS
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () {
                      _addSensorDataToBuffer();
                      _fetchPrediction();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, 
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Kirim Data ke AI Server", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                // REKOMENDASI AI
                if (rekomendasiAi != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), border: Border.all(color: const Color(0xFFFF0100)), borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF0100)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(rekomendasiAi!['head'] ?? "Peringatan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFFFF0100)))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(rekomendasiAi!['title'] ?? "", style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
                        if (featureScores != null && featureScores!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(color: Colors.redAccent, thickness: 1),
                          Text("Penyimpangan Sensor:", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                          ...featureScores!.entries.map((entry) => Text("${entry.key}: ${entry.value.toStringAsFixed(3)}", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54))),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // DATA SENSOR GRID
                Text("Data Sensor Kolam", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2, 
                    crossAxisSpacing: 12, mainAxisSpacing: 12, 
                    childAspectRatio: isTablet ? 2.0 : 1.85, 
                  ),
                  children: [
                    _buildSensorCard("Suhu Air", "${currentTempAir.toStringAsFixed(2)} °C", "assets/icons/SuhuAir.png", isTablet),
                    _buildSensorCard("Suhu Lingkungan", "${currentTempLingkungan.toStringAsFixed(2)} °C", "assets/icons/SuhuLingkungan.png", isTablet),
                    _buildSensorCard("TDS", "${currentTDS.toStringAsFixed(0)} ppm", "assets/icons/TDS.png", isTablet),
                    _buildSensorCard("pH Air", "${currentPH.toStringAsFixed(2)}", "assets/icons/PhAir.png", isTablet),
                    _buildSensorCard("Turbidity", "${currentTurbidity.toStringAsFixed(2)} NTU", "assets/icons/Turbidity.png", isTablet),
                    _buildSensorCard("DO", "${currentDO.toStringAsFixed(2)} mg/L", "assets/icons/DO.png", isTablet),
                  ],
                ),
                const SizedBox(height: 20),
                // STOK PAKAN
                Text("Stok Pakan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(color: getStokColor(stokPakan), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Image.asset("assets/LOGO4.png", width: 36, height: 36),
                      const SizedBox(width: 12),
                      Expanded(child: Text("Stok Pakan Tersisa $stokPakan%", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFFEFF2F7)))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, String iconPath, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Image.asset(iconPath, width: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}