import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NewsNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);
  }

  static Future<void> showNewsNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'news_channel',
      'Noticias del Instituto',
      channelDescription: 'Notificaciones de nuevas noticias',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
