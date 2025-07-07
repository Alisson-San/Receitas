// lib/managers/ingredient_manager.dart
import 'package:flutter/material.dart';
import 'package:receita/models/Ingrediente.dart';
import 'package:receita/repositories/ingredientes_repository.dart';

class GestorIngrediente {
  final IngredientesRepository ingredientesRepository;
  final String receitaId;
  final Function onDataChanged;

  GestorIngrediente({
    required this.ingredientesRepository,
    required this.receitaId,
    required this.onDataChanged,
  });

  Future<void> addIngrediente(BuildContext context) async {
    final nomeController = TextEditingController();
    final quantidadeController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Ingrediente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome do Ingrediente'),
            ),
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.text, // Mudado para text para aceitar 'g', 'ml'
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nomeController.text.isNotEmpty && quantidadeController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final novoIngrediente = Ingrediente(
        receitaId: receitaId,
        nome: nomeController.text,
        quantidade: quantidadeController.text,
      );
      
      await ingredientesRepository.adicionar(novoIngrediente);
      onDataChanged();
    }
  }

  Future<void> editarIngrediente(BuildContext context, Ingrediente ingrediente) async {
    final nomeController = TextEditingController(text: ingrediente.nome);
    final quantidadeController = TextEditingController(text: ingrediente.quantidade);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Ingrediente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome do Ingrediente'),
            ),
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.text, // Mudado para text para aceitar 'g', 'ml'
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nomeController.text.isNotEmpty && quantidadeController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final ingredienteAtualizado = Ingrediente(
        id: ingrediente.id,
        receitaId: ingrediente.receitaId,
        nome: nomeController.text,
        quantidade: quantidadeController.text,
      );
      
      await ingredientesRepository.atualizar(ingredienteAtualizado);
      onDataChanged();
    }
  }

  Future<void> removerIngrediente(Ingrediente ingrediente) async {
    await ingredientesRepository.remover(ingrediente.id!);
    onDataChanged();
  }
}