import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  
  static const String baseUrl = 'http://192.168.1.77:5000';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> checkAnomaly(List<Map<String, double>> dataBuffer) async {
    try {
      final url = Uri.parse('$baseUrl/predict');
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"data": dataBuffer}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      // Menangkap error jika server mati atau IP salah
      throw Exception("Gagal terhubung ke Server AI. Pastikan IP benar dan Server menyala.");
    }
  }

  /// Fetch real-time data from Firestore collection 'realtime_data', document 'device_1'
  Future<Map<String, dynamic>> getRealtimeData() async {
    try {
      final doc = await _firestore
          .collection('realtime_data')
          .doc('device_1')
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception("Document device_1 tidak ditemukan di collection realtime_data");
      }
    } catch (e) {
      throw Exception("Gagal mengambil data Firestore: $e");
    }
  }

  /// Stream real-time data from Firestore for live updates
  Stream<Map<String, dynamic>> getRealtimeDataStream() {
    print("🔥 [ApiService] Creating Firestore stream for realtime_data/device_1");
    return _firestore
        .collection('realtime_data')
        .doc('device_1')
        .snapshots()
        .map((snapshot) {
      print("🔥 [ApiService] Snapshot received - exists: ${snapshot.exists}");
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        print("🔥 [ApiService] Data snapshot: $data");
        return data;
      } else {
        throw Exception("Document device_1 tidak ditemukan di collection realtime_data");
      }
    });
  }

  /// Create test data in Firestore (untuk debugging/testing)
  Future<void> createTestData() async {
    try {
      print("📝 [ApiService] Creating test data...");
      await _firestore
          .collection('realtime_data')
          .doc('device_1')
          .set({
        'suhu_air': 28.5,
        'suhu_lingkungan': 30.0,
        'dissolved_oxygen': 6.5,
        'pH_air': 7.2,
        'tds': 200.0,
        'turbidity': 12.0,
        'pakan_percent': 80.0,
        'updatedAt': DateTime.now(),
      });
      print("✅ [ApiService] Test data created successfully!");
    } catch (e) {
      print("❌ [ApiService] Error creating test data: $e");
      throw Exception("Gagal membuat test data: $e");
    }
  }
}