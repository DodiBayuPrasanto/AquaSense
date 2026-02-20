import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notif.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    final horizontalPadding = isTablet ? 48.0 : 16.0;
    final sensorCardWidth = isTablet ? 220.0 : 158.0;
    final sensorCardHeight = isTablet ? 110.0 : 85.0;

    bool hasNotif = true;
    int stokPakan = 10;
    String kondisiKolam = "baik";

    // Warna stok pakan
    Color getStokColor(int persen) {
      if (persen > 60) return const Color(0xFF52B888);
      if (persen > 25) return const Color(0xFFFFC63D);
      return const Color(0xFFFF0100);
    }

    // Warna kondisi kolam
    Color getKolamColor(String kondisi) {
      switch (kondisi.toLowerCase()) {
        case "baik":
          return const Color(0xFF52B888);
        case "kurang":
          return const Color(0xFFFFC63D);
        case "buruk":
          return const Color(0xFFFF0100);
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // ===== HEADER (Tanpa Avatar) =====
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

                            // Notifikasi
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NotifPage(),
                                  ),
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

                        // ===== KONDISI KOLAM =====
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: getKolamColor(kondisiKolam),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/Logo4.png",
                                width: 38,
                                height: 40,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Kolam Dalam Kondisi ${kondisiKolam[0].toUpperCase()}${kondisiKolam.substring(1)}",
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

                        // ===== DATA SENSOR =====
                        Text(
                          "Data Sensor Kolam",
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),

                        Wrap(
                          spacing: isTablet ? 24 : 10,
                          runSpacing: isTablet ? 24 : 10,
                          children: [
                            _buildSensorCard(
                              "Suhu Air",
                              "25.9 °C",
                              "assets/icons/SuhuAir.png",
                              sensorCardWidth,
                              sensorCardHeight,
                              isTablet,
                            ),
                            _buildSensorCard(
                              "Suhu Lingkungan",
                              "26.6 °C",
                              "assets/icons/SuhuLingkungan.png",
                              sensorCardWidth,
                              sensorCardHeight,
                              isTablet,
                            ),
                            _buildSensorCard(
                              "TDS",
                              "631 ppm",
                              "assets/icons/TDS.png",
                              sensorCardWidth,
                              sensorCardHeight,
                              isTablet,
                            ),
                            _buildSensorCard(
                              "pH Air",
                              "6.93",
                              "assets/icons/PhAir.png",
                              sensorCardWidth,
                              sensorCardHeight,
                              isTablet,
                            ),
                            _buildSensorCard(
                              "Turbidity",
                              "631 NTU",
                              "assets/icons/Turbidity.png",
                              sensorCardWidth,
                              sensorCardHeight,
                              isTablet,
                            ),
                            _buildSensorCard(
                              "DO",
                              "6 mg/L",
                              "assets/icons/DO.png",
                              sensorCardWidth,
                              sensorCardHeight,
                              isTablet,
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // ===== STOK PAKAN =====
                        Text(
                          "Stok Pakan",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(35),
                          decoration: BoxDecoration(
                            color: getStokColor(stokPakan),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/Logo4.png",
                                width: 36,
                                height: 36,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Stok Pakan Tersisa $stokPakan%",
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

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
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
    double width,
    double height,
    bool isTablet,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 18 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 18 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: isTablet ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: isTablet ? 40 : 30,
              height: isTablet ? 40 : 30,
            ),
            SizedBox(width: isTablet ? 16 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 16 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
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
