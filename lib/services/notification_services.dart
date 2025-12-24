import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/helper/app_dates.dart';
import 'package:projek_uts_mbr/services/discount_service.dart';
import '../l10n/app_localizations.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';

class NotificationServices {
  static Future<void> scheduleOrderReminder({
    required BuildContext context,
    required DateTime eventDate,
    required String vendorName,
    required String packageName,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    //jika nanti sudah on, dan user beli paket, reminder di set ke default jam 9 pagi
    final reminderTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      9,
      0,
    );

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: l10n.notificationAppointmentTitle,
        body: l10n.notificationAppointmentBody('$vendorName - $packageName'),
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        year: reminderTime.year,
        month: reminderTime.month,
        day: reminderTime.day,
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        second: 0,
        millisecond: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  static Future<void> schedulePremiumReminder({
    required String customerEmail,
    required DateTime expiryDate,
  }) async {
    //untuk reminder 1 hari sebelum expire
    final oneDayBefore = expiryDate.subtract(Duration(days: 1));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(100000),
        channelKey: 'basic_channel',
        title: 'Premium Subscription Reminder',
        body:
            'Premium Anda akan berakhir besok. Perpanjang sekarang untuk tetap menikmati fitur eksklusif!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'premium_reminder',
          'customerEmail': customerEmail,
          'daysLeft': '1',
          'expiryDate': expiryDate.toIso8601String(),
        },
      ),
      schedule: NotificationCalendar(
        year: oneDayBefore.year,
        month: oneDayBefore.month,
        day: oneDayBefore.day,
        hour: 10, // default diingatkan pas jam 10 pagi
        minute: 0,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );

    print('Scheduled premium reminder for 1 day before expiry: $oneDayBefore');

    //ini untuk notifikasi pas paket premium sudah expire
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(100000),
        channelKey: 'basic_channel',
        title: 'Premium Subscription Expired',
        body:
            'Premium Anda telah berakhir. Upgrade sekarang untuk kembali menikmati fitur tanpa iklan!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'premium_expired',
          'customerEmail': customerEmail,
          'daysLeft': '0',
          'expiryDate': expiryDate.toIso8601String(),
        },
      ),
      schedule: NotificationCalendar(
        year: expiryDate.year,
        month: expiryDate.month,
        day: expiryDate.day,
        hour: 9, // default diingatkan pada jam 9 pagi
        minute: 0,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );

    print('Scheduled premium expired notification for: $expiryDate');
  }

  static void _showNotif(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static bool isTanggalKembar() {
    final now = DateTime.now();
    return now.day == now.month;
  }

  static bool isAnniversary() {
    final now = DateTime.now();
    return now.day == AppDates.ANNIV_DAY && now.month == AppDates.ANNIV_MONTH;
  }

  static Future<void> checkAndTrigger() async {
    final sessionManager = SessionManager();
    bool notifEnabled = await sessionManager.getNotificationStatus();
    if (!notifEnabled) return;

    if (isTanggalKembar()) {
      DiscountService.activateDiscount(0.05); // 5%
      _showNotif('🎉 Tanggal Kembar!', 'Diskon 5% untuk semua produk 🎁');
      return;
    }

    if (isAnniversary()) {
      DiscountService.activateDiscount(0.10); // 10%
      _showNotif('🎂 Anniversary App', 'Diskon spesial 10% 🎉');
    }
  }
}
