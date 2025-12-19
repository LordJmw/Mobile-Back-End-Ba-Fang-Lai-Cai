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
}
