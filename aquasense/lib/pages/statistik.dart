import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'notif.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    final horizontalPadding = isTablet ? 48.0 : 16.0;
    bool hasNotif = true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, Dodi Bayu Prasanto",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D2625),
                        ),
                      ),
                      Text(
                        "09 September 2025",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF97A09F),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotifPage()),
                      );
                    },
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

              /// ================= CARD CHART =================
              const _ChartCard(),

              const SizedBox(height: 12),

              /// ================= TEMPAT PAKAN =================
              Text(
                "Kontrol Pemberian Pakan",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // Interactive control: toggles open/close and on/off icons
              const TempatPakanControl(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatefulWidget {
  const _ChartCard({super.key});

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  bool isPressed = false;
  String selectedDay = "7 Hari";
  String selectedSensor = "Suhu Air";

  // Mapping satuan untuk setiap sensor
  final Map<String, String> sensorUnits = {
    "Suhu Air": "°C",
    "Suhu Lingkungan": "°C",
    "TDS": "ppm",
    "pH Air": "",
    "Turbidity": "NTU",
    "Dissolved Oxygen": "mg/L",
  };

  // Mapping range maksimal untuk setiap sensor
  final Map<String, double> sensorMaxValues = {
    "Suhu Air": 100,
    "Suhu Lingkungan": 50,
    "TDS": 200,
    "pH Air": 10, // Diperbaiki: range pH 4–10
    "Turbidity": 10,
    "Dissolved Oxygen": 15,
  };

  // Mapping range minimal untuk setiap sensor
  final Map<String, double> sensorMinValues = {
    "Suhu Air": 0,
    "Suhu Lingkungan": 0,
    "TDS": 0,
    "pH Air": 4, // Diperbaiki: pH dimulai dari 4 agar grafik tidak gepeng
    "Turbidity": 0,
    "Dissolved Oxygen": 0,
  };

  // Mapping interval Y-axis per sensor agar label rapi
  final Map<String, double> sensorIntervals = {
    "Suhu Air": 20,
    "Suhu Lingkungan": 10,
    "TDS": 40,
    "pH Air": 1, // Diperbaiki: interval 1 unit pH
    "Turbidity": 2,
    "Dissolved Oxygen": 3,
  };

  // Fungsi untuk generate data lengkap dari pola dasar
  // Menerima parameter variation dan clamp agar data pH tidak rusak
  static List<fl_chart.FlSpot> _generateFullData(
    List<fl_chart.FlSpot> basePattern,
    int totalDays, {
    double variation = 2.0,
    double minClamp = 0,
    double maxClamp = double.infinity,
  }) {
    List<fl_chart.FlSpot> fullData = [];
    int patternLength = basePattern.length;
    for (int i = 0; i < totalDays; i++) {
      int patternIndex = i % patternLength;
      double value = basePattern[patternIndex].y;
      // Variasi proporsional: variation/2 ke atas/bawah
      value += (i % 5 - 2) * (variation / 2);
      value = value.clamp(minClamp, maxClamp);
      fullData.add(fl_chart.FlSpot(i.toDouble(), value));
    }
    return fullData;
  }

  // Data dummy suhu air - °C
  static final List<fl_chart.FlSpot> suhuAirBase = [
    fl_chart.FlSpot(0, 72),
    fl_chart.FlSpot(1, 75),
    fl_chart.FlSpot(2, 65),
    fl_chart.FlSpot(3, 68),
    fl_chart.FlSpot(4, 60),
    fl_chart.FlSpot(5, 75),
    fl_chart.FlSpot(6, 50),
    fl_chart.FlSpot(7, 70),
    fl_chart.FlSpot(8, 68),
    fl_chart.FlSpot(9, 72),
    fl_chart.FlSpot(10, 65),
    fl_chart.FlSpot(11, 80),
    fl_chart.FlSpot(12, 75),
    fl_chart.FlSpot(13, 78),
    fl_chart.FlSpot(14, 70),
    fl_chart.FlSpot(15, 73),
    fl_chart.FlSpot(16, 76),
    fl_chart.FlSpot(17, 72),
    fl_chart.FlSpot(18, 74),
    fl_chart.FlSpot(19, 69),
    fl_chart.FlSpot(20, 71),
    fl_chart.FlSpot(21, 68),
    fl_chart.FlSpot(22, 77),
    fl_chart.FlSpot(23, 75),
    fl_chart.FlSpot(24, 73),
    fl_chart.FlSpot(25, 79),
    fl_chart.FlSpot(26, 72),
    fl_chart.FlSpot(27, 74),
  ];

  static final List<fl_chart.FlSpot> suhuAirData = _generateFullData(
    suhuAirBase,
    364,
    variation: 4.0,
    minClamp: 0,
    maxClamp: 100,
  );

  // Data dummy suhu lingkungan - °C
  static final List<fl_chart.FlSpot> suhuLingkunganBase = [
    fl_chart.FlSpot(0, 25),
    fl_chart.FlSpot(1, 26),
    fl_chart.FlSpot(2, 24),
    fl_chart.FlSpot(3, 27),
    fl_chart.FlSpot(4, 23),
    fl_chart.FlSpot(5, 28),
    fl_chart.FlSpot(6, 22),
    fl_chart.FlSpot(7, 26),
    fl_chart.FlSpot(8, 25),
    fl_chart.FlSpot(9, 27),
    fl_chart.FlSpot(10, 24),
    fl_chart.FlSpot(11, 29),
    fl_chart.FlSpot(12, 26),
    fl_chart.FlSpot(13, 28),
    fl_chart.FlSpot(14, 25),
    fl_chart.FlSpot(15, 27),
    fl_chart.FlSpot(16, 26),
    fl_chart.FlSpot(17, 24),
    fl_chart.FlSpot(18, 28),
    fl_chart.FlSpot(19, 23),
    fl_chart.FlSpot(20, 27),
    fl_chart.FlSpot(21, 25),
    fl_chart.FlSpot(22, 29),
    fl_chart.FlSpot(23, 26),
    fl_chart.FlSpot(24, 24),
    fl_chart.FlSpot(25, 30),
    fl_chart.FlSpot(26, 25),
    fl_chart.FlSpot(27, 27),
  ];

  static final List<fl_chart.FlSpot> suhuLingkunganData = _generateFullData(
    suhuLingkunganBase,
    364,
    variation: 4.0,
    minClamp: 0,
    maxClamp: 50,
  );

  // Data dummy TDS - ppm
  static final List<fl_chart.FlSpot> tdsBase = [
    fl_chart.FlSpot(0, 150),
    fl_chart.FlSpot(1, 160),
    fl_chart.FlSpot(2, 140),
    fl_chart.FlSpot(3, 170),
    fl_chart.FlSpot(4, 130),
    fl_chart.FlSpot(5, 180),
    fl_chart.FlSpot(6, 120),
    fl_chart.FlSpot(7, 155),
    fl_chart.FlSpot(8, 165),
    fl_chart.FlSpot(9, 145),
    fl_chart.FlSpot(10, 175),
    fl_chart.FlSpot(11, 135),
    fl_chart.FlSpot(12, 185),
    fl_chart.FlSpot(13, 125),
    fl_chart.FlSpot(14, 158),
    fl_chart.FlSpot(15, 168),
    fl_chart.FlSpot(16, 148),
    fl_chart.FlSpot(17, 178),
    fl_chart.FlSpot(18, 138),
    fl_chart.FlSpot(19, 188),
    fl_chart.FlSpot(20, 128),
    fl_chart.FlSpot(21, 152),
    fl_chart.FlSpot(22, 162),
    fl_chart.FlSpot(23, 142),
    fl_chart.FlSpot(24, 172),
    fl_chart.FlSpot(25, 132),
    fl_chart.FlSpot(26, 182),
    fl_chart.FlSpot(27, 122),
  ];

  static final List<fl_chart.FlSpot> tdsData = _generateFullData(
    tdsBase,
    364,
    variation: 4.0,
    minClamp: 0,
    maxClamp: 200,
  );

  // Data dummy pH - range 4–10 (fokus area 6.5–8.0)
  static final List<fl_chart.FlSpot> phBase = [
    fl_chart.FlSpot(0, 7.2),
    fl_chart.FlSpot(1, 7.5),
    fl_chart.FlSpot(2, 6.8),
    fl_chart.FlSpot(3, 7.1),
    fl_chart.FlSpot(4, 6.9),
    fl_chart.FlSpot(5, 7.4),
    fl_chart.FlSpot(6, 6.7),
    fl_chart.FlSpot(7, 7.3),
    fl_chart.FlSpot(8, 7.0),
    fl_chart.FlSpot(9, 7.6),
    fl_chart.FlSpot(10, 6.8),
    fl_chart.FlSpot(11, 7.2),
    fl_chart.FlSpot(12, 7.1),
    fl_chart.FlSpot(13, 7.5),
    fl_chart.FlSpot(14, 6.9),
    fl_chart.FlSpot(15, 7.4),
    fl_chart.FlSpot(16, 7.0),
    fl_chart.FlSpot(17, 7.3),
    fl_chart.FlSpot(18, 6.8),
    fl_chart.FlSpot(19, 7.6),
    fl_chart.FlSpot(20, 7.1),
    fl_chart.FlSpot(21, 7.2),
    fl_chart.FlSpot(22, 7.5),
    fl_chart.FlSpot(23, 6.9),
    fl_chart.FlSpot(24, 7.4),
    fl_chart.FlSpot(25, 7.0),
    fl_chart.FlSpot(26, 7.3),
    fl_chart.FlSpot(27, 6.8),
  ];

  // Diperbaiki: variasi kecil (0.4) dan clamp 4–10 agar data pH akurat
  static final List<fl_chart.FlSpot> phData = _generateFullData(
    phBase,
    364,
    variation: 0.4,
    minClamp: 4,
    maxClamp: 10,
  );

  // Data dummy Turbidity - NTU
  static final List<fl_chart.FlSpot> turbidityBase = [
    fl_chart.FlSpot(0, 5.2),
    fl_chart.FlSpot(1, 4.8),
    fl_chart.FlSpot(2, 6.1),
    fl_chart.FlSpot(3, 5.5),
    fl_chart.FlSpot(4, 4.9),
    fl_chart.FlSpot(5, 6.3),
    fl_chart.FlSpot(6, 5.0),
    fl_chart.FlSpot(7, 5.7),
    fl_chart.FlSpot(8, 4.6),
    fl_chart.FlSpot(9, 6.0),
    fl_chart.FlSpot(10, 5.3),
    fl_chart.FlSpot(11, 5.8),
    fl_chart.FlSpot(12, 4.7),
    fl_chart.FlSpot(13, 6.2),
    fl_chart.FlSpot(14, 5.1),
    fl_chart.FlSpot(15, 5.9),
    fl_chart.FlSpot(16, 4.8),
    fl_chart.FlSpot(17, 6.1),
    fl_chart.FlSpot(18, 5.4),
    fl_chart.FlSpot(19, 5.6),
    fl_chart.FlSpot(20, 4.9),
    fl_chart.FlSpot(21, 6.0),
    fl_chart.FlSpot(22, 5.2),
    fl_chart.FlSpot(23, 5.7),
    fl_chart.FlSpot(24, 4.6),
    fl_chart.FlSpot(25, 6.3),
    fl_chart.FlSpot(26, 5.0),
    fl_chart.FlSpot(27, 5.8),
  ];

  static final List<fl_chart.FlSpot> turbidityData = _generateFullData(
    turbidityBase,
    364,
    variation: 2.0,
    minClamp: 0,
    maxClamp: 10,
  );

  // Data dummy Dissolved Oxygen - mg/L
  static final List<fl_chart.FlSpot> doBase = [
    fl_chart.FlSpot(0, 8.5),
    fl_chart.FlSpot(1, 8.2),
    fl_chart.FlSpot(2, 9.1),
    fl_chart.FlSpot(3, 8.8),
    fl_chart.FlSpot(4, 8.0),
    fl_chart.FlSpot(5, 9.3),
    fl_chart.FlSpot(6, 7.9),
    fl_chart.FlSpot(7, 8.7),
    fl_chart.FlSpot(8, 8.4),
    fl_chart.FlSpot(9, 9.0),
    fl_chart.FlSpot(10, 8.1),
    fl_chart.FlSpot(11, 8.9),
    fl_chart.FlSpot(12, 8.3),
    fl_chart.FlSpot(13, 9.2),
    fl_chart.FlSpot(14, 8.0),
    fl_chart.FlSpot(15, 8.6),
    fl_chart.FlSpot(16, 8.5),
    fl_chart.FlSpot(17, 9.1),
    fl_chart.FlSpot(18, 8.2),
    fl_chart.FlSpot(19, 8.8),
    fl_chart.FlSpot(20, 8.4),
    fl_chart.FlSpot(21, 9.0),
    fl_chart.FlSpot(22, 8.1),
    fl_chart.FlSpot(23, 8.7),
    fl_chart.FlSpot(24, 8.3),
    fl_chart.FlSpot(25, 9.2),
    fl_chart.FlSpot(26, 8.0),
    fl_chart.FlSpot(27, 8.6),
  ];

  static final List<fl_chart.FlSpot> doData = _generateFullData(
    doBase,
    364,
    variation: 2.0,
    minClamp: 0,
    maxClamp: 15,
  );

  // Map data sensor
  late final Map<String, List<fl_chart.FlSpot>> sensorDataMap = {
    "Suhu Air": suhuAirData,
    "Suhu Lingkungan": suhuLingkunganData,
    "TDS": tdsData,
    "pH Air": phData,
    "Turbidity": turbidityData,
    "Dissolved Oxygen": doData,
  };

  // Chart data menggunakan slice dari data sensor yang dipilih
  Map<String, List<fl_chart.FlSpot>> get chartDataMap {
    final selectedSensorData = sensorDataMap[selectedSensor] ?? suhuAirData;
    return {
      "7 Hari": selectedSensorData.sublist(0, 7),
      "1 Bulan": selectedSensorData.sublist(0, 28),
      "3 Bulan": selectedSensorData.sublist(0, 91),
      "6 Bulan": selectedSensorData.sublist(0, 182),
      "1 Tahun": selectedSensorData,
    };
  }

  List<fl_chart.FlSpot> getChartData() {
    return chartDataMap[selectedDay] ?? chartDataMap["7 Hari"]!;
  }

  void selectDay(String day) {
    setState(() {
      selectedDay = day;
    });
  }

  void selectSensor(String sensor) {
    setState(() {
      selectedSensor = sensor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double minY = sensorMinValues[selectedSensor] ?? 0;
    final double maxY = sensorMaxValues[selectedSensor] ?? 100;
    final double interval =
        sensorIntervals[selectedSensor] ?? ((maxY - minY) / 5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E4E4),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== CHART =====
          GestureDetector(
            onTapDown: (_) => setState(() => isPressed = true),
            onTapUp: (_) => setState(() => isPressed = false),
            onTapCancel: () => setState(() => isPressed = false),
            onPanStart: (_) => setState(() => isPressed = true),
            onPanUpdate: (_) => setState(() => isPressed = true),
            onPanEnd: (_) => setState(() => isPressed = false),
            child: SizedBox(
              height: 260,
              child: fl_chart.LineChart(
                fl_chart.LineChartData(
                  minY: minY, // Diperbaiki: dinamis per sensor
                  maxY: maxY, // Diperbaiki: dinamis per sensor
                  gridData: const fl_chart.FlGridData(show: false),
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
                        interval: interval, // Diperbaiki: interval dinamis
                        reservedSize: 54,
                        getTitlesWidget: (value, meta) {
                          final unit = sensorUnits[selectedSensor] ?? "";
                          // pH ditampilkan 1 desimal, sensor lain integer
                          final displayValue = selectedSensor == "pH Air"
                              ? value.toStringAsFixed(1)
                              : value.toInt().toString();
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              "$displayValue $unit",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF6E6E6E),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: fl_chart.LineTouchData(
                    touchTooltipData: fl_chart.LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.white,
                      tooltipBorder: const BorderSide(
                        color: Color(0xFFE4E4E4),
                        width: 1,
                      ),
                      // tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      getTooltipItems:
                          (List<fl_chart.LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final unit = sensorUnits[selectedSensor] ?? "";
                              final displayValue = selectedSensor == "pH Air"
                                  ? barSpot.y.toStringAsFixed(2)
                                  : barSpot.y.toStringAsFixed(1);
                              return fl_chart.LineTooltipItem(
                                "$displayValue $unit".trim(),
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
                      curveSmoothness: 0.35,
                      color: const Color(0xFF3558A8),
                      barWidth: 2.5,
                      belowBarData: fl_chart.BarAreaData(
                        show: true,
                        color: const Color(0xFF3558A8).withOpacity(0.35),
                      ),
                      dotData: fl_chart.FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          if (index == getChartData().length - 1) {
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
                      spots: getChartData(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// ===== FILTER HARI =====
          Row(
            children: [
              _dayButton(
                "7 Hari",
                selectedDay == "7 Hari",
                () => selectDay("7 Hari"),
              ),
              const SizedBox(width: 5),
              _dayButton(
                "1 Bulan",
                selectedDay == "1 Bulan",
                () => selectDay("1 Bulan"),
              ),
              const SizedBox(width: 5),
              _dayButton(
                "3 Bulan",
                selectedDay == "3 Bulan",
                () => selectDay("3 Bulan"),
              ),
              const SizedBox(width: 5),
              _dayButton(
                "6 Bulan",
                selectedDay == "6 Bulan",
                () => selectDay("6 Bulan"),
              ),
              const SizedBox(width: 5),
              _dayButton(
                "1 Tahun",
                selectedDay == "1 Tahun",
                () => selectDay("1 Tahun"),
              ),
            ],
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
      onTap: () => selectSensor(text),
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

class TempatPakanControl extends StatefulWidget {
  const TempatPakanControl({super.key});

  @override
  State<TempatPakanControl> createState() => _TempatPakanControlState();
}

class _TempatPakanControlState extends State<TempatPakanControl> {
  // true = buka, false = tutup
  bool isOpen = false;
  // true = on, false = off
  bool isOn = false;

  void _toggleOpen() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  void _togglePower() {
    setState(() {
      isOn = !isOn;
      // When powering on, mark the dispenser as open and show green label.
      if (isOn) {
        isOpen = true;
      } else {
        isOpen = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = isOpen ? 'Buka' : 'Tutup';
    final leftIcon = isOpen
        ? 'assets/icons/bukaPakan.png'
        : 'assets/icons/tutupPakan.png';
    final rightIcon = isOn
        ? 'assets/icons/onPakan.png'
        : 'assets/icons/offPakan.png';

    return Container(
      width: 333,
      height: 85,
      padding: const EdgeInsets.fromLTRB(16, 23, 16, 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _toggleOpen,
            child: Row(
              children: [
                Image.asset(leftIcon, width: 33, height: 34),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tempat Pakan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isOpen ? const Color(0xFF52B888) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Power icon on the right; clicking toggles on/off
          GestureDetector(
            onTap: _togglePower,
            child: Image.asset(
              rightIcon,
              width: 46,
              height: 46,
              errorBuilder: (context, error, stackTrace) => Icon(
                isOn ? Icons.power : Icons.power_off,
                size: 28,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
