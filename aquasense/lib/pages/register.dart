import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _obscurePassword = true;

  final Color primaryColor = const Color(0xFF24479C);

  //  Helper untuk uniform InputDecoration
  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black54,
      ),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      floatingLabelStyle: GoogleFonts.poppins(
        //  label berubah warna saat fokus
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("assets/icons/Back.png", width: 24, height: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              Center(
                child: Image.asset(
                  "assets/Logo3.png",
                  width: 170,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Register",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              //  Nama Depan
              TextField(
                decoration: _inputDecoration(
                  label: "Nama Depan",
                  hint: "Nama Depan",
                ),
              ),
              const SizedBox(height: 16),

              //  Nama Belakang
              TextField(
                decoration: _inputDecoration(
                  label: "Nama Belakang",
                  hint: "Nama Belakang",
                ),
              ),
              const SizedBox(height: 16),

              //  Email
              TextField(
                decoration: _inputDecoration(
                  label: "E-mail",
                  hint: "Email",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      "assets/icons/Email.png",
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              //  Password
              TextField(
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  label: "Password",
                  hint: "Password",
                  prefixIcon: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Image.asset(
                        "assets/icons/Lock.png",
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Image.asset(
                      _obscurePassword
                          ? "assets/icons/HidePass.png"
                          : "assets/icons/ShowPass.png",
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 39),

              //  Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // aksi register
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Daftar",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 45),

              //  Teks Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already signed up? ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
