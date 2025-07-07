// repositories/receita_repository.dart
import 'package:receita/db/database_helper.dart';
import 'package:receita/models/receita.dart';
import 'package:sqflite/sqflite.dart';

class ReceitaRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<void> adicionar(Receita receita) async {
    await _db.inserir(
      'receitas',
      receita.toSqliteMap(),
    );
  }

  Future<void> atualizar(Receita receita) async {
    await _db.atualizar(
      'receitas',
      receita.toSqliteMap(),
      condicao: 'id = ?',
      conidcaoArgs: [?receita.id],
    );
  }

  Future<void> remover(String id) async {
    

    await _db.deletar(
      'ingredientes',
      condicao: 'receitaId = ?',
      conidcaoArgs: [id],
    );

    await _db.deletar(
      'instrucoes',
      condicao: 'receitaId = ?',
      conidcaoArgs: [id],
    );

    await _db.deletar(
      'receitas',
      condicao: 'id = ?',
      conidcaoArgs: [id],
    );
  }

  Future<List<Receita>> todosDoUsuario(String userId) async {
        final List<Map<String, dynamic>> maps = await _db.obterTodos(
      'receitas',
      condicao: 'userId = ?',
      conidcaoArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Receita.fromMap(maps[i]); 
    });
  }

  Future<List<Receita>> todos() async {
    final List<Map<String, dynamic>> maps = await _db.obterTodos('receitas');
    return List.generate(maps.length, (i) {
      return Receita.fromMap(maps[i]);
    });
  }

  Future<void> removerTodosDoUsuario(String userId) async {
    await _db.deletar(
      'ingredientes',
      condicao: 'userId = ?',
      conidcaoArgs: [userId],
    );
    // Remove todas as instruções do usuário
    await _db.deletar(
      'instrucoes',
      condicao: 'userId = ?',
      conidcaoArgs: [userId],
    );
    // Remove todas as receitas do usuário
    await _db.deletar(
      'receitas',
      condicao: 'userId = ?',
      conidcaoArgs: [userId],
    );

    
  }
}