import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:receita/screens/login_screen.dart';
import 'package:receita/managers/gestor_backup.dart';
import 'package:receita/repositories/ingredientes_repository.dart';
import 'package:receita/repositories/instrucoes_repository.dart';
import 'package:receita/repositories/receita_repository.dart';
import 'package:receita/main.dart' as app_main;
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracaoUsuarioScreen extends StatefulWidget {
  const ConfiguracaoUsuarioScreen({super.key});

  @override
  State<ConfiguracaoUsuarioScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<ConfiguracaoUsuarioScreen> with WidgetsBindingObserver { 
  late GestorBackup _gestorBackup;
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final IngredientesRepository _ingredientesRepository = IngredientesRepository();
  final InstrucoesRepository _instrucoesRepository = InstrucoesRepository();
  bool _isAutoBackupEnabled = false;
  static const String _autoBackupKey = 'auto_backup_enabled';
  static const String _backupTaskName = 'firebaseBackupTask';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSettings();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remover o observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAutoBackupSetting();
    }
  }

  Future<void> _initializeSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _gestorBackup = GestorBackup(
        receitaRepository: _receitaRepository,
        ingredientesRepository: _ingredientesRepository,
        instrucoesRepository: _instrucoesRepository,
        userId: user.uid,
        notificacaoServico: app_main.notificacaoService,
      );
    } else {    
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Redireciona para LoginScreen
        (Route<dynamic> route) => false,
      );
    }
  }
  

  Future<void> _loadAutoBackupSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAutoBackupEnabled = prefs.getBool(_autoBackupKey) ?? false;
    });
  }

  Future<void> _toggleAutoBackup(bool newValue) async {
    setState(() {
      _isAutoBackupEnabled = newValue;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupKey, newValue);

    if (newValue) {
      
      Workmanager().registerPeriodicTask(
        _backupTaskName,
        _backupTaskName, 
        frequency: const Duration(seconds: 30),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup automático agendado diariamente.')),
        );
      }
    } else {
      
      Workmanager().cancelByUniqueName(_backupTaskName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup automático desativado.')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configurações do Usuário')),
        body: const Center(child: Text('Usuário não logado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E-mail: ${user.email ?? 'Não disponível'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _gestorBackup.LocalBackup(context);
              },
              child: const Text('Backup Agora (Arquivo Local)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _gestorBackup.FirebaseBackup(context);
              },
              child: const Text('Backup Agora (Firebase)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _gestorBackup.restauracaoArquivoLocal(context);
              },
              child: const Text('Restaurar de Arquivo Local'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _gestorBackup.restaurarFirebaseBackup(context);
              },
              child: const Text('Restaurar do Firebase'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Backup Automático (Firebase)',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _isAutoBackupEnabled,
                  onChanged: _toggleAutoBackup,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text('Sair (Logout)'),
            ),
          ],
        ),
      ),
    );
  }
}