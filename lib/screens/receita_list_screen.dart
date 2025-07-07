import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:receita/repositories/ingredientes_repository.dart';
import 'package:receita/repositories/instrucoes_repository.dart';
import '/models/receita.dart';
import '/repositories/receita_repository.dart';
import '/screens/receita_detalhe_screen.dart';
import 'package:receita/managers/gestor_receita.dart';
import 'package:receita/screens/configuracao_usuario_screen.dart';

class ReceitaListScreen extends StatefulWidget {
  const ReceitaListScreen({super.key});

  @override
  _ReceitaListScreenState createState() => _ReceitaListScreenState();
}

class _ReceitaListScreenState extends State<ReceitaListScreen> {
  List<Receita> _receitas = [];
  late ReceitaRepository _receitaRepository;
  late IngredientesRepository _ingredientesRepository;
  late InstrucoesRepository _instrucoesRepository;
  late GestorReceita _gestorReceita;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _receitaRepository = ReceitaRepository();
    _ingredientesRepository = IngredientesRepository();
    _instrucoesRepository = InstrucoesRepository();
    _initializeUserAndLoadReceitas  (); 
  }

  Future<void> _initializeUserAndLoadReceitas() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid; 
      _gestorReceita = GestorReceita(
        receitaRepository: _receitaRepository,
        ingredientesRepository: _ingredientesRepository,
        instrucoesRepository: _instrucoesRepository,
        onDataChanged: _carregarReceitas,
        userId: _currentUserId!, 
      );
      await _carregarReceitas();
    } else {
      debugPrint("Usuário não logado na ReceitaListScreen.");
      setState(() {
        _receitas = [];
      });
    }
  }

  Future<void> _carregarReceitas() async {
    if (_currentUserId == null) {
      setState(() {
        _receitas = [];
      });
      return;
    }
   
    var receitasBanco = await _receitaRepository.todosDoUsuario(_currentUserId!);
    for (var receita in receitasBanco) {
      var ingredientes = await _ingredientesRepository.todosDaReceita(receita.id!);
      var instrucoes = await _instrucoesRepository.todosDaReceita(receita.id!);
      receita.ingredientes = ingredientes;
      receita.instrucoes = instrucoes;
    }    
    setState(() {
      _receitas = receitasBanco;
    });
  }

  String _montarSubtitle(Receita receita) {
    String dataCriacao = receita.dataCriacao ?? '';
    int ingredientes = receita.ingredientes.length;
    int instrucoes = receita.instrucoes.length;
    return 'Criado:$dataCriacao \nIngredientes:$ingredientes \nInstruções:$instrucoes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Botão de configurações
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfiguracaoUsuarioScreen()),
              );
              await _carregarReceitas();
            },
          ),
        ],
      ),
      body: _currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : _receitas.isEmpty
              ? const Center(child: Text('Nenhuma receita encontrada. Crie uma!'))
              : ListView.builder(
                  itemCount: _receitas.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_receitas[index].nome ?? ''),
                      subtitle: Text(_montarSubtitle(_receitas[index])),
                      leading: const Icon(Icons.receipt),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceitaDetalheScreen(
                              receita: _receitas[index],
                              gestorReceita: _gestorReceita,
                              ingredientesRepository: _ingredientesRepository,
                              instrucoesRepository: _instrucoesRepository,
                            ),
                          ),
                        );
                        await _carregarReceitas();
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentUserId == null
            ? null
            : () => _gestorReceita.escolherCriacaoReceita(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}