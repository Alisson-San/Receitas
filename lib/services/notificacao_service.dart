import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class ServicoNotificacao {
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  ServicoNotificacao({FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin}) {
    _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;
  }

  Future<void> initNotifications() async {
    if (_flutterLocalNotificationsPlugin == null) {
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher'); // Use 'ic_launcher' como padrão

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );
    await _flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      },
    );
  }

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

    await _flutterLocalNotificationsPlugin!.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'backup_completed',
    );
  }
}