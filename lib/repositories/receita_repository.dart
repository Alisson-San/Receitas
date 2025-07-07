// repositories/receita_repository.dart
import 'package:receita/db/database_helper.dart';
import 'package:receita/models/receita.dart';
import 'package:sqflite/sqflite.dart';

class ReceitaRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<void> adicionar(Receita receita) async {
    final db = await _db.database;
    await db.insert(
      'receitas',
      receita.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizar(Receita receita) async {
    final db = await _db.database;
    await db.update(
      'receitas',
      receita.toSqliteMap(),
      where: 'id = ?',
      whereArgs: [receita.id],
    );
  }

  Future<void> remover(String id) async {
    final db = await _db.database;

    await db.delete(
      'ingredientes',
      where: 'receitaId = ?',
      whereArgs: [id],
    );

    await db.delete(
      'instrucoes',
      where: 'receitaId = ?',
      whereArgs: [id],
    );

    await db.delete(
      'receitas',
      where: 'id = ?',
      whereArgs: [id],
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