import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global notifier — satu sumber kebenaran untuk status notif
/// Semua halaman listen ke notifier ini, perubahan langsung tersebar
class NotifState {
  NotifState._();
  static final ValueNotifier<bool> hasNotif = ValueNotifier(false);

  /// Muat dari SharedPreferences dan update notifier
  static Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    final isAnomaly = prefs.getBool('is_anomaly') ?? false;
    final notifOpened = prefs.getBool('notif_opened') ?? true;
    hasNotif.value = isAnomaly && !notifOpened;
  }

  /// Tandai notif sudah dibuka
  static Future<void> markOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_opened', true);
    await reload();
  }
}
