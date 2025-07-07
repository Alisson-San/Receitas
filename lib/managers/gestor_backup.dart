
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receita/models/Ingrediente.dart';
import 'package:receita/models/Instrucao.dart';

import 'package:receita/models/receita.dart';

import 'package:receita/repositories/receita_repository.dart';
import 'package:receita/repositories/ingredientes_repository.dart';
import 'package:receita/repositories/instrucoes_repository.dart';
import 'package:receita/services/notificacao_service.dart';


import 'package:permission_handler/permission_handler.dart'; 

class GestorBackup {
  final ReceitaRepository receitaRepository;
  final IngredientesRepository ingredientesRepository;
  final InstrucoesRepository instrucoesRepository;
  final String userId;
  final ServicoNotificacao notificacaoServico;

  GestorBackup({
    required this.receitaRepository,
    required this.ingredientesRepository,
    required this.instrucoesRepository,
    required this.userId,
    required this.notificacaoServico,
  });


  Future<List<Receita>> _pegarTodasInformacaoUsuario() async {
    final List<Receita> receitas = await receitaRepository.todosDoUsuario(userId);
    for (var receita in receitas) {
      
      receita.ingredientes = await ingredientesRepository.todosDaReceita(receita.id!);
      receita.instrucoes = await instrucoesRepository.todosDaReceita(receita.id!);
    }
    return receitas;
  }

  
  Future<void> LocalBackup(BuildContext? context) async {
    // Solicitar permissão de armazenamento
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de armazenamento negada. Não foi possível realizar o backup local.')),
        );
      }
      notificacaoServico.mostrarNotificacao('Backup Local Falhou', 'Permissão de armazenamento negada.');
      return;
    }

    try {
      final List<Receita> todosDadosUsuario = await _pegarTodasInformacaoUsuario();
      final List<Map<String, dynamic>> jsonData = todosDadosUsuario.map((r) => r.toJson()).toList();
      final String jsonString = jsonEncode(jsonData);

      // Permite ao usuário escolher o diretório
      String? diretorio = await FilePicker.platform.getDirectoryPath();

      if (diretorio != null) {
        final String fileName = 'receitas_backup_${DateTime.now().toIso8601String().split('.')[0].replaceAll(':', '-')}.json';
        final File file = File('$diretorio/$fileName');
        
        await file.writeAsString(jsonString);

        notificacaoServico.mostrarNotificacao('Backup Local Concluído', 'Suas receitas foram salvas em $fileName');
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup local salvo em: ${file.path}')),
          );
        }
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seleção de diretório cancelada.')),
          );
        }
        notificacaoServico.mostrarNotificacao('Backup Local Cancelado', 'Nenhum diretório selecionado.');
      }
    } on PathAccessException catch (e) {
      debugPrint('Erro de permissão ou acesso ao path (Backup Local): $e');
      notificacaoServico.mostrarNotificacao('Backup Local Falhou', 'Erro de permissão ao salvar o arquivo: ${e.message}. Tente outro local.');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o backup. Tente salvar em outro local. (Detalhes: ${e.message})')),
        );
      }
    } catch (e) {
      debugPrint('Erro inesperado ao realizar backup local: $e');
      notificacaoServico.mostrarNotificacao('Backup Local Falhou', 'Ocorreu um erro inesperado: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao realizar backup local: $e')),
        );
      }
    }
  }


  Future<void> restauracaoArquivoLocal(BuildContext context) async {
    // Solicitar permissão de armazenamento (para leitura)
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de armazenamento negada. Não foi possível restaurar do backup local.')),
        );
      }
      notificacaoServico.mostrarNotificacao('Restauração Local Falhou', 'Permissão de armazenamento negada.');
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        final String jsonString = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(jsonString);
        final List<Receita> restoredRecipes = jsonData.map((e) => Receita.fromJson(e)).toList();

        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Restauração'),
            content: const Text(
                'A restauração substituirá todas as suas receitas atuais. Deseja continuar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuar'),
              ),
            ],
          ),
        );

        if (confirm == true) {

          final List<Receita> todosDadosUsuario = await _pegarTodasInformacaoUsuario();

          todosDadosUsuario.forEach((receita) {
            ingredientesRepository.removerTodosDaReceita(receita.id!);
            instrucoesRepository.removerTodosDaReceita(receita.id!);
            receitaRepository.remover(receita.id!);
          });

          restoredRecipes.forEach((receita) {
            receita.userId = userId; // Garante que a receita restaurada pertence ao usuário logado

            receitaRepository.adicionar(receita);
            receita.ingredientes.forEach((ingrediente) {
              ingrediente.receitaId = receita.id; // Garante o link da sub-coleção
              ingredientesRepository.adicionar(ingrediente);
            });
            receita.instrucoes.forEach((instrucao) {
              instrucao.receitaId = receita.id; // Garante o link da sub-coleção
              instrucoesRepository.adicionar(instrucao);
            });
          });


          notificacaoServico.mostrarNotificacao('Restauração Local Concluída', 'Receitas restauradas do arquivo.');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Restauração do backup local concluída!')),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Restauração cancelada.')),
            );
          }
          notificacaoServico.mostrarNotificacao('Restauração Local Cancelada', 'Operação cancelada pelo usuário.');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seleção de arquivo cancelada.')),
          );
        }
        notificacaoServico.mostrarNotificacao('Restauração Local Cancelada', 'Nenhum arquivo selecionado.');
      }
    } on PathAccessException catch (e) {
      debugPrint('Erro de permissão ou acesso ao path (Restauração Local): $e');
      notificacaoServico.mostrarNotificacao('Restauração Local Falhou', 'Erro de permissão ao ler o arquivo: ${e.message}.');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ler o backup. (Detalhes: ${e.message})')),
        );
      }
    } catch (e) {
      debugPrint('Erro inesperado ao restaurar backup local: $e');
      notificacaoServico.mostrarNotificacao('Restauração Local Falhou', 'Ocorreu um erro inesperado: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao restaurar backup local: $e')),
        );
      }
    }
  }

  Future<void> FirebaseBackup(BuildContext? context) async {
    try {
      final List<Receita> todosDadosUsuario = await _pegarTodasInformacaoUsuario();
      final CollectionReference userRecipesCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('recipes');

      final QuerySnapshot existingRecipes = await userRecipesCollection.get();
      for (DocumentSnapshot doc in existingRecipes.docs) {
        await doc.reference.delete();
      }


      for (var receita in todosDadosUsuario) {
        // Salva a receita principal
        await userRecipesCollection.doc(receita.id).set(receita.toJson());

        // Salva ingredientes como subcoleção
        if (receita.ingredientes.isNotEmpty) {
          final CollectionReference ingredientesSubCollection =
              userRecipesCollection.doc(receita.id!).collection('ingredientes');
          for (var ingrediente in receita.ingredientes) {
            await ingredientesSubCollection.doc(ingrediente.id).set(ingrediente.toJson());
          }
        }

       
        if (receita.instrucoes.isNotEmpty) {
          final CollectionReference instrucoesSubCollection =
              userRecipesCollection.doc(receita.id!).collection('instrucoes');
          for (var instrucao in receita.instrucoes) {
            await instrucoesSubCollection.doc(instrucao.id).set(instrucao.toJson());
          }
        }
      }
      notificacaoServico.mostrarNotificacao('Backup Firebase Concluído', 'Suas receitas foram salvas no Firebase.');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup no Firebase concluído com sucesso!')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao realizar backup Firebase: $e');
      notificacaoServico.mostrarNotificacao('Backup Firebase Falhou', 'Falha ao salvar receitas no Firebase: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao realizar backup Firebase: $e')),
        );
      }
    }
  }

  Future<void> restaurarFirebaseBackup(BuildContext context) async {
    try {
      final CollectionReference userRecipesCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('recipes');

      final QuerySnapshot recipesSnapshot = await userRecipesCollection.get();
      if (recipesSnapshot.docs.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum backup encontrado no Firebase para este usuário.')),
          );
        }
        notificacaoServico.mostrarNotificacao('Restauração Firebase Falhou', 'Nenhum backup encontrado no Firebase.');
        return;
      }

      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Restauração Firebase'),
          content: const Text(
              'A restauração do Firebase substituirá todas as suas receitas atuais. Deseja continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );

      if (confirm == true) {

        List<Receita> receitasRestauradas = [];
        for (var doc in recipesSnapshot.docs) {
          final Receita receita = Receita.fromJson(doc.data()! as Map<String, dynamic>);
          receita.userId = userId;

          final QuerySnapshot ingredientesSnapshot =
              await userRecipesCollection.doc(receita.id).collection('ingredientes').get();
          receita.ingredientes = ingredientesSnapshot.docs
              .map((ingDoc) => Ingrediente.fromJson(ingDoc.data()! as Map<String, dynamic>))
              .toList();

          final QuerySnapshot instrucoesSnapshot =
              await userRecipesCollection.doc(receita.id).collection('instrucoes').get();
          receita.instrucoes = instrucoesSnapshot.docs
              .map((instDoc) => Instrucao.fromJson(instDoc.data()! as Map<String, dynamic>))
              .toList();
          receitasRestauradas.add(receita);
        }


        // Limpa as receitas, ingredientes e instruções atuais do usuário
        
        final todosDadosUsuario = await _pegarTodasInformacaoUsuario();
        for (var receita in todosDadosUsuario) {
          await receitaRepository.remover(receita.id!);
          await ingredientesRepository.removerTodosDaReceita(receita.id!);
          await instrucoesRepository.removerTodosDaReceita(receita.id!);
        }
        // Restaura as receitas do Firebase
        receitasRestauradas.forEach((receita) async{
          receita.userId = userId; 

          await receitaRepository.adicionar(receita);
        });
        for (var receita in receitasRestauradas) {
          receita.ingredientes.forEach((ingrediente) async {
            ingrediente.receitaId = receita.id; 
            await ingredientesRepository.adicionar(ingrediente);
          });
          receita.instrucoes.forEach((instrucao) async {
            instrucao.receitaId = receita.id; 
            await instrucoesRepository.adicionar(instrucao);
          });
        }
      

        notificacaoServico.mostrarNotificacao('Restauração Firebase Concluída', 'Receitas restauradas do Firebase.');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restauração do backup Firebase concluída!')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restauração cancelada.')),
          );
        }
        notificacaoServico.mostrarNotificacao('Restauração Firebase Cancelada', 'Operação cancelada pelo usuário.');
      }
    } catch (e) {
      debugPrint('Erro ao restaurar backup Firebase: $e');
      notificacaoServico.mostrarNotificacao('Restauração Firebase Falhou', 'Falha ao restaurar receitas do Firebase: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao restaurar backup Firebase: $e')),
        );
      }
    }
  }

}