import 'package:flutter/material.dart';
import 'package:receita/managers/gestor_receita.dart';
import 'package:receita/models/receita.dart';
import 'package:receita/repositories/ingredientes_repository.dart';
import 'package:receita/repositories/instrucoes_repository.dart';
import 'package:receita/managers/gestor_ingrediente.dart';
import 'package:receita/managers/gestor_instrucao.dart';

class ReceitaDetalheScreen extends StatefulWidget {
  final Receita receita;
  final GestorReceita gestorReceita;
  final IngredientesRepository ingredientesRepository;
  final InstrucoesRepository instrucoesRepository;

  const ReceitaDetalheScreen({
    super.key,
    required this.receita,
    required this.gestorReceita,
    required this.ingredientesRepository,
    required this.instrucoesRepository,
  });

  @override
  _ReceitaDetalheScreenState createState() => _ReceitaDetalheScreenState();
}

class _ReceitaDetalheScreenState extends State<ReceitaDetalheScreen> {
  late Receita _receitaAtualizada;
  late IngredientesRepository _ingredientesRepository;
  late InstrucoesRepository _instrucoesRepository;
  late GestorReceita _gestorReceita; 

  late GestorIngrediente _gestorIngrediente;
  late GestorInstrucao _gestorInstrucao;

  @override
  void initState() {
    super.initState();
    _receitaAtualizada = widget.receita;
    _ingredientesRepository = widget.ingredientesRepository;
    _instrucoesRepository = widget.instrucoesRepository;
    _gestorReceita = widget.gestorReceita;

    _gestorIngrediente = GestorIngrediente(
      ingredientesRepository: _ingredientesRepository,
      receitaId: _receitaAtualizada.id!,
      onDataChanged: _carregarDados,
    );

    _gestorInstrucao = GestorInstrucao(
      instrucoesRepository: _instrucoesRepository,
      receitaId: _receitaAtualizada.id!,
      onDataChanged: _carregarDados,
      currentInstructions: _receitaAtualizada.instrucoes,
    );

    _carregarDados(); // Carrega os dados iniciais
  }

  Future<void> _carregarDados() async {
    final ingredientes = await _ingredientesRepository.todosDaReceita(_receitaAtualizada.id!);
    final instrucoes = await _instrucoesRepository.todosDaReceita(_receitaAtualizada.id!);
    
    setState(() {
      _receitaAtualizada.ingredientes = ingredientes;
      _receitaAtualizada.instrucoes = instrucoes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_receitaAtualizada.nome ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await _gestorReceita.editarReceita(context, _receitaAtualizada);
              setState(() {}); 
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _gestorReceita.removerReceita(context,_receitaAtualizada.id!);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção 1: Informações Básicas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _receitaAtualizada.nome ?? '',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Criada em: ${_receitaAtualizada.dataCriacao?.split('T')[0] ?? ''}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Seção 2: Ingredientes
            Row(
              children: [
                const Text(
                  'Ingredientes',
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _gestorIngrediente.addIngrediente(context),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _receitaAtualizada.ingredientes.length,
              itemBuilder: (context, index) {
                final ingrediente = _receitaAtualizada.ingredientes[index];
                return ListTile(
                  title: Text('${ingrediente.nome} - ${ingrediente.quantidade}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _gestorIngrediente.editarIngrediente(context, ingrediente),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _gestorIngrediente.removerIngrediente(ingrediente),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Seção 3: Modo de Preparo
            Row(
              children: [
                const Text(
                  'Modo de Preparo'
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _gestorInstrucao.addInstrucao(context),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _receitaAtualizada.instrucoes.length,
              itemBuilder: (context, index) {
                final instrucao = _receitaAtualizada.instrucoes[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 12,
                    child: Text('${instrucao.passo}'),
                  ),
                  title: Text(instrucao.descricao ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _gestorInstrucao.editarInstrucao(context, instrucao),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _gestorInstrucao.removerInstrucao(instrucao),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}