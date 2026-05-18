import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tailormate/models/order.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  // schedule notification for an order
  static Future<void> scheduleOrderReminder(
      TailorOrder order) async {
    if (order.dueDate == null) return;

    final dueDate = DateTime.parse(order.dueDate!);
    final now = DateTime.now();

    // 3 days before
    final threeDaysBefore =
    dueDate.subtract(const Duration(days: 3));
    if (threeDaysBefore.isAfter(now)) {
      await _notifications.zonedSchedule(
        order.id! * 10,
        '⏰ Order due in 3 days!',
        '${order.outfitName} is due on ${dueDate.day}/${dueDate.month}/${dueDate.year}',
        tz.TZDateTime.from(threeDaysBefore, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'order_reminders',
            'Order Reminders',
            channelDescription: 'Reminders for upcoming orders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode:
        AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation
            .absoluteTime,
      );
    }

    // on due date
    final onDueDate = DateTime(
        dueDate.year, dueDate.month, dueDate.day, 8, 0);
    if (onDueDate.isAfter(now)) {
      await _notifications.zonedSchedule(
        order.id! * 10 + 1,
        '🚨 Order due today!',
        '${order.outfitName} is due today!',
        tz.TZDateTime.from(onDueDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'order_reminders',
            'Order Reminders',
            channelDescription: 'Reminders for upcoming orders',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode:
        AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation
            .absoluteTime,
      );
    }
  }

  // cancel notifications for an order
  static Future<void> cancelOrderReminder(int orderId) async {
    await _notifications.cancel(orderId * 10);
    await _notifications.cancel(orderId * 10 + 1);
  }
}