// lib/managers/instruction_manager.dart
import 'package:flutter/material.dart';
import 'package:receita/models/Instrucao.dart';
import 'package:receita/repositories/instrucoes_repository.dart';
import 'package:uuid/uuid.dart';

class GestorInstrucao {
  final InstrucoesRepository instrucoesRepository;
  final String receitaId;
  final Function onDataChanged;
  final List<Instrucao> currentInstructions;

  GestorInstrucao({
    required this.instrucoesRepository,
    required this.receitaId,
    required this.onDataChanged,
    required this.currentInstructions,
  });

  Future<void> addInstrucao(BuildContext context) async {
    final descricaoController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Instrução'),
        content: TextField(
          controller: descricaoController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Descrição da Instrução'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (descricaoController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final novaInstrucao = Instrucao(
        id: const Uuid().v4(),
        receitaId: receitaId,
        descricao: descricaoController.text,
        passo: currentInstructions.length + 1,
      );
      
      await instrucoesRepository.adicionar(novaInstrucao);
      onDataChanged();
    }
  }

  Future<void> editarInstrucao(BuildContext context, Instrucao instrucao) async {
    final descricaoController = TextEditingController(text: instrucao.descricao);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Instrução'),
        content: TextField(
          controller: descricaoController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Descrição da Instrução'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (descricaoController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final instrucaoAtualizada = Instrucao(
        id: instrucao.id,
        receitaId: instrucao.receitaId,
        descricao: descricaoController.text,
        passo: instrucao.passo,
      );
      
      await instrucoesRepository.atualizar(instrucaoAtualizada);
      onDataChanged();
    }
  }

  Future<void> removerInstrucao(Instrucao instrucao) async {
    await instrucoesRepository.remover(instrucao.id!);
    onDataChanged();
  }
}