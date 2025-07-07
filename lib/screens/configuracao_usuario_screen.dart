import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:receita/screens/login_screen.dart';
import 'package:receita/managers/gestor_backup.dart';
import 'package:receita/repositories/ingredientes_repository.dart';
import 'package:receita/repositories/instrucoes_repository.dart';
import 'package:receita/repositories/receita_repository.dart';
import 'package:receita/main.dart' as app_main;

class ConfiguracaoUsuarioScreen extends StatefulWidget {
  const ConfiguracaoUsuarioScreen({super.key});

  @override
  State<ConfiguracaoUsuarioScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<ConfiguracaoUsuarioScreen> {
  late GestorBackup _gestorBackup;
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final IngredientesRepository _ingredientesRepository = IngredientesRepository();
  final InstrucoesRepository _instrucoesRepository = InstrucoesRepository();

  @override
  void initState() {
    super.initState();
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
              onPressed: () => _gestorBackup.LocalBackup(context),
              child: const Text('Backup Agora (Arquivo Local)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _gestorBackup.FirebaseBackup(context),
              child: const Text('Backup Agora (Firebase)'),
            ),
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