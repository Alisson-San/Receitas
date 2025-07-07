import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ServicoNotificacao {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  ServicoNotificacao({required this.flutterLocalNotificationsPlugin});

  Future<void> mostrarNotificacao(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'backup_channel', // ID do canal
      'Backup Notifications', // Nome do canal
      channelDescription: 'Notificações para operações de backup e restauração.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'backup_completed',
    );
  }
}