import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'notif.dart';
import 'notif_state.dart';

// --- MODEL DATA ---
class SensorData {
  final double dissolvedOxygen;
  final double phAir;
  final double suhuAir;
  final double suhuLingkungan;
  final double tds;
  final double turbidity;
  final DateTime updatedAt;

  SensorData({
    required this.dissolvedOxygen,
    required this.phAir,
    required this.suhuAir,
    required this.suhuLingkungan,
    required this.tds,
    required this.turbidity,
    required this.updatedAt,
  });

  factory SensorData.fromFirestore(Map<String, dynamic> json) {
    return SensorData(
      dissolvedOxygen: (json['dissolved_oxygen'] ?? 0).toDouble(),
      phAir: (json['pH_air'] ?? 0).toDouble(),
      suhuAir: (json['suhu_air'] ?? 0).toDouble(),
      suhuLingkungan: (json['suhu_lingkungan'] ?? 0).toDouble(),
      tds: (json['tds'] ?? 0).toDouble(),
      turbidity: (json['turbidity'] ?? 0).toDouble(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}

// =====================================================================
// STATISTIK PAGE
// =====================================================================
class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  @override
  void initState() {
    super.initState();
    // Pastikan notifier sudah terisi saat halaman dibuka
    NotifState.reload();
  }

  Future<void> _openNotifPage() async {
    await NotifState.markOpened();

    if (mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotifPage()));
      await NotifState.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    final horizontalPadding = isTablet ? 48.0 : 16.0;

    final Stream<QuerySnapshot> sensorStream =
        FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'aquasense',
            )
            .collection('sensor_data')
            .orderBy('updatedAt', descending: true)
            .limit(365)
            .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: sensorStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<SensorData> historyData = snapshot.data!.docs
                .map(
                  (doc) => SensorData.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList()
                .reversed
                .toList();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ================= HEADER =================
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
                      // Icon notif reaktif via ValueListenableBuilder
                      ValueListenableBuilder<bool>(
                        valueListenable: NotifState.hasNotif,
                        builder: (context, hasNotif, _) {
                          return GestureDetector(
                            onTap: _openNotifPage,
                            child: Image.asset(
                              hasNotif
                                  ? "assets/icons/Notif_On.png"
                                  : "assets/icons/Notif_Off.png",
                              width: 24,
                              height: 28,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ================= CARD CHART =================
                  _ChartCard(historyData: historyData),

                  const SizedBox(height: 12),

                  // ================= TEMPAT PAKAN =================
                  Text(
                    "Kontrol Pemberian Pakan",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const TempatPakanControl(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =====================================================================
// CHART CARD — tidak ada perubahan sama sekali dari kode asli
// =====================================================================
class _ChartCard extends StatefulWidget {
  final List<SensorData> historyData;
  const _ChartCard({required this.historyData});

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  String selectedDay = "7 Hari";
  String selectedSensor = "Suhu Air";

  final Map<String, String> sensorUnits = {
    "Suhu Air": "°C",
    "Suhu Lingkungan": "°C",
    "TDS": "ppm",
    "pH Air": "",
    "Turbidity": "NTU",
    "Dissolved Oxygen": "mg/L",
  };

  List<SensorData> _getFilteredData() {
    final now = DateTime.now();
    int days;
    switch (selectedDay) {
      case "7 Hari":
        days = 7;
        break;
      case "1 Bulan":
        days = 30;
        break;
      case "3 Bulan":
        days = 90;
        break;
      case "6 Bulan":
        days = 180;
        break;
      case "1 Tahun":
        days = 365;
        break;
      default:
        days = 7;
    }
    final cutoff = now.subtract(Duration(days: days));
    return widget.historyData
        .where((d) => d.updatedAt.isAfter(cutoff))
        .toList();
  }

  List<double> _movingAverage(List<double> data, int window) {
    if (data.length <= window) return data;
    final half = window ~/ 2;
    List<double> result = [];
    for (int i = 0; i < data.length; i++) {
      final start = (i - half).clamp(0, data.length - 1);
      final end = (i + half).clamp(0, data.length - 1);
      double sum = 0;
      for (int j = start; j <= end; j++) {
        sum += data[j];
      }
      result.add(sum / (end - start + 1));
    }
    return result;
  }

  List<double> _downsample(List<double> data, int maxPoints) {
    if (data.length <= maxPoints) return data;
    final step = data.length / maxPoints;
    return List.generate(
      maxPoints,
      (i) => data[(i * step).round().clamp(0, data.length - 1)],
    );
  }

  List<fl_chart.FlSpot> _getSpots() {
    final dataSlice = _getFilteredData();
    if (dataSlice.isEmpty) return [const fl_chart.FlSpot(0, 0)];

    List<double> yValues = dataSlice.map((data) {
      switch (selectedSensor) {
        case "Suhu Air":
          return data.suhuAir;
        case "Suhu Lingkungan":
          return data.suhuLingkungan;
        case "TDS":
          return data.tds;
        case "pH Air":
          return data.phAir;
        case "Turbidity":
          return data.turbidity;
        case "Dissolved Oxygen":
          return data.dissolvedOxygen;
        default:
          return 0.0;
      }
    }).toList();

    int window;
    if (yValues.length > 200) {
      window = 25;
    } else if (yValues.length > 100) {
      window = 15;
    } else if (yValues.length > 50) {
      window = 9;
    } else if (yValues.length > 20) {
      window = 5;
    } else {
      window = 3;
    }
    List<double> smoothY = _movingAverage(yValues, window);

    const int maxPoints = 50;
    List<double> downsampled = _downsample(smoothY, maxPoints);
    List<double> finalSmooth = _movingAverage(downsampled, 5);

    return List.generate(
      finalSmooth.length,
      (i) => fl_chart.FlSpot(i.toDouble(), finalSmooth[i]),
    );
  }

  double _getMinY(List<fl_chart.FlSpot> spots) {
    if (spots.isEmpty) return 0;
    final min = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final max = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (max - min) * 0.2;
    return (min - padding).clamp(0, double.infinity);
  }

  double _getMaxY(List<fl_chart.FlSpot> spots) {
    if (spots.isEmpty) return 10;
    final min = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final max = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (max - min) * 0.2;
    return max + padding;
  }

  double _calculateOptimalInterval(double minY, double maxY) {
    double range = maxY - minY;
    if (range <= 0) return 1.0;
    double rawInterval = range / 4.0;
    double magnitude = pow(
      10.0,
      (log(rawInterval) / ln10).floorToDouble(),
    ).toDouble();
    double normalized = rawInterval / magnitude;
    if (normalized <= 1.0) return magnitude;
    if (normalized <= 2.0) return magnitude * 2;
    if (normalized <= 2.5) return magnitude * 2.5;
    if (normalized <= 5.0) return magnitude * 5;
    return magnitude * 10;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getSpots();
    final rawMinY = _getMinY(spots);
    final rawMaxY = _getMaxY(spots);
    final interval = _calculateOptimalInterval(rawMinY, rawMaxY);
    var minY = (rawMinY / interval).floorToDouble() * interval;
    var maxY = minY + interval * 4;

    final dataMax = spots.isEmpty
        ? 0.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (dataMax > maxY) {
      final stepsNeeded = ((dataMax - minY) / interval).ceilToDouble();
      minY = minY + (stepsNeeded - 4) * interval;
      maxY = minY + interval * 4;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 260,
            child: fl_chart.LineChart(
              fl_chart.LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: fl_chart.FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => const fl_chart.FlLine(
                    color: Color(0xFFF0F0F0),
                    strokeWidth: 1,
                  ),
                ),
                borderData: fl_chart.FlBorderData(show: false),
                titlesData: fl_chart.FlTitlesData(
                  topTitles: const fl_chart.AxisTitles(
                    sideTitles: fl_chart.SideTitles(showTitles: false),
                  ),
                  bottomTitles: const fl_chart.AxisTitles(
                    sideTitles: fl_chart.SideTitles(showTitles: false),
                  ),
                  leftTitles: const fl_chart.AxisTitles(
                    sideTitles: fl_chart.SideTitles(showTitles: false),
                  ),
                  rightTitles: fl_chart.AxisTitles(
                    sideTitles: fl_chart.SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        final unit = sensorUnits[selectedSensor] ?? "";
                        final epsilon = interval * 0.01;
                        final relPos = (value - minY) / interval;
                        final isOn =
                            (relPos - relPos.roundToDouble()).abs() < epsilon ||
                            (value - minY).abs() < epsilon ||
                            (value - maxY).abs() < epsilon;
                        if (!isOn) return const SizedBox.shrink();

                        String dv;
                        if (value == value.toInt()) {
                          dv = value.toInt().toString();
                        } else if (interval < 1) {
                          dv = value
                              .toStringAsFixed(2)
                              .replaceAll(RegExp(r'0+$'), '')
                              .replaceAll(RegExp(r'\.$'), '');
                        } else if (interval < 5) {
                          dv = value
                              .toStringAsFixed(1)
                              .replaceAll(RegExp(r'0+$'), '')
                              .replaceAll(RegExp(r'\.$'), '');
                        } else {
                          dv = value.toInt().toString();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            "$dv $unit".trim(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF6E6E6E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: fl_chart.LineTouchData(
                  touchTooltipData: fl_chart.LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    tooltipBorder: const BorderSide(
                      color: Color(0xFFE4E4E4),
                      width: 1,
                    ),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipItems: (touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final unit = sensorUnits[selectedSensor] ?? "";
                        final dv = selectedSensor == "pH Air"
                            ? barSpot.y.toStringAsFixed(2)
                            : barSpot.y.toStringAsFixed(1);
                        return fl_chart.LineTooltipItem(
                          "$dv $unit".trim(),
                          GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  fl_chart.LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.5,
                    preventCurveOverShooting: true,
                    color: const Color(0xFF3558A8),
                    barWidth: 2.5,
                    belowBarData: fl_chart.BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF3558A8).withOpacity(0.30),
                          const Color(0xFF3558A8).withOpacity(0.02),
                        ],
                      ),
                    ),
                    dotData: fl_chart.FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (spots.isNotEmpty && index == spots.length - 1) {
                          return fl_chart.FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFFE53935),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        }
                        return fl_chart.FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                        );
                      },
                    ),
                    spots: spots,
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 400),
            ),
          ),

          const SizedBox(height: 18),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _dayButton(
                  "7 Hari",
                  selectedDay == "7 Hari",
                  () => setState(() => selectedDay = "7 Hari"),
                ),
                const SizedBox(width: 5),
                _dayButton(
                  "1 Bulan",
                  selectedDay == "1 Bulan",
                  () => setState(() => selectedDay = "1 Bulan"),
                ),
                const SizedBox(width: 5),
                _dayButton(
                  "3 Bulan",
                  selectedDay == "3 Bulan",
                  () => setState(() => selectedDay = "3 Bulan"),
                ),
                const SizedBox(width: 5),
                _dayButton(
                  "6 Bulan",
                  selectedDay == "6 Bulan",
                  () => setState(() => selectedDay = "6 Bulan"),
                ),
                const SizedBox(width: 5),
                _dayButton(
                  "1 Tahun",
                  selectedDay == "1 Tahun",
                  () => setState(() => selectedDay = "1 Tahun"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Grafik Data Sensor",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sensorChip("Suhu Air", selectedSensor == "Suhu Air"),
              _sensorChip(
                "Suhu Lingkungan",
                selectedSensor == "Suhu Lingkungan",
              ),
              _sensorChip("TDS", selectedSensor == "TDS"),
              _sensorChip("pH Air", selectedSensor == "pH Air"),
              _sensorChip("Turbidity", selectedSensor == "Turbidity"),
              _sensorChip(
                "Dissolved Oxygen",
                selectedSensor == "Dissolved Oxygen",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3558A8) : const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _sensorChip(String text, bool active) {
    return GestureDetector(
      onTap: () => setState(() => selectedSensor = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3558A8) : const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// TEMPAT PAKAN CONTROL — tidak ada perubahan sama sekali dari kode asli
// =====================================================================
class TempatPakanControl extends StatefulWidget {
  const TempatPakanControl({super.key});

  @override
  State<TempatPakanControl> createState() => _TempatPakanControlState();
}

class _TempatPakanControlState extends State<TempatPakanControl> {
  bool isOpen = false;
  bool isOn = false;
  bool loading = false;
  String status = '';

  Timer? _statusTimeout;

  late final DocumentReference docRef;
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    docRef = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'aquasense',
    ).collection('servo_control').doc('device_1');

    _subscription = docRef.snapshots().listen(
      (doc) {
        if (!doc.exists || !mounted) return;

        final data = doc.data() as Map<String, dynamic>;
        final s = data['status']?.toString() ?? '';

        setState(() {
          isOpen = (data['command']?.toString() ?? '0') == '1';
          isOn = data['power'] as bool? ?? false;

          if (s == 'completed') {
            status = '✓ Selesai';
            _statusTimeout?.cancel();
          }
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => status = 'Koneksi error');
      },
    );
  }

  @override
  void dispose() {
    _statusTimeout?.cancel();
    _subscription.cancel();
    super.dispose();
  }

  Future<void> send({String? command, bool? power}) async {
    if (loading) return;

    setState(() {
      loading = true;
      status = 'Mengirim...';
    });

    try {
      final Map<String, dynamic> updates = {
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (command != null) updates['command'] = command;
      if (power != null) updates['power'] = power;

      await docRef.set(updates, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        loading = false;
        status = 'Terkirim';
      });

      _statusTimeout?.cancel();
      _statusTimeout = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() => status = '');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        status = 'Gagal terkirim';
      });
    }
  }

  void toggleOpen() {
    if (!isOn || loading) return;
    send(command: isOpen ? '0' : '1');
  }

  void togglePower() {
    if (loading) return;
    if (isOn) {
      send(power: false, command: '0');
    } else {
      send(power: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E4), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: loading ? null : toggleOpen,
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: loading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF3558A8),
                          ),
                        )
                      : Image.asset(
                          key: ValueKey('icon_$isOpen'),
                          !isOn
                              ? "assets/icons/offPakan.png"
                              : isOpen
                              ? "assets/icons/bukaPakan.png"
                              : "assets/icons/tutupPakan.png",
                          width: 28,
                          height: 28,
                        ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tempat Pakan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D2625),
                      ),
                    ),
                    Text(
                      isOn ? (isOpen ? 'Terbuka' : 'Tertutup') : 'Nonaktif',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isOn
                            ? (isOpen
                                  ? const Color(0xFF3558A8)
                                  : const Color(0xFF97A09F))
                            : Colors.grey.shade400,
                      ),
                    ),
                    if (status.isNotEmpty)
                      Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: status.contains('✓')
                              ? Colors.green
                              : status.contains('Gagal') ||
                                    status.contains('error')
                              ? Colors.red
                              : const Color(0xFF97A09F),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: loading ? null : togglePower,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOn
                    ? const Color(0xFF3558A8).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                isOn ? "assets/icons/onPakan.png" : "assets/icons/offPakan.png",
                width: 28,
                height: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
