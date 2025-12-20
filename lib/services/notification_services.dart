import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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
        hour: 10, // 10 AM
        minute: 0,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );

    print('Scheduled premium reminder for 1 day before expiry: $oneDayBefore');

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
        hour: 9, // 9 AM
        minute: 0,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );

    print('Scheduled premium expired notification for: $expiryDate');
  }
}
