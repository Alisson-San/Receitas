import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; 
import 'package:workmanager/workmanager.dart';


import 'package:receita/services/notificacao_service.dart';
import 'screens/login_screen.dart';
import 'screens/receita_list_screen.dart';
import 'tarefas_background.dart';

// Instância global do plugin de notificações
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Instância global do NotificationService
late ServicoNotificacao notificacaoService;

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // Inicialização do plugin de notificações
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings
  );

  notificacaoService = ServicoNotificacao(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Receitas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
    home: LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const ReceitaListScreen(),
      },
    );
  }
}