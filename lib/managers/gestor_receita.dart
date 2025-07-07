// lib/managers/receita_manager.dart
import 'package:flutter/material.dart';
import 'package:receita/models/receita.dart';
import 'package:receita/repositories/ingredientes_repository.dart';
import 'package:receita/repositories/instrucoes_repository.dart';
import 'package:receita/repositories/receita_repository.dart';
import 'package:receita/services/receita_service.dart';
import 'package:uuid/uuid.dart';
import 'package:local_auth/local_auth.dart';

class GestorReceita {
  final ReceitaRepository receitaRepository;
  final IngredientesRepository ingredientesRepository;
  final InstrucoesRepository instrucoesRepository;
  final Function() onDataChanged;
  final String userId;
  final LocalAuthentication _auth = LocalAuthentication();

  GestorReceita({
    required this.receitaRepository,
    required this.ingredientesRepository,
    required this.instrucoesRepository,
    required this.onDataChanged,
    required this.userId, 
  });

  Future<void> escolherCriacaoReceita(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Receita'),
        content: const Text('Como você deseja criar a receita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 1),
            child: const Text('Manual'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 2),
            child: const Text('Aleatória'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (result == 1) {
      await _addManualReceita(context);
      onDataChanged();
    } else if (result == 2) {
      await _addAleatoriaReceita(context);
      onDataChanged();
    }
  }

  Future<void> _addAleatoriaReceita(BuildContext context) async {


      final randomText = await ReceitaService.fetchRandomRecipe();
      final novaReceita = ReceitaService.parseRecipeFromText(randomText);
      final receitaId = const Uuid().v1();
      
      novaReceita.id = receitaId;
      novaReceita.userId = userId; 
      
      await receitaRepository.adicionar(novaReceita);
      
      for (var ingrediente in novaReceita.ingredientes) {
        ingrediente.receitaId = receitaId;
        await ingredientesRepository.adicionar(ingrediente);
      }
      
      for (var instrucao in novaReceita.instrucoes) {
        instrucao.receitaId = receitaId;
        await instrucoesRepository.adicionar(instrucao);
      }
  }

  Future<void> _addManualReceita(BuildContext context) async {
    final textController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Receita'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome da Receita'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.pop(context, textController.text);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await receitaRepository.adicionar(Receita(
        nome: result, 
        id: const Uuid().v1(), 
        dataCriacao: DateTime.now().toIso8601String().split('T')[0], 
        ingredientes: [], 
        instrucoes: [],
        userId: userId, 
      ));
    }
  }

  Future<void> editarReceita(BuildContext context, Receita receita) async {
    final nomeController = TextEditingController(text: receita.nome);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Receita'),
        content: TextField(
          controller: nomeController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome da Receita'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nomeController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      receita.nome = nomeController.text;
      await receitaRepository.atualizar(receita);
      onDataChanged();
    }
  }

  Future<void> removerReceita(BuildContext context, String receitaId) async {
    bool canCheckBiometrics = await _auth.canCheckBiometrics;
    bool isDeviceSupported = await _auth.isDeviceSupported();

    if (canCheckBiometrics && isDeviceSupported) {
      try {
        final bool didAuthenticate = await _auth.authenticate(
          localizedReason: 'Por favor, autentique para deletar esta receita',
          options: const AuthenticationOptions(
            stickyAuth: true, 
            biometricOnly: false,
          ),
        );

        if (didAuthenticate) {
          await receitaRepository.remover(receitaId);
          onDataChanged();
          // Opcional: Mostrar um SnackBar de sucesso
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receita deletada com sucesso!')),
            );
          }
        } else {
          // Usuário não autenticou
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Autenticação falhou. Receita não deletada.')),
            );
          }
        }
      } catch (e) {
        // Lidar com erros de autenticação (ex: hardware não disponível, permissão negada)
        debugPrint("Erro durante a autenticação: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro na autenticação: ${e.toString()}')),
          );
        }
      }
    } else {
      
      debugPrint("Biometria ou autenticação de dispositivo não disponível/configurada.");
      // Se desejar, adicione um diálogo de confirmação simples aqui:
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Este dispositivo não suporta autenticação de segurança. Deseja realmente deletar esta receita?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Deletar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await receitaRepository.remover(receitaId);
        onDataChanged();
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receita deletada (sem autenticação).')),
            );
          }
      }
    }
  }
}