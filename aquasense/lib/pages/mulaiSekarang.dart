import 'package:aquasense/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'register.dart';

class MulaiSekarang extends StatelessWidget {
  const MulaiSekarang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), //  background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo kecil di atas kiri
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  "assets/Logo2.png", // ganti sesuai path logo kamu
                  height: 40,
                ),
              ),

              const SizedBox(height: 5),

              // Gambar ilustrasi
              Center(
                child: Image.asset(
                  "assets/Spoiler.png", // ganti dengan gambar yang kamu punya
                  height: 350,
                ),
              ),

              const SizedBox(height: 5),

              // Judul
              Text(
                "Kesulitan melakukan monitoring kolam lele?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "Dengan AquaSense monitoring kolam lele jadi mudah!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 45),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const BottomNavBar()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24479C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    "Masuk",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }
}
