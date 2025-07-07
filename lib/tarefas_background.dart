import 'package:receita/main.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:receita/repositories/receita_repository.dart';
import 'package:receita/repositories/ingredientes_repository.dart';
import 'package:receita/repositories/instrucoes_repository.dart';
import 'package:receita/managers/gestor_backup.dart';
import 'package:receita/services/notificacao_service.dart';
import 'package:flutter/material.dart';


@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized(); 
    await Firebase.initializeApp(); 

    // Inicializa o NotificationService
    final ServicoNotificacao servicoNotificacao = ServicoNotificacao();
    await servicoNotificacao.initNotifications();

    debugPrint("Executando tarefa de background: $taskName");

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("Usuário não logado, não é possível fazer backup em background.");
        servicoNotificacao.mostrarNotificacao(
          'Backup Automático Falhou',
          'Não foi possível realizar o backup. Faça login no aplicativo.',
        );
        return Future.value(true);
      }

      final ReceitaRepository receitaRepository = ReceitaRepository();
      final IngredientesRepository ingredientesRepository = IngredientesRepository();
      final InstrucoesRepository instrucoesRepository = InstrucoesRepository();

      final GestorBackup backupManager = GestorBackup(
        receitaRepository: receitaRepository,
        ingredientesRepository: ingredientesRepository,
        instrucoesRepository: instrucoesRepository,
        userId: user.uid,
        notificacaoServico: servicoNotificacao,
      );


      await backupManager.FirebaseBackup(null);

      debugPrint("Backup Firebase em background concluído para o usuário: ${user.uid}");
  

      return Future.value(true); 
    } catch (e) {
      debugPrint("Erro na tarefa de background ($taskName): $e");
      notificacaoService.mostrarNotificacao(
        'Backup Automático Falhou',
        'Ocorreu um erro ao tentar realizar o backup: $e',
      );
      return Future.value(false); 
    }
  });
}