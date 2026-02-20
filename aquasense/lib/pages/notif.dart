import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifPage extends StatelessWidget {
  const NotifPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifs = [
      {
        "title": "Suhu Air Mencapai Batas Wajar",
        "subtitle":
            "Tutup kolam dengan paranet agar suhu kolam stabil kembali.",
        "time": "7 Menit yang lalu",
      },
      {
        "title": "pH Air Kolam Dalam Kondisi yang Tidak Normal",
        "subtitle":
            "Membuang 30-50% air dan mengisinya dengan air baru, memberikan kapur dolomit/batu kapur (pH rendah) atau tawas (pH tinggi).",
        "time": "7 Menit yang lalu",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset("assets/icons/Back.png", width: 24, height: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifikasi",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 18),

          Container(
            height: 6,
            width: double.infinity,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifs.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.black12, thickness: 1),
              itemBuilder: (context, index) {
                final item = notifs[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/icons/Pesan.png",
                        width: 25,
                        height: 25,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header kecil + waktu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Peringatan",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  item["time"] ?? "",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Judul
                            Text(
                              item["title"] ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Subtitle
                            Text(
                              item["subtitle"] ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                                color: const Color(0xFF414247),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
