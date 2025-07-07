import '/db/database_helper.dart';
import '/models/Instrucao.dart';

class InstrucoesRepository {

  static final DatabaseHelper _db = DatabaseHelper();

  static const String _tabela = "instrucoes";

  Future<int> adicionar(Instrucao instrucoes) async {
    return _db.inserir(_tabela, instrucoes.toMap());
  }

  Future<int> atualizar(Instrucao instrucao) async {
    return _db.atualizar(_tabela, instrucao.toMap());
  }

  Future<int> remover(String id) async {
    return _db.deletar(_tabela, 
        condicao: "id = ?",
        conidcaoArgs: [id]);
  }

  Future<List<Instrucao>> todosDaReceita(String idReceita) async {
    var instrucoesNoBanco = await _db.obterTodos(_tabela
        , condicao: "receitaId = ?",
        conidcaoArgs: [idReceita]);
    List<Instrucao> listaDeInstrucoes = [];

    for (var i = 0; i < instrucoesNoBanco.length; i++) {
      listaDeInstrucoes.add(Instrucao.fromMap(instrucoesNoBanco[i]));
    }

    return listaDeInstrucoes;
  }

  Future<void> removerTodosDaReceita(String receitaId) async {
    final db = await _db.database;
    await db.delete(
      'instrucoes',
      where: 'receitaId = ?',
      whereArgs: [receitaId],
    );
  }

}