import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F4),
      body: SafeArea(
        child: Column(
          children: [
            /// ===============================
            /// HEADER (BACK MANUAL)
            /// ===============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Row(
                children: [
                  /// BACK ICON MANUAL
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      "assets/icons/Back.png",
                      width: 22,
                      height: 22,
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// TITLE
                  Expanded(
                    child: Center(
                      child: Text(
                        "Tentang Aplikasi",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF414247),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 38),
                ],
              ),
            ),

            /// ===============================
            /// CONTENT
            /// ===============================
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: const BoxDecoration(color: Color(0xFFDDE3E6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// DESKRIPSI UTAMA
                      _bodyText(
                        "Aplikasi Monitoring Bibit Lele merupakan aplikasi yang dirancang untuk membantu pembudidaya ikan lele dalam memantau kondisi kolam dan mengelola pemberian pakan secara efektif. Serta monitoring kolam secara real-time.",
                      ),

                      const SizedBox(height: 20),

                      // _sectionTitle("Halaman Login"),
                      // _bodyText(
                      //   "Halaman Login berfungsi untuk mengakses aplikasi ini, pengguna diminta memasukan email dan password yang sudah dibuat sebelumnya.",
                      // ),

                      const SizedBox(height: 16),

                      // _sectionTitle("Halaman Sign Up"),
                      // _bodyText(
                      //   "Halaman Sign Up disini berfungsi untuk proses pendaftaran pengguna yang belum memiliki akun, pengguna diminta memasukan data pada form sign up untuk disimpan kedalam database.",
                      // ),

                      const SizedBox(height: 16),

                      _sectionTitle("Halaman Home"),
                      _bodyText(
                        "Halaman Home merupakan halaman utama pada aplikasi ini dimana menampilkan kondisi kolam, data sensor kolam dan informasi stok pakan.",
                      ),

                      const SizedBox(height: 16),

                      _sectionTitle("Halaman Statistik"),
                      _bodyText(
                        "Halaman Statistik menampilkan grafik pada data sensor dan dapat dilihat dari 7 hari sampai 1 tahun di setiap data sensor nya. Selain itu, pada halaman ini tersedia fitur kontrol pemberian pakan.",
                      ),

                      const SizedBox(height: 16),

                      _sectionTitle("Halaman Profil"),
                      _bodyText(
                        "Halaman Profil berisi informasi tentang aplikasi.",
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// STYLE TITLE
  /// ===============================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF414247),
        ),
      ),
    );
  }

  /// ===============================
  /// STYLE BODY
  /// ===============================
  Widget _bodyText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        height: 1.6,
        color: const Color(0xFF5F5F5F),
      ),
      textAlign: TextAlign.justify,
    );
  }
}
