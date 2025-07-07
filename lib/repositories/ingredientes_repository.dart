import '/db/database_helper.dart';
import '/models/Ingrediente.dart';

class IngredientesRepository {

  static final DatabaseHelper _db = DatabaseHelper();

  static const String _tabela = "ingredientes";

  Future<int> adicionar(Ingrediente Ingrediente) async {
    return _db.inserir(_tabela, Ingrediente.toMap());
  }

  Future<int> atualizar(Ingrediente ingrediente) async {
    return _db.atualizar(_tabela, ingrediente.toMap());
  }

  Future<int> remover(String id) async {
    return _db.deletar(_tabela,
        condicao: "id = ?",
        conidcaoArgs: [id]);
  }

  Future<List<Ingrediente>> todosDaReceita(String idReceita) async {
    var ingrediemtesNoBanco = await _db.obterTodos(_tabela
        , condicao: "receitaId = ?",
        conidcaoArgs: [idReceita]);
    List<Ingrediente> listaDeIngredientes = [];

    for (var i = 0; i < ingrediemtesNoBanco.length; i++) {
      listaDeIngredientes.add(Ingrediente.fromMap(ingrediemtesNoBanco[i]));
    }

    return listaDeIngredientes;
  }

  Future<void> removerTodosDaReceita(String receitaId) async {
      await _db.deletar(
        'ingredientes',
        condicao: 'receitaId = ?',
        conidcaoArgs: [receitaId],
      );
    }


}