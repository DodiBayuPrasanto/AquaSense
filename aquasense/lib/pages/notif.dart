import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({super.key});

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  List<Map<String, String>> notifList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationData();
  }

  // Fungsi untuk mengambil data dari SharedPreferences
  Future<void> _loadNotificationData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil data yang disimpan oleh HomePage
    bool isAnomaly = prefs.getBool('is_anomaly') ?? false;
    String? head = prefs.getString('anomaly_head');
    String? title = prefs.getString('anomaly_title');
    String? timeStr = prefs.getString('last_analysis_time');

    List<Map<String, String>> loadedNotifs = [];

    // Jika ada data anomali, masukkan ke dalam list
    if (isAnomaly && head != null && title != null) {
      loadedNotifs.add({
        "title": head,
        "subtitle": title,
        "time": _formatTime(timeStr),
      });
    }

    setState(() {
      notifList = loadedNotifs;
      isLoading = false;
    });
  }

  // Helper untuk mengubah ISO String menjadi format waktu yang enak dibaca
  String _formatTime(String? isoString) {
    if (isoString == null) return "Baru saja";
    DateTime notifTime = DateTime.parse(isoString);
    DateTime now = DateTime.now();
    Duration diff = now.difference(notifTime);

    if (diff.inMinutes < 1) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} Menit yang lalu";
    if (diff.inHours < 24) return "${diff.inHours} Jam yang lalu";
    return "${notifTime.day}/${notifTime.month}/${notifTime.year}";
  }

  @override
  Widget build(BuildContext context) {
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : notifList.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notifList.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: Colors.black12, thickness: 1),
                        itemBuilder: (context, index) {
                          final item = notifList[index];

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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                      Text(
                                        item["title"] ?? "",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18, // Ukuran disesuaikan agar proporsional
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
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

  // Tampilan jika tidak ada notifikasi (Kondisi Kolam Aman)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Tidak Ada Peringatan",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "Kondisi kolam Anda saat ini normal.",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}